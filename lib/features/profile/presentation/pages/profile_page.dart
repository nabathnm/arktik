import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trip/domain/entities/trip_summary_entity.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../widgets/active_trip_section.dart';
import '../widgets/logout_button.dart';
import '../widgets/notification_setting.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchMyTrips();
    });
  }

  TripSummaryEntity? _getActiveTrip(List<TripSummaryEntity> trips) {
    final now = DateTime.now();
    final activeTrips = trips.where((trip) {
      final ref = trip.endDate ?? trip.selectedDate;
      return ref == null || !ref.isBefore(now) || ref.isAtSameMomentAs(now);
    }).toList();

    activeTrips.sort((a, b) {
      final dateA = a.startDate ?? a.selectedDate ?? DateTime(2100);
      final dateB = b.startDate ?? b.selectedDate ?? DateTime(2100);
      return dateA.compareTo(dateB);
    });

    return activeTrips.isNotEmpty ? activeTrips.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final trips = context.watch<TripProvider>().myTrips;
    final activeTrip = _getActiveTrip(trips);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 20),
            const Divider(color: Colors.black, thickness: 0.5),
            const SizedBox(height: 8),

            ActiveTripSection(activeTrip: activeTrip),

            const SizedBox(height: 24),
            const Divider(color: Colors.black, thickness: 0.5),
            const SizedBox(height: 24),

            NotificationSetting(
              isEnabled: _isNotificationEnabled,
              onChanged: (val) {
                setState(() {
                  _isNotificationEnabled = val;
                });
              },
            ),

            const SizedBox(height: 24),

            LogoutButton(
              onLogout: () {
                context.read<AuthProvider>().signOut();
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
