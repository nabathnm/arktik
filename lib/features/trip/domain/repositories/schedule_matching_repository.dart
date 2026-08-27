import '../entities/candidate_date_entity.dart';

abstract class ScheduleMatchingRepository {
  Future<List<CandidateDateEntity>> findAvailableDates({
    required String tripId,
    required DateTime searchStartDate,
    required DateTime searchEndDate,
  });

  Future<void> selectTripDateRange({
    required String tripId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
