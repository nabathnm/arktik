import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/trip_summary_entity.dart';
import '../../domain/entities/trip_member_entity.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class TripCard extends StatelessWidget {
  final TripSummaryEntity trip;
  final VoidCallback onTap;

  const TripCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy');
    final duration = (trip.startDate != null && trip.endDate != null)
        ? trip.endDate!.difference(trip.startDate!).inDays + 1
        : 0;
    final now = DateTime.now();

    double progress = 0.0;
    if (trip.startDate != null && trip.endDate != null) {
      if (now.isAfter(trip.endDate!) || now.isAtSameMomentAs(trip.endDate!)) {
        progress = 1.0;
      } else if (now.isAfter(trip.startDate!)) {
        progress = duration > 0
            ? now.difference(trip.startDate!).inDays / duration
            : 0.0;
      }
    }
    progress = progress.clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toInt();

    // Determine colors
    final isCompleted = progress == 1.0;
    final progressColor = isCompleted
        ? Colors.green.shade200
        : AppColors.primary.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.baseWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://picsum.photos/seed/${trip.id}/200', // Placeholder image
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '🇺🇸',
                            style: TextStyle(fontSize: 16),
                          ), // Placeholder flag
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              trip.name,
                              style: LivestTypography.h3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${trip.startDate != null ? dateFormat.format(trip.startDate!) : "-"} - ${trip.endDate != null ? dateFormat.format(trip.endDate!) : "-"}',
                        style: LivestTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(
                            0.5,
                          ), // Match badge color from design (blueish)
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$duration Hari',
                          style: LivestTypography.captionBold.copyWith(
                            color: AppColors.baseWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Section
            RichText(
              text: TextSpan(
                style: LivestTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Progres: '),
                  TextSpan(
                    text: '$progressPercent% Selesai',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
