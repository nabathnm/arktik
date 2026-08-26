import '../entities/trip_member_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripMembersUseCase {
  final TripRepository repository;

  GetTripMembersUseCase(this.repository);

  Future<List<TripMemberEntity>> call(String tripId) async {
    return await repository.getTripMembers(tripId);
  }
}
