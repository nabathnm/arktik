import '../entities/calendar_event_entity.dart';
import 'package:arktik/features/google_calendar/domain/entities/availability_entity.dart';

abstract class GoogleCalendarRepository {
  Future<List<CalendarEventEntity>> getEvents();

  Future<CalendarEventEntity> createEvent({
    required CalendarEventEntity event,
  });

  Future<CalendarEventEntity> updateEvent({
    required CalendarEventEntity event,
  });

  Future<void> deleteEvent({
    required String eventId,
  });

  Future<List<AvailabilityEntity>> getAvailability({
    required DateTime start,
    required DateTime end,
  });

  Future<void> syncSchedulesToDatabase();
}
