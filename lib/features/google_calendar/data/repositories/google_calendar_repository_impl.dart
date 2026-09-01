import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/repositories/google_calendar_repository.dart';
import '../datasources/google_calendar_remote_datasource.dart';
import '../models/calendar_event_model.dart';
import '../utils/availability_calculator.dart';

class GoogleCalendarRepositoryImpl implements GoogleCalendarRepository {
  final GoogleCalendarRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  GoogleCalendarRepositoryImpl(this.remoteDataSource, this.supabaseClient);

  @override
  Future<List<CalendarEventEntity>> getEvents() async {
    try {
      final googleEvents = await remoteDataSource.getEvents();
      return googleEvents
          .map((e) => CalendarEventModel.fromGoogleEvent(e))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CalendarEventEntity> createEvent({
    required CalendarEventEntity event,
  }) async {
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
  Future<CalendarEventEntity> updateEvent({
    required CalendarEventEntity event,
  }) async {
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

  @override
  Future<int> syncSchedulesToDatabase() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException('User not logged in');

      final start = DateTime.now();
      final timePeriods = [];

      for (int i = 0; i < 3; i++) {
        final chunkStart = start.add(Duration(days: i * 30));
        final chunkEnd = chunkStart.add(const Duration(days: 30));

        final chunkPeriods = await remoteDataSource.getFreeBusy(
          chunkStart,
          chunkEnd,
        );
        timePeriods.addAll(chunkPeriods);
      }

      await supabaseClient
          .from('user_availabilities')
          .delete()
          .eq('user_id', user.id);

      if (timePeriods.isEmpty) return 0;

      final insertData = timePeriods
          .where((tp) => tp.start != null && tp.end != null)
          .map((tp) {
            return {
              'user_id': user.id,
              'start_time': tp.start!.toIso8601String(),
              'end_time': tp.end!.toIso8601String(),
            };
          })
          .toList();

      if (insertData.isNotEmpty) {
        await supabaseClient.from('user_availabilities').insert(insertData);
      }
      return insertData.length;
    } catch (e) {
      throw ServerException('Gagal melakukan sinkronisasi kalender: $e');
    }
  }
}
