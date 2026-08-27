import '../entities/trip_itinerary_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripItinerariesUseCase {
  final TripRepository repository;

  GetTripItinerariesUseCase(this.repository);

  Future<List<TripItineraryEntity>> call(String tripId) {
    return repository.getTripItineraries(tripId);
  }
}
