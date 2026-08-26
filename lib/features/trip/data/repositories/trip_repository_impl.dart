import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member_entity.dart';
import '../../domain/entities/trip_summary_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl(this.remoteDataSource);

  @override
  Future<TripEntity> createTrip({
    required String name,
    String? destinationId,
    required DateTime startDate,
    required DateTime endDate,
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
}
