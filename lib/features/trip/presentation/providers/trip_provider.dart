import 'package:flutter/material.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_summary_entity.dart';
import '../../domain/entities/trip_member_entity.dart';
import '../../domain/usecases/create_trip_usecase.dart';
import '../../domain/usecases/get_my_trips_usecase.dart';
import '../../domain/usecases/get_trip_members_usecase.dart';
import '../../domain/usecases/get_trip_leader_usecase.dart';
import '../../domain/usecases/get_my_membership_usecase.dart';
import '../../domain/usecases/get_trip_by_id_usecase.dart';
import '../../domain/usecases/remove_trip_member_usecase.dart';
import '../../domain/usecases/leave_trip_usecase.dart';
import '../../domain/usecases/delete_trip_usecase.dart';

import '../../domain/usecases/add_destination_to_trip_usecase.dart';
import '../../domain/usecases/get_trip_itineraries_usecase.dart';
import '../../domain/usecases/remove_destination_from_trip_usecase.dart';
import '../../domain/usecases/update_trip_checklist_usecase.dart';
import '../../domain/entities/trip_itinerary_entity.dart';

enum TripStateStatus { initial, loading, loaded, error }

class TripProvider extends ChangeNotifier {
  final CreateTripUseCase createTripUseCase;
  final GetMyTripsUseCase getMyTripsUseCase;
  final GetTripMembersUseCase getTripMembersUseCase;
  final GetTripLeaderUseCase getTripLeaderUseCase;
  final GetMyMembershipUseCase getMyMembershipUseCase;
  final GetTripByIdUseCase getTripByIdUseCase;
  final RemoveTripMemberUseCase removeTripMemberUseCase;
  final LeaveTripUseCase leaveTripUseCase;
  final DeleteTripUseCase deleteTripUseCase;
  
  final AddDestinationToTripUseCase addDestinationToTripUseCase;
  final GetTripItinerariesUseCase getTripItinerariesUseCase;
  final RemoveDestinationFromTripUseCase removeDestinationFromTripUseCase;
  final UpdateTripChecklistUseCase updateTripChecklistUseCase;

  TripProvider({
    required this.createTripUseCase,
    required this.getMyTripsUseCase,
    required this.getTripMembersUseCase,
    required this.getTripLeaderUseCase,
    required this.getMyMembershipUseCase,
    required this.getTripByIdUseCase,
    required this.removeTripMemberUseCase,
    required this.leaveTripUseCase,
    required this.deleteTripUseCase,
    required this.addDestinationToTripUseCase,
    required this.getTripItinerariesUseCase,
    required this.removeDestinationFromTripUseCase,
    required this.updateTripChecklistUseCase,
  });

  TripStateStatus _status = TripStateStatus.initial;
  TripStateStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TripSummaryEntity> _myTrips = [];
  List<TripSummaryEntity> get myTrips => _myTrips;

  TripEntity? _currentTrip;
  TripEntity? get currentTrip => _currentTrip;

  List<TripMemberEntity> _members = [];
  List<TripMemberEntity> get members => _members;

  TripMemberEntity? _leader;
  TripMemberEntity? get leader => _leader;

  TripMemberEntity? _myMembership;
  TripMemberEntity? get myMembership => _myMembership;

  List<TripItineraryEntity> _itineraries = [];
  List<TripItineraryEntity> get itineraries => _itineraries;

