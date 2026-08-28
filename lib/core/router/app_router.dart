import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/trip/domain/entities/trip_entity.dart';
import 'package:rantau/features/destination/presentation/pages/eksplor_page.dart';
import 'package:rantau/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:rantau/main.dart';
import '../../features/google_calendar/presentation/pages/availability_calendar_page.dart';
import 'package:provider/provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../widgets/app_navigation_bar.dart';
import '../../features/destination/presentation/pages/admin_dashboard_page.dart';
import '../../features/destination/presentation/pages/destination_management_page.dart';
import '../../features/destination/presentation/pages/create_destination_page.dart';
import '../../features/destination/presentation/pages/destination_detail_placeholder_page.dart';
import '../../features/trip/presentation/pages/create_invitation_page.dart';
import '../../features/trip/presentation/pages/join_invitation_page.dart';
import '../../features/beranda/presentation/pages/beranda_page.dart';
import '../../features/trip/presentation/pages/create_trip_page.dart';
import '../../features/trip/presentation/pages/share_token_page.dart';
import '../../features/trip/presentation/pages/my_trips_page.dart';
import '../../features/trip/presentation/pages/trip_detail_page.dart';
import '../../features/trip/presentation/pages/trip_members_page.dart';
import '../../features/trip/presentation/pages/member_detail_page.dart';
import '../../features/trip/presentation/pages/schedule_matching_page.dart';
import '../../features/trip/presentation/pages/trip_checklist_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    refreshListenable: config.authProvider,
    redirect: (context, state) {
      final authStatus = config.authProvider.status;
      final isAuthRoute = state.matchedLocation == '/auth';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // Check if onboarding is completed
      final onboardingCompleted =
          config.sharedPreferences.getBool('onboarding_completed') ?? false;

      // If onboarding not completed, stay on onboarding
      if (!onboardingCompleted) {
        return isOnboardingRoute ? null : '/onboarding';
      }

      // If onboarding completed, skip onboarding route
      if (isOnboardingRoute) {
        return '/auth';
      }

      if (authStatus == AuthStateStatus.unauthenticated ||
          authStatus == AuthStateStatus.initial ||
          authStatus == AuthStateStatus.error) {
        return isAuthRoute ? null : '/auth';
      }

      if (authStatus == AuthStateStatus.authenticated) {
        final user = config.authProvider.user;

        // Prevent access to /auth if already authenticated
        if (isAuthRoute) {
          if (user?.role == UserRole.admin) return '/admin/dashboard';
          return '/user/home';
        }

        // Prevent users from accessing admin routes
        if (state.matchedLocation.startsWith('/admin') &&
            user?.role != UserRole.admin) {
          return '/user/home';
        }

        // Prevent admins from accessing user routes (forces them to admin dashboard)
        if (state.matchedLocation.startsWith('/user') &&
            user?.role == UserRole.admin) {
          return '/admin/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: "onboarding",
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth',
        name: "auth",
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/destination/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DestinationDetailPlaceholderPage(destinationId: id);
        },
      ),
      GoRoute(
        path: '/availability',
        builder: (context, state) => const AvailabilityCalendarPage(),
      ),
      // Combined Shell for both Admin and User
      ShellRoute(
        builder: (context, state, child) => AppNavigationBar(child: child),
        routes: [
          // Admin Routes
          GoRoute(
            path: '/admin/dashboard',
            name: "admin_dashboard",
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: '/admin/destinations',
            name: "admin_destinations",
            builder: (context, state) => const DestinationManagementPage(),
          ),
          GoRoute(
            path: '/admin/destinations/create',
            name: "admin_create_destination",
            builder: (context, state) => const CreateDestinationPage(),
          ),
          // User Main Routes
          GoRoute(
            path: '/user/home',
            name: "user_home",
            builder: (context, state) => const BerandaPage(),
          ),
          GoRoute(
            path: '/user/explore',
            name: "user_explore",
            builder: (context, state) => const EksplorPage(),
          ),
          GoRoute(
            path: '/user/my-trips',
            name: "user_my_trips",
            builder: (context, state) => const MyTripsPage(),
          ),
          GoRoute(
            path: '/user/profile',
            name: "user_profile",
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      // Other User Routes (Without Navigation Bar)
      GoRoute(
        path: '/trip/:tripId',
        builder: (context, state) {
          final id = state.pathParameters['tripId']!;
          return TripDetailPage(tripId: id);
        },
      ),
      GoRoute(
        path: '/trip/:tripId/matching',
        builder: (context, state) {
          final id = state.pathParameters['tripId']!;
          return ScheduleMatchingPage(tripId: id);
        },
      ),
      GoRoute(
        path: '/trip/:tripId/checklist',
        builder: (context, state) {
          final id = state.pathParameters['tripId']!;
          return TripChecklistPage(tripId: id);
        },
      ),
      GoRoute(
        path: '/trip/:tripId/explore',
        builder: (context, state) => const EksplorPage(),
      ),
      GoRoute(
        path: '/trip/:tripId/members',
        builder: (context, state) {
          final id = state.pathParameters['tripId']!;
          return TripMembersPage(tripId: id);
        },
      ),
      GoRoute(
        path: '/trip/:tripId/members/:userId',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final userId = state.pathParameters['userId']!;
          return MemberDetailPage(tripId: tripId, userId: userId);
        },
      ),
      GoRoute(
        path: '/user/create-trip',
        builder: (context, state) => const CreateTripPage(),
      ),
      GoRoute(
        path: '/trip-share',
        builder: (context, state) {
          final trip = state.extra as TripEntity;
          return ShareTokenPage(trip: trip);
        },
      ),
      GoRoute(
        path: '/user/create-invitation',
        builder: (context, state) => const CreateInvitationPage(),
      ),
      GoRoute(
        path: '/user/join-invitation',
        builder: (context, state) => const JoinInvitationPage(),
      ),
      GoRoute(
        path: '/trip/:id/level-1',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Scaffold(
            appBar: AppBar(title: const Text('Level 1 - Party Mode')),
            body: Center(
              child: Text('Trip ID: $id - Placeholder untuk Level 1'),
            ),
          );
        },
      ),
    ],
  );
}
