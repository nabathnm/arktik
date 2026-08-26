import '../entities/trip_summary_entity.dart';
import '../repositories/trip_repository.dart';

class GetMyTripsUseCase {
  final TripRepository repository;

  GetMyTripsUseCase(this.repository);

  Future<List<TripSummaryEntity>> call() async {
    return await repository.getMyTrips();
  }
}
