import '../entities/trip_member_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripLeaderUseCase {
  final TripRepository repository;

  GetTripLeaderUseCase(this.repository);

  Future<TripMemberEntity?> call(String tripId) async {
    return await repository.getTripLeader(tripId);
  }
}
