import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripByIdUseCase {
  final TripRepository repository;

  GetTripByIdUseCase(this.repository);

  Future<TripEntity> call(String tripId) async {
    return await repository.getTripById(tripId);
  }
}
