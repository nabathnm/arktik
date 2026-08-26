import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/trip_member_entity.dart';
import '../../domain/entities/trip_summary_entity.dart';
import 'package:flutter/services.dart';

class TripDetailPage extends StatefulWidget {
  final String tripId;

  const TripDetailPage({super.key, required this.tripId});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTripDetails(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip Detail', style: LivestTypography.h3),
        backgroundColor: AppColors.baseWhite,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          if (provider.status == TripStateStatus.loading) {
            return const AppLoading();
          }

          if (provider.status == TripStateStatus.error ||
              provider.currentTrip == null) {
            return AppError(
              message: provider.errorMessage ?? 'Failed to load trip',
              onRetry: () => provider.loadTripDetails(widget.tripId),
            );
          }

          final trip = provider.currentTrip!;
          final leader = provider.leader;
          final dateFormat = DateFormat('dd MMM yyyy');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.name, style: LivestTypography.h1),
                const SizedBox(height: 8),
                Text(
                  '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                  style: LivestTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                Builder(
                  builder: (context) {
                    final tripSummary = provider.myTrips.firstWhere(
                      (t) => t.id == trip.id,
                      orElse: () => TripSummaryEntity(
                        id: '',
                        name: '',
                        startDate: DateTime.now(),
                        endDate: DateTime.now(),
                        myRole: TripMemberRole.member,
                        memberCount: 0,
                      ),
                    );
                    final invitationCode = tripSummary.invitationCode;

                    if (invitationCode == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.neutralLightActive,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neutralNormal),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invitation Code',
                                  style: LivestTypography.captionBold.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  invitationCode,
                                  style: LivestTypography.h3,
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: invitationCode),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Kode trip $invitationCode disalin!',
                                      ),
                                      backgroundColor: AppColors.primary,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.copy,
                                color: AppColors.primary,
                              ),
                              tooltip: 'Copy Code',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                _buildInfoSection(
                  'Destination',
                  trip.destinationId ?? 'Not specified',
                ),

                if (leader != null)
                  _buildInfoSection(
                    'Leader',
                    leader.name ?? 'Unknown',
                    isLeader: true,
                  ),

                _buildInfoSection(
                  'Members',
                  '${provider.members.length} people',
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/trip/${widget.tripId}/members'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutralLightActive,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Members',
                      style: LivestTypography.buttonLg,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Text('LEVELS', style: LivestTypography.h3),
                const SizedBox(height: 16),

                if (provider.myMembership?.role == TripMemberRole.owner) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancel Trip'),
                            content: const Text(
                              'Are you sure you want to cancel and remove this trip? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Yes, Cancel Trip',
                                  style: TextStyle(color: AppColors.redNormal),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          await provider.deleteTrip(trip.id);
                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redLight,
                        foregroundColor: AppColors.redNormal,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.redNormal),
                        ),
                      ),
                      child: const Text(
                        'Cancel / Remove Trip',
                        style: LivestTypography.buttonLg,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String value, {
    bool isLeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: LivestTypography.captionBold.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isLeader) const Text('👑 ', style: TextStyle(fontSize: 16)),
              Text(value, style: LivestTypography.bodyLg),
            ],
          ),
        ],
      ),
    );
  }
}
