import 'package:flutter/material.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member_entity.dart';
import '../../domain/entities/trip_summary_entity.dart';
import '../../domain/entities/trip_itinerary_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl(this.remoteDataSource);

  @override
  Future<TripEntity> createTrip({
    required String name,
    String? destinationId,
    DateTime? startDate,
    DateTime? endDate,
    required TripType type,
  }) async {
    return await remoteDataSource.createTrip(
      name: name,
      destinationId: destinationId,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  @override
  Future<List<TripSummaryEntity>> getMyTrips() async {
    return await remoteDataSource.getMyTrips();
  }

  @override
  Future<TripEntity> getTripById(String tripId) async {
    return await remoteDataSource.getTripById(tripId);
  }

  @override
  Future<List<TripMemberEntity>> getTripMembers(String tripId) async {
    return await remoteDataSource.getTripMembers(tripId);
  }

  @override
  Future<TripMemberEntity?> getTripLeader(String tripId) async {
    return await remoteDataSource.getTripLeader(tripId);
  }

  @override
  Future<TripMemberEntity?> getMyMembership(String tripId) async {
    return await remoteDataSource.getMyMembership(tripId);
  }

  @override
  Future<void> leaveTrip(String tripId) async {
    return await remoteDataSource.leaveTrip(tripId);
  }

  @override
  Future<void> removeTripMember({required String tripId, required String memberUserId}) async {
    return await remoteDataSource.removeTripMember(tripId: tripId, memberUserId: memberUserId);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    return await remoteDataSource.deleteTrip(tripId);
  }

  @override
  Future<List<TripItineraryEntity>> getTripItineraries(String tripId) async {
    return await remoteDataSource.getTripItineraries(tripId);
  }

  @override
  Future<TripItineraryEntity> addDestinationToTrip({
    required String tripId,
    required String destinationId,
    required DateTime visitDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    return await remoteDataSource.addDestinationToTrip(
      tripId: tripId,
      destinationId: destinationId,
      visitDate: visitDate,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  Future<void> removeDestinationFromTrip(String itineraryId) async {
    return await remoteDataSource.removeDestinationFromTrip(itineraryId);
  }

  @override
  Future<void> updateTripChecklist(String tripId, List<bool> checklist) async {
    return await remoteDataSource.updateTripChecklist(tripId, checklist);
  }
}
