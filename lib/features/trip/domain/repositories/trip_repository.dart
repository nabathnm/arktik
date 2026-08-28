import 'package:flutter/material.dart';
import '../entities/trip_entity.dart';
import '../entities/trip_member_entity.dart';
import '../entities/trip_summary_entity.dart';
import '../entities/trip_itinerary_entity.dart';

abstract class TripRepository {
  Future<TripEntity> createTrip({
    required String name,
    String? destinationId,
    DateTime? startDate,
    DateTime? endDate,
    required TripType type,
  });

  Future<List<TripSummaryEntity>> getMyTrips();

  Future<TripEntity> getTripById(String tripId);

  Future<List<TripMemberEntity>> getTripMembers(String tripId);

  Future<TripMemberEntity?> getTripLeader(String tripId);

  Future<TripMemberEntity?> getMyMembership(String tripId);

  Future<void> leaveTrip(String tripId);

  Future<void> removeTripMember({required String tripId, required String memberUserId});

  Future<void> deleteTrip(String tripId);

  Future<List<TripItineraryEntity>> getTripItineraries(String tripId);

  Future<TripItineraryEntity> addDestinationToTrip({
    required String tripId,
    required String destinationId,
    required DateTime visitDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  });

  Future<void> removeDestinationFromTrip(String itineraryId);

  Future<void> updateTripChecklist(String tripId, List<bool> checklist);
}
