import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../trip/presentation/providers/trip_provider.dart';

class MyTripsSection extends StatelessWidget {
  const MyTripsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        if (provider.status == TripStateStatus.loading &&
            provider.myTrips.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final trips = provider.myTrips;
        if (trips.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 32.0, bottom: 16.0),
            child: Center(
              child: Text(
                'Belum ada Riwayat Trip',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          );
        }

        // Show a simplified card for the latest trip
        final trip = trips.first;
        final dateFormat = DateFormat('d MMMM yyyy');
        final duration = trip.duration;
        final progress = trip.progress;
        final progressPercent = trip.progressPercent;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: InkWell(
            onTap: () => context.push('/trip/${trip.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
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
                      // ClipRRect untuk gambar destinasi
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://picsum.photos/seed/${trip.id}/200', // Dynamic placeholder
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Detail Trip
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip.startDate != null && trip.endDate != null
                                  ? '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}'
                                  : 'Tanggal belum ditentukan',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Badge Hari
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8FB1E9), // Warna biru badge
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$duration Hari',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Text
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'Progres: '),
                        TextSpan(
                          text: '$progressPercent% Selesai',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar Custom
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0
                            ? Colors.green.shade400
                            : const Color(0xFFFDE047),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
