import '../entities/calendar_event_entity.dart';
import '../repositories/google_calendar_repository.dart';

class GetCalendarEvents {
  final GoogleCalendarRepository repository;

  GetCalendarEvents(this.repository);

  Future<List<CalendarEventEntity>> call() async {
    return repository.getEvents();
  }
}

class CreateCalendarEvent {
  final GoogleCalendarRepository repository;

  CreateCalendarEvent(this.repository);

  Future<CalendarEventEntity> call({required CalendarEventEntity event}) async {
    return repository.createEvent(event: event);
  }
}

class UpdateCalendarEvent {
  final GoogleCalendarRepository repository;

  UpdateCalendarEvent(this.repository);

  Future<CalendarEventEntity> call({required CalendarEventEntity event}) async {
    return repository.updateEvent(event: event);
  }
}

class DeleteCalendarEvent {
  final GoogleCalendarRepository repository;

  DeleteCalendarEvent(this.repository);

  Future<void> call({required String eventId}) async {
    return repository.deleteEvent(eventId: eventId);
  }
}
