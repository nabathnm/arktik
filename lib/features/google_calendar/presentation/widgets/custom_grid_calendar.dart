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

    return LayoutBuilder(
      builder: (context, constraints) {
        // If it's a very small mobile screen, maybe show horizontal scroll.
        // But for this, we will build the grid to be responsive.
        final bool isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            _buildHeader(context, provider, currentMonth),
            const SizedBox(height: 16),
            _buildDaysOfWeek(isMobile),
            const SizedBox(height: 8),
            _buildCalendarGrid(context, provider, currentMonth, isMobile),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AvailabilityProvider provider, DateTime currentMonth) {
    return Row(
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            provider.changeMonth(DateTime(currentMonth.year, currentMonth.month + 1, 1));
          },
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek(bool isMobile) {
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF49A9F0), // Matching the blue header in screenshot
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) => Expanded(
          child: Text(
            isMobile ? day.substring(0, 1) : day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, AvailabilityProvider provider, DateTime currentMonth, bool isMobile) {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    // 0 = Monday in Dart, but we want Sunday to be the first day (0)
    int firstWeekday = firstDayOfMonth.weekday % 7; 
    
    // Total cells needed (can be up to 42 for 6 rows)
    int totalCells = 42; 

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
          top: BorderSide(color: Colors.grey.shade200),
        )
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.8, // Adjust based on how much height you want per cell
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          int dayOffset = index - firstWeekday + 1;
          bool isCurrentMonth = dayOffset > 0 && dayOffset <= daysInMonth;
          
          DateTime cellDate;
          if (isCurrentMonth) {
            cellDate = DateTime(currentMonth.year, currentMonth.month, dayOffset);
          } else if (dayOffset <= 0) {
            // Previous month
            cellDate = DateTime(currentMonth.year, currentMonth.month - 1, DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month - 1) + dayOffset);
          } else {
            // Next month
            cellDate = DateTime(currentMonth.year, currentMonth.month + 1, dayOffset - daysInMonth);
          }

          // Generate dummy events for testing based on date
          List<Map<String, dynamic>> dummyEvents = _generateDummyEvents(cellDate);

          return _buildCell(context, cellDate, isCurrentMonth, dummyEvents, isMobile, provider);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _generateDummyEvents(DateTime date) {
    // Generate some fake visual events based on the date to match the screenshot
    if (date.day % 7 == 2) {
      return [
        {'title': 'Persiapan Monov', 'color': const Color(0xFFE5F0FA), 'borderColor': const Color(0xFF6AA7F0)},
      ];
    } else if (date.day % 7 == 3) {
      return [
        {'title': 'Monev', 'color': const Color(0xFFF3E5F5), 'borderColor': const Color(0xFFB37EE8)},
        {'title': 'Presentasi', 'color': const Color(0xFFF3E5F5), 'borderColor': const Color(0xFFB37EE8)},
        {'title': 'Masak', 'color': const Color(0xFFFDECEF), 'borderColor': const Color(0xFFEE8BA4)},
      ];
    } else if (date.day % 7 == 5) {
      return [
        {'title': 'Nonton Spiderman', 'color': const Color(0xFFF3E5F5), 'borderColor': const Color(0xFFB37EE8)},
        {'title': 'Take Video', 'color': const Color(0xFFE5F0FA), 'borderColor': const Color(0xFF6AA7F0)},
        {'title': 'Piket', 'color': const Color(0xFFFDECEF), 'borderColor': const Color(0xFFEE8BA4)},
      ];
    }
    return [];
  }

  Widget _buildCell(
    BuildContext context, 
    DateTime date, 
    bool isCurrentMonth, 
    List<Map<String, dynamic>> events,
    bool isMobile,
    AvailabilityProvider provider
  ) {
    bool isSelected = DateUtils.isSameDay(date, provider.selectedDate);
    bool isToday = DateUtils.isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: () {
        if (isCurrentMonth) provider.selectDate(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
          border: Border(
            right: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Number
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF49A9F0) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isToday 
                      ? Colors.white 
                      : (isCurrentMonth ? Colors.black87 : Colors.grey.shade400),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Events
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling if grid is tight
                child: Column(
                  children: events.map((e) => _buildEventPill(e['title'], e['color'], e['borderColor'], isMobile)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPill(String title, Color bgColor, Color borderColor, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8, vertical: isMobile ? 2 : 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
      ),
      width: double.infinity,
      child: Text(
        title,
        style: TextStyle(
          fontSize: isMobile ? 8 : 10,
          color: Colors.black45, // Soft text color
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
