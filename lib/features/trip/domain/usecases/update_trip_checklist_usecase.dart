import '../repositories/trip_repository.dart';

class UpdateTripChecklistUseCase {
  final TripRepository repository;

  UpdateTripChecklistUseCase(this.repository);

  Future<void> execute(String tripId, List<bool> checklist) {
    return repository.updateTripChecklist(tripId, checklist);
  }
}
