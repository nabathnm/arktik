import '../repositories/schedule_matching_repository.dart';

class SelectTripDateUseCase {
  final ScheduleMatchingRepository repository;

  SelectTripDateUseCase(this.repository);

  Future<void> execute({
    required String tripId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.selectTripDateRange(
      tripId: tripId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
