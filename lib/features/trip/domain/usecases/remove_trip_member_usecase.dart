import '../repositories/trip_repository.dart';

class RemoveTripMemberUseCase {
  final TripRepository repository;

  RemoveTripMemberUseCase(this.repository);

  Future<void> call({required String tripId, required String memberUserId}) async {
    await repository.removeTripMember(tripId: tripId, memberUserId: memberUserId);
  }
}
