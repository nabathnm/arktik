import '../repositories/trip_repository.dart';

class RemoveDestinationFromTripUseCase {
  final TripRepository repository;

  RemoveDestinationFromTripUseCase(this.repository);

  Future<void> execute(String itineraryId) {
    return repository.removeDestinationFromTrip(itineraryId);
  }
}
