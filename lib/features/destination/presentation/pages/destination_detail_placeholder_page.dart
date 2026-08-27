import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../providers/destination_provider.dart';
import '../../domain/entities/destination_entity.dart';

class DestinationDetailPlaceholderPage extends StatelessWidget {
  final String destinationId;

  const DestinationDetailPlaceholderPage({
    super.key,
    required this.destinationId,
  });

  @override
  Widget build(BuildContext context) {
    final destination = context.read<DestinationProvider>().destinations.firstWhere(
      (d) => d.id == destinationId,
      orElse: () => const DestinationEntity(
        id: '',
        name: 'Marina Bay, Singapura',
        description: 'Jalan air & distrik hiburan terkenal dengan gedung tinggi modern, bangunan terkenal, restoran & perbelanjaan.',
        location: 'Singapura',
        type: DestinationType.tourism,
        imageUrl: 'https://placeholder.com', 
        createdBy: '',
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header with back button
            Stack(
              children: [
                Image.network(
                  destination.imageUrl,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 350,
                    color: Colors.grey[300],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 48,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Title and rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: LivestTypography.h3.copyWith(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 (2.021)', // Mock rating
                        style: LivestTypography.bodySm.copyWith(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Deskripsi section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Deskripsi',
                      style: LivestTypography.bodyLgBold.copyWith(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Colors.black, thickness: 1),
                  const SizedBox(height: 24),
                  Text(
                    destination.description.isNotEmpty ? destination.description : 'Jalan air & distrik hiburan terkenal dengan gedung tinggi modern, bangunan terkenal, restoran & perbelanjaan.',
                    style: LivestTypography.bodyMd.copyWith(color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Add to Trip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showTripSelector(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add to Trip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showTripSelector(BuildContext context) {
    final tripProvider = context.read<TripProvider>();
    final activeTrips = tripProvider.myTrips.where((t) => t.selectedDate != null).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (activeTrips.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('You have no trips with a selected date yet.'),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Trip to Add Destination',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: activeTrips.length,
                itemBuilder: (context, index) {
                  final trip = activeTrips[index];
                  return ListTile(
                    leading: const Icon(Icons.flight),
                    title: Text(trip.name),
                    subtitle: Text('Date: ${trip.selectedDate!.toString().split(' ')[0]}'),
                    onTap: () async {
                      final startTime = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 9, minute: 0),
                        helpText: 'Select Start Time',
                      );
                      
                      if (startTime == null || !context.mounted) return;

                      final endTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: startTime.hour + 2, minute: startTime.minute),
                        helpText: 'Select End Time',
                      );

                      if (endTime == null || !context.mounted) return;

                      Navigator.pop(context);

                      try {
                        await tripProvider.addDestinationToTrip(
                          tripId: trip.id,
                          destinationId: destinationId,
                          visitDate: trip.selectedDate!,
                          startTime: startTime,
                          endTime: endTime,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Destination added to trip!')),
                          );
                          context.go('/trip/${trip.id}');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: AppColors.redNormal,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
