import 'package:flutter/material.dart';
import 'package:rantau/features/google_calendar/domain/entities/availability_entity.dart';
import 'availability_time_slot.dart';

class AvailabilityDayView extends StatelessWidget {
  final List<AvailabilityEntity> slots;
  final bool isLoading;

  const AvailabilityDayView({
    Key? key,
    required this.slots,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton();
    }

    if (slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_available, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No scheduled events.\nYour calendar is free.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        return AvailabilityTimeSlot(entity: slots[index]);
      },
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
