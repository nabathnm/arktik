import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';

abstract class GoogleCalendarRemoteDataSource {
  Future<List<calendar.Event>> getEvents();
  Future<calendar.Event> createEvent(calendar.Event event);
  Future<calendar.Event> updateEvent(calendar.Event event);
  Future<void> deleteEvent(String eventId);
  Future<List<calendar.TimePeriod>> getFreeBusy(DateTime start, DateTime end);
}

class GoogleCalendarRemoteDataSourceImpl
    implements GoogleCalendarRemoteDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleCalendarRemoteDataSourceImpl(this._googleSignIn);

  Future<calendar.CalendarApi> _getCalendarApi() async {
    const calendarScope = 'https://www.googleapis.com/auth/calendar.events';
    const calendarReadonlyScope = 'https://www.googleapis.com/auth/calendar.readonly';

    if (_googleSignIn.currentUser == null) {
      // Di platform Web, karena kita menggunakan Supabase OAuth untuk login awal,
      // plugin google_sign_in belum tahu siapa user-nya. Kita harus panggil signIn() dulu.
      await _googleSignIn.signIn();
    }

    // Pastikan user sudah memberikan akses calendar scope
    final bool isAuthorized = await _googleSignIn.requestScopes([
      calendarScope,
      calendarReadonlyScope,
    ]);
    if (!isAuthorized) {
      throw Exception('Calendar permission denied by user.');
    }

    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) {
      throw Exception(
        'User is not authenticated with Google or has not granted calendar scopes.',
      );
    }
    return calendar.CalendarApi(httpClient);
  }

  @override
  Future<List<calendar.Event>> getEvents() async {
    final api = await _getCalendarApi();
    final now = DateTime.now();
    final events = await api.events.list(
      'primary',
      maxResults: 50,
      singleEvents: true,
      orderBy: 'startTime',
      timeMin: now.toUtc(),
      timeMax: now
          .add(const Duration(days: 30))
          .toUtc(), // Batasi 30 hari ke depan
    );

    final fetchedItems = events.items ?? [];

    // Filter manual di sisi Dart untuk membuang event Ulang Tahun / Birthday
    final filteredEvents = fetchedItems.where((event) {
      final summary = event.summary?.toLowerCase() ?? '';
      final isBirthday =
          summary.contains('birthday') || summary.contains('ulang tahun');
      return !isBirthday;
    }).toList();

    return filteredEvents;
  }

  @override
  Future<calendar.Event> createEvent(calendar.Event event) async {
    final api = await _getCalendarApi();
    return await api.events.insert(event, 'primary');
  }

  @override
  Future<calendar.Event> updateEvent(calendar.Event event) async {
    final api = await _getCalendarApi();
    if (event.id == null)
      throw Exception('Event ID cannot be null for update.');
    return await api.events.update(event, 'primary', event.id!);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final api = await _getCalendarApi();
    await api.events.delete('primary', eventId);
  }

  @override
  Future<List<calendar.TimePeriod>> getFreeBusy(DateTime start, DateTime end) async {
    final api = await _getCalendarApi();
    
    final request = calendar.FreeBusyRequest(
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      items: [calendar.FreeBusyRequestItem(id: 'primary')],
    );

    final response = await api.freebusy.query(request);
    final busyPeriods = response.calendars?['primary']?.busy ?? [];
    return busyPeriods;
  }
}
