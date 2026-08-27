import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import '../../domain/entities/trip_summary_entity.dart';

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
          if (provider.status == TripStateStatus.loading &&
              provider.myTrips.isEmpty) {
            return const AppLoading();
          }

          if (provider.status == TripStateStatus.error) {
            return AppError(
              message: provider.errorMessage ?? 'An error occurred',
              onRetry: () => provider.fetchMyTrips(),
            );
          }
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final groupedActive = <DateTime, List<TripSummaryEntity>>{};
          final groupedPast = <DateTime, List<TripSummaryEntity>>{};

          for (final trip in provider.myTrips) {
            final ref = trip.endDate ?? trip.selectedDate;
            final isPast =
                ref != null && ref.isBefore(now) && !ref.isAtSameMomentAs(now);

            final key = ref != null
                ? DateTime(ref.year, ref.month, ref.day)
                : DateTime(2100);
            if (isPast) {
              groupedPast.putIfAbsent(key, () => []).add(trip);
            } else {
              groupedActive.putIfAbsent(key, () => []).add(trip);
            }
          }

          final sortedActiveKeys = groupedActive.keys.toList()..sort();
          final sortedPastKeys = groupedPast.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<TripProvider>().fetchMyTrips();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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

                if (groupedActive.isEmpty)
                  _buildEmptyState('Tidak ada trip yang sedang berjalan')
                else
                  ...sortedActiveKeys.expand((date) {
                    final trips = groupedActive[date]!;
                    final dateStr = date.year == 2100
                        ? 'TBD'
                        : '${date.day}/${date.month}/${date.year}';
                    return [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                        child: Text(
                          dateStr,
                          style: LivestTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...trips.map(
                        (trip) => TripCard(
                          trip: trip,
                          onTap: () => context.push('/trip/${trip.id}'),
                        ),
                      ),
                    ];
                  }),

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

                if (groupedPast.isEmpty)
                  _buildEmptyState('Belum ada trip yang telah berakhir')
                else
                  ...sortedPastKeys.expand((date) {
                    final trips = groupedPast[date]!;
                    final dateStr = '${date.day}/${date.month}/${date.year}';
                    return [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                        child: Text(
                          dateStr,
                          style: LivestTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...trips.map(
                        (trip) => TripCard(
                          trip: trip,
                          onTap: () => context.push('/trip/${trip.id}'),
                        ),
                      ),
                    ];
                  }),
              ],
            ),
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
