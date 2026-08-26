import '../repositories/trip_repository.dart';

class LeaveTripUseCase {
  final TripRepository repository;

  LeaveTripUseCase(this.repository);

  Future<void> call(String tripId) async {
    await repository.leaveTrip(tripId);
  }
}
