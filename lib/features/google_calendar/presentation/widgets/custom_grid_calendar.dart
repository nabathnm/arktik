import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/availability_provider.dart';

class CustomGridCalendar extends StatelessWidget {
  const CustomGridCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();
    final currentMonth = provider.currentMonth;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark background matching mockup
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(context, provider, currentMonth),
          const SizedBox(height: 16),
          _buildDaysOfWeek(),
          const SizedBox(height: 8),
          _buildCalendarGrid(context, provider, currentMonth),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AvailabilityProvider provider, DateTime currentMonth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(currentMonth),
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white70),
              onPressed: () {
                provider.changeMonth(DateTime(currentMonth.year, currentMonth.month - 1, 1));
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white70),
              onPressed: () {
                provider.changeMonth(DateTime(currentMonth.year, currentMonth.month + 1, 1));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) => Expanded(
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, AvailabilityProvider provider, DateTime currentMonth) {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    // 0 = Monday in Dart, but we want Sunday to be the first day (0)
    int firstWeekday = firstDayOfMonth.weekday % 7; 
    
    // Total cells needed (can be up to 42 for 6 rows)
    int totalCells = 42; 

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0, 
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        int dayOffset = index - firstWeekday + 1;
        bool isCurrentMonth = dayOffset > 0 && dayOffset <= daysInMonth;
        
        DateTime cellDate;
        if (isCurrentMonth) {
          cellDate = DateTime(currentMonth.year, currentMonth.month, dayOffset);
        } else if (dayOffset <= 0) {
          cellDate = DateTime(currentMonth.year, currentMonth.month - 1, DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month - 1) + dayOffset);
        } else {
          cellDate = DateTime(currentMonth.year, currentMonth.month + 1, dayOffset - daysInMonth);
        }

        // Using the existing dummy logic to determine if there's an event
        bool hasEvent = _hasEvents(cellDate);

        return _buildCell(context, cellDate, isCurrentMonth, hasEvent, provider);
      },
    );
  }

  bool _hasEvents(DateTime date) {
    // Generate some fake visual events based on the date to match previous logic
    if (date.day % 7 == 2 || date.day % 7 == 3 || date.day % 7 == 5) {
      return true;
    }
    return false;
  }

  Widget _buildCell(
    BuildContext context, 
    DateTime date, 
    bool isCurrentMonth, 
    bool hasEvent,
    AvailabilityProvider provider
  ) {
    bool isSelected = DateUtils.isSameDay(date, provider.selectedDate);

    // Determine text color
    Color textColor = Colors.white;
    if (!isCurrentMonth) {
      textColor = Colors.white30; // Faded for outside month
    } else if (isSelected) {
      textColor = Colors.black; // Text is dark inside the bright blue circle
    } else if (hasEvent) {
      textColor = Colors.redAccent; // Red if it has event
    }

    return GestureDetector(
      onTap: () {
        if (isCurrentMonth) provider.selectDate(date);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF90CAF9) : Colors.transparent, // Light blue circle when selected
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