  void _setStatus(TripStateStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> createTrip({
    required String name,
    String? destinationId,
    DateTime? startDate,
    DateTime? endDate,
    required TripType type,
  }) async {
    _setStatus(TripStateStatus.loading);
    try {
      final newTrip = await createTripUseCase.execute(
        name: name,
        destinationId: destinationId,
        startDate: startDate,
        endDate: endDate,
        type: type,
      );

      _currentTrip = newTrip;
      // Refresh my trips
      await fetchMyTrips();
    } catch (e) {
      _setStatus(TripStateStatus.error, error: e.toString());
      rethrow;
    }
  }

  Future<void> fetchMyTrips() async {
    _setStatus(TripStateStatus.loading);
    try {
      _myTrips = await getMyTripsUseCase();
      _setStatus(TripStateStatus.loaded);
    } catch (e) {
      _setStatus(TripStateStatus.error, error: e.toString());
    }
  }

  Future<void> loadTripDetails(String tripId) async {
    _setStatus(TripStateStatus.loading);
    try {
      _currentTrip = await getTripByIdUseCase(tripId);
      _members = await getTripMembersUseCase(tripId);
      _leader = await getTripLeaderUseCase(tripId);
      _myMembership = await getMyMembershipUseCase(tripId);
      _itineraries = await getTripItinerariesUseCase(tripId);
      _setStatus(TripStateStatus.loaded);
    } catch (e) {
      _setStatus(TripStateStatus.error, error: e.toString());
    }
  }

  Future<void> addDestinationToTrip({
    required String tripId,
    required String destinationId,
    required DateTime visitDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    _setStatus(TripStateStatus.loading);
    try {
      final newItinerary = await addDestinationToTripUseCase.execute(
        tripId: tripId,
        destinationId: destinationId,
        visitDate: visitDate,
        startTime: startTime,
        endTime: endTime,
      );
      if (_currentTrip != null && _currentTrip!.id == tripId) {
        _itineraries = [..._itineraries, newItinerary];
      }
      _setStatus(TripStateStatus.loaded);
    } catch (e) {
      _setStatus(TripStateStatus.error, error: e.toString());
      rethrow;
    }
  }

  Future<void> removeDestinationFromTrip(String itineraryId) async {
    _setStatus(TripStateStatus.loading);
    try {
      await removeDestinationFromTripUseCase.execute(itineraryId);
      _itineraries = _itineraries.where((i) => i.id != itineraryId).toList();
      _setStatus(TripStateStatus.loaded);
    } catch (e) {
      _setStatus(TripStateStatus.error, error: e.toString());
      rethrow;
    }
  }

  Future<void> removeMember(String tripId, String memberUserId) async {
    try {
      await removeTripMemberUseCase(tripId: tripId, memberUserId: memberUserId);
      _members.removeWhere((m) => m.userId == memberUserId);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> leaveTrip(String tripId) async {
    try {
      await leaveTripUseCase(tripId);
      _myTrips.removeWhere((t) => t.id == tripId);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTrip(String tripId) async {
    _setStatus(TripStateStatus.loading);
    try {
      await deleteTripUseCase(tripId);
      _myTrips.removeWhere((t) => t.id == tripId);
      _currentTrip = null;
      _setStatus(TripStateStatus.loaded);
    } catch (e) {
      _setStatus(TripStateStatus.error, error: e.toString());
    }
  }

  Future<void> updateChecklist(String tripId, List<bool> newChecklist) async {
    if (_currentTrip == null || _currentTrip!.id != tripId) return;

    final bool allDone = newChecklist.every((e) => e == true);

    // Optimistically update the UI
    final oldTrip = _currentTrip!;
    _currentTrip = TripEntity(
      id: oldTrip.id,
      name: oldTrip.name,
      destinationId: oldTrip.destinationId,
      startDate: oldTrip.startDate,
      endDate: oldTrip.endDate,
      selectedDate: oldTrip.selectedDate,
      type: oldTrip.type,
      status: allDone ? TripStatus.completed : oldTrip.status,
      createdBy: oldTrip.createdBy,
      createdAt: oldTrip.createdAt,
      checklistStatus: newChecklist,
    );
    notifyListeners();

    try {
      await updateTripChecklistUseCase.execute(tripId, newChecklist);
    } catch (e) {
      // Revert if error
      _currentTrip = oldTrip;
      _setStatus(TripStateStatus.error, error: e.toString());
    }
  }
}
