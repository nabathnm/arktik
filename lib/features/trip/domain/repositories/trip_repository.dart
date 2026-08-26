import '../entities/trip_entity.dart';
import '../entities/trip_member_entity.dart';
import '../entities/trip_summary_entity.dart';

abstract class TripRepository {
  Future<TripEntity> createTrip({
    required String name,
    String? destinationId,
    required DateTime startDate,
    required DateTime endDate,
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
}
