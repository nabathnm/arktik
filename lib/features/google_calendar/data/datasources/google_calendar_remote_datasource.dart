import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

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
    const calendarReadonlyScope =
        'https://www.googleapis.com/auth/calendar.readonly';
    final scopes = [calendarScope, calendarReadonlyScope];

    try {
      if (_googleSignIn.currentUser == null) {
        // Do NOT use signInSilently() here because it introduces an async delay
        // that causes the browser to lose the "user gesture" context.
        // When the user gesture is lost, subsequent popups for signIn() or requestScopes()
        // will be blocked by the browser, causing them to hang and time out.
        var account = await _googleSignIn.signIn().timeout(
          const Duration(seconds: 45),
          onTimeout: () => throw Exception(
            'Sign in popup timed out. Please check if your browser blocked the popup.',
          ),
        );

        if (account == null) {
          throw Exception('Sign in was cancelled or failed.');
        }
      }

      // Check if scopes are already granted
      final bool isAuthorized = await _googleSignIn
          .canAccessScopes(scopes)
          .timeout(const Duration(seconds: 5), onTimeout: () => false);

      if (!isAuthorized) {
        final bool granted = await _googleSignIn
            .requestScopes(scopes)
            .timeout(
              const Duration(seconds: 45),
              onTimeout: () => throw Exception(
                'Scope request timed out. Please check if your browser blocked the popup.',
              ),
            );
        if (!granted) {
          throw Exception(
            'Calendar permission denied by user. You must check the boxes to allow access.',
          );
        }
      }

      final httpClient = await _googleSignIn.authenticatedClient().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception(
          'Failed to get authenticated client. Token refresh might be hanging.',
        ),
      );
      if (httpClient == null) {
        throw Exception(
          'User is not authenticated with Google or has not granted calendar scopes.',
        );
      }
      return calendar.CalendarApi(httpClient);
    } catch (e) {
      // Re-throw so the provider can catch and handle it to stop the loading state
      throw Exception('Failed to get Calendar API: $e');
    }
  }

  @override
  Future<List<calendar.Event>> getEvents() async {
    final api = await _getCalendarApi();
    final now = DateTime.now();

    try {
      final events = await api.events
          .list(
            'primary',
            maxResults: 250,
            singleEvents: true,
            orderBy: 'startTime',
            timeMin: now
                .subtract(const Duration(days: 365))
                .toUtc(), // 1 tahun ke belakang
            timeMax: now
                .add(const Duration(days: 365))
                .toUtc(), // 1 tahun ke depan
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
              'Fetching events from Google Calendar timed out.',
            ),
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
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  @override
  Future<calendar.Event> createEvent(calendar.Event event) async {
    final api = await _getCalendarApi();
    return await api.events
        .insert(event, 'primary')
        .timeout(const Duration(seconds: 15));
  }

  @override
  Future<calendar.Event> updateEvent(calendar.Event event) async {
    final api = await _getCalendarApi();
    if (event.id == null) {
      throw Exception('Event ID cannot be null for update.');
    }
    return await api.events.update(event, 'primary', event.id!);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final api = await _getCalendarApi();
    await api.events.delete('primary', eventId);
  }

  @override
  Future<List<calendar.TimePeriod>> getFreeBusy(
    DateTime start,
    DateTime end,
  ) async {
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
