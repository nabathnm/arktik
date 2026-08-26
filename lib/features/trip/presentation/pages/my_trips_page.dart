import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchMyTrips();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip Saya', style: LivestTypography.h2),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          if (provider.status == TripStateStatus.loading) {
            return const AppLoading();
          }

          if (provider.status == TripStateStatus.error) {
            return AppError(
              message: provider.errorMessage ?? 'An error occurred',
              onRetry: () => provider.fetchMyTrips(),
            );
          }
          final now = DateTime.now();
          final activeTrips = provider.myTrips
              .where(
                (t) =>
                    t.endDate.isAfter(now) || t.endDate.isAtSameMomentAs(now),
              )
              .toList();
          final pastTrips = provider.myTrips
              .where((t) => t.endDate.isBefore(now))
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            children: [
              // Sedang Berjalan Indicator
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent.shade400),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Sedang Berjalan',
                    style: TextStyle(
                      color: Colors.greenAccent.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (activeTrips.isEmpty)
                _buildEmptyState('Tidak ada trip yang sedang berjalan')
              else
                ...activeTrips.map(
                  (trip) => TripCard(
                    trip: trip,
                    onTap: () => context.push('/trip/${trip.id}'),
                  ),
                ),

              const SizedBox(height: 32),

              // Telah Berakhir Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Telah Berakhir',
                      style: LivestTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),

              if (pastTrips.isEmpty)
                _buildEmptyState('Belum ada trip yang telah berakhir')
              else
                ...pastTrips.map(
                  (trip) => TripCard(
                    trip: trip,
                    onTap: () => context.push('/trip/${trip.id}'),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-trip'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.baseWhite),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Icon(
            Icons.flight_takeoff,
            size: 48,
            color: AppColors.neutralLightActive,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: LivestTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
