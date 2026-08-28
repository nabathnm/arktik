import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/availability_provider.dart';

class AvailabilityCalendar extends StatelessWidget {
  const AvailabilityCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();
    final currentMonth = provider.currentMonth;
    final selectedDate = provider.selectedDate;

    // Generate days for the current month view (simplification: showing a scrollable list of days)
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    
    return Column(
      children: [
        // Month Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                provider.changeMonth(DateTime(currentMonth.year, currentMonth.month - 1, 1));
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                provider.changeMonth(DateTime(currentMonth.year, currentMonth.month + 1, 1));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Days Row
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final date = DateTime(currentMonth.year, currentMonth.month, index + 1);
              final isSelected = DateUtils.isSameDay(date, selectedDate);
              
              return GestureDetector(
                onTap: () => provider.selectDate(date),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
