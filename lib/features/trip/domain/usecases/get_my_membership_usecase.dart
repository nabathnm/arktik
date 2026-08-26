import '../entities/trip_member_entity.dart';
import '../repositories/trip_repository.dart';

class GetMyMembershipUseCase {
  final TripRepository repository;

  GetMyMembershipUseCase(this.repository);

  Future<TripMemberEntity?> call(String tripId) async {
    return await repository.getMyMembership(tripId);
  }
}
