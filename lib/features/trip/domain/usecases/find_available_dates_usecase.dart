import '../entities/candidate_date_entity.dart';
import '../repositories/schedule_matching_repository.dart';

class FindAvailableDatesUseCase {
  final ScheduleMatchingRepository repository;

  FindAvailableDatesUseCase(this.repository);

  Future<List<CandidateDateEntity>> execute({
    required String tripId,
    required DateTime searchStartDate,
    required DateTime searchEndDate,
  }) {
    return repository.findAvailableDates(
      tripId: tripId,
      searchStartDate: searchStartDate,
      searchEndDate: searchEndDate,
    );
  }
}
