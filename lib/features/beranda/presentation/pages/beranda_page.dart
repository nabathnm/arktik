import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../../destination/presentation/providers/destination_provider.dart';
import '../widgets/beranda_header.dart';
import '../widgets/section_header.dart';
import '../widgets/my_trips_section.dart';
import '../widgets/popular_destinations_section.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchMyTrips();
      context.read<DestinationProvider>().fetchDestinations();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<TripProvider>().fetchMyTrips(),
      context.read<DestinationProvider>().fetchDestinations(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = user?.name?.split(' ').first ?? 'User';
    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BerandaHeader(firstName: firstName, avatarUrl: avatarUrl),
              const SizedBox(height: 56),

              SectionHeader(
                title: 'Trip Saya',
                onSeeAll: () => context.go('/user/my-trips'),
              ),
              const MyTripsSection(),
              const SizedBox(height: 24),

              SectionHeader(
                title: 'Rekomendasi Trip\nPopuler',
                onSeeAll: () => context.go('/user/explore'),
              ),
              const PopularDestinationsSection(),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}
