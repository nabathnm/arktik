import 'package:flutter/material.dart';
import 'package:rantau/features/google_calendar/domain/entities/availability_entity.dart';
import 'package:intl/intl.dart';

class AvailabilityTimeSlot extends StatelessWidget {
  final AvailabilityEntity entity;

  const AvailabilityTimeSlot({Key? key, required this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFree = entity.status == AvailabilityStatus.free;
    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(entity.start);
    final endTime = timeFormat.format(entity.end);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isFree ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isFree ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$startTime - $endTime',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isFree ? Colors.green[800] : Colors.red[800],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isFree ? 'FREE' : 'BUSY',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isFree ? Colors.green[800] : Colors.red[800],
                letterSpacing: 1.2,
              ),
            ),
          ),
          Icon(
            isFree ? Icons.check_circle_outline : Icons.block,
            color: isFree ? Colors.green[600] : Colors.red[600],
          ),
        ],
      ),
    );
  }
}
