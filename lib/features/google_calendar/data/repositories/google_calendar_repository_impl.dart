import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/repositories/google_calendar_repository.dart';
import '../datasources/google_calendar_remote_datasource.dart';
import '../models/calendar_event_model.dart';
import '../utils/availability_calculator.dart';

class GoogleCalendarRepositoryImpl implements GoogleCalendarRepository {
  final GoogleCalendarRemoteDataSource remoteDataSource;

  GoogleCalendarRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CalendarEventEntity>> getEvents() async {
    try {
      final googleEvents = await remoteDataSource.getEvents();
      return googleEvents.map((e) => CalendarEventModel.fromGoogleEvent(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CalendarEventEntity> createEvent({required CalendarEventEntity event}) async {
    try {
      final model = CalendarEventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        start: event.start,
        end: event.end,
      );
      final created = await remoteDataSource.createEvent(model.toGoogleEvent());
      return CalendarEventModel.fromGoogleEvent(created);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CalendarEventEntity> updateEvent({required CalendarEventEntity event}) async {
    try {
      final model = CalendarEventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        start: event.start,
        end: event.end,
      );
      final updated = await remoteDataSource.updateEvent(model.toGoogleEvent());
      return CalendarEventModel.fromGoogleEvent(updated);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteEvent({required String eventId}) async {
    try {
      await remoteDataSource.deleteEvent(eventId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AvailabilityEntity>> getAvailability({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final timePeriods = await remoteDataSource.getFreeBusy(start, end);

      final busyPeriods = timePeriods.map((tp) {
        return AvailabilityEntity(
          start: tp.start ?? DateTime.now(),
          end: tp.end ?? DateTime.now(),
          status: AvailabilityStatus.busy,
        );
      }).toList();

      return AvailabilityCalculator.calculateAvailability(
        queryStart: start,
        queryEnd: end,
        busyPeriods: busyPeriods,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
