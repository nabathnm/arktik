import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/trip_summary_entity.dart';
import 'package:intl/intl.dart';

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
        : AppColors.primary.withValues(alpha: 0.5);

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
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 6),
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
                    width: 70,
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
                      Text(
                        trip.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        trip.startDate != null && trip.endDate != null
                            ? '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}'
                            : 'Tanggal belum ditentukan',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$duration Hari',
                          style: AppTypography.captionBold.copyWith(
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
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Progres: ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: ' $progressPercent% Selesai',
                    style: const TextStyle(
                      fontSize: 12,
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
