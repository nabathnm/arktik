import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class CreateTripUseCase {
  final TripRepository repository;

  CreateTripUseCase(this.repository);

  Future<TripEntity> execute({
    required String name,
    String? destinationId,
    DateTime? startDate,
    DateTime? endDate,
    required TripType type,
  }) {
    return repository.createTrip(
      name: name,
      destinationId: destinationId,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }
}
