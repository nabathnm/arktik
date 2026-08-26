import 'package:googleapis/calendar/v3.dart' as calendar;
import '../../domain/entities/calendar_event_entity.dart';

class CalendarEventModel extends CalendarEventEntity {
  const CalendarEventModel({
    required super.id,
    super.title,
    super.description,
    super.start,
    super.end,
    super.htmlLink,
  });

  factory CalendarEventModel.fromGoogleEvent(calendar.Event event) {
    return CalendarEventModel(
      id: event.id ?? '',
      title: event.summary,
      description: event.description,
      start: event.start?.dateTime ?? event.start?.date,
      end: event.end?.dateTime ?? event.end?.date,
      htmlLink: event.htmlLink,
    );
  }

  calendar.Event toGoogleEvent() {
    return calendar.Event(
      id: id.isNotEmpty ? id : null,
      summary: title,
      description: description,
      start: start != null ? calendar.EventDateTime(dateTime: start) : null,
      end: end != null ? calendar.EventDateTime(dateTime: end) : null,
    );
  }
}
