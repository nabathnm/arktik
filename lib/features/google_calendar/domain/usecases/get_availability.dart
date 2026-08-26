import 'package:rantau/features/google_calendar/domain/entities/availability_entity.dart';
import 'package:rantau/features/google_calendar/domain/repositories/google_calendar_repository.dart';

class GetAvailability {
  final GoogleCalendarRepository repository;

  GetAvailability(this.repository);

  Future<List<AvailabilityEntity>> call({
    required DateTime start,
    required DateTime end,
  }) {
    return repository.getAvailability(start: start, end: end);
  }
}
