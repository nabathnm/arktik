import 'package:flutter/material.dart';
import '../../../trip/domain/entities/trip_summary_entity.dart';
import 'active_trip_card.dart';

class ActiveTripSection extends StatelessWidget {
  final TripSummaryEntity? activeTrip;

  const ActiveTripSection({super.key, required this.activeTrip});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'Trip Sedang Berlangsung',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        if (activeTrip != null)
          ActiveTripCard(
            trip: activeTrip!,
            onTap: () {}, // No navigation provided in reference
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Text(
              'Tidak ada trip berjalan',
              style: TextStyle(color: Colors.black54),
            ),
          ),
      ],
    );
  }
}
