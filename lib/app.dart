import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rantau/main.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/google_calendar/presentation/providers/google_calendar_provider.dart';
import 'features/destination/presentation/providers/destination_provider.dart';
import 'features/trip/presentation/pages/invitation_provider.dart';
import 'features/trip/presentation/providers/trip_provider.dart';
import 'features/trip/presentation/providers/schedule_matching_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: config.authProvider),
        ChangeNotifierProvider<DestinationProvider>.value(
          value: config.destinationProvider,
        ),
        ChangeNotifierProvider<GoogleCalendarProvider>.value(
          value: config.googleCalendarProvider,
        ),
        ChangeNotifierProvider<DestinationProvider>.value(
          value: config.destinationProvider,
        ),
        ChangeNotifierProvider<InvitationProvider>.value(
          value: config.invitationProvider,
        ),
        ChangeNotifierProvider<TripProvider>.value(value: config.tripProvider),
        ChangeNotifierProvider<ScheduleMatchingProvider>.value(
          value: config.scheduleMatchingProvider,
        ),
      ],
      child: MaterialApp.router(
        title: 'Schedule Matchmaking',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
