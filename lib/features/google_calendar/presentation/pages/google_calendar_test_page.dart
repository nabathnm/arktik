import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/google_calendar_provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/calendar_event_entity.dart';

class GoogleCalendarTestPage extends StatefulWidget {
  const GoogleCalendarTestPage({super.key});

  @override
  State<GoogleCalendarTestPage> createState() => _GoogleCalendarTestPageState();
}

class _GoogleCalendarTestPageState extends State<GoogleCalendarTestPage> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();

  bool _hasEvent(DateTime date, List<CalendarEventEntity> events) {
    return events.any((event) {
      if (event.start == null) return false;
      return event.start!.year == date.year &&
          event.start!.month == date.month &&
          event.start!.day == date.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoogleCalendarProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Calendar Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Connection: ${provider.isConnected ? "Connected" : "Not Connected"}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: provider.isConnected ? Colors.green : Colors.red,
                          ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Google Calendar access is required. This allows the application to read and manage your calendar events.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.status == CalendarStateStatus.loading
                          ? null
                          : () => provider.loadEvents(),
                      child: const Text('Connect & Load Events'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Error Handling
            if (provider.status == CalendarStateStatus.error) ...[
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Text(
                  provider.errorMessage ?? 'Unknown error occurred',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: provider.status == CalendarStateStatus.creating || !provider.isConnected
                      ? null
                      : () => provider.createTestEvent(),
                  child: provider.status == CalendarStateStatus.creating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create Test Event'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            if (provider.status == CalendarStateStatus.loading)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
            else
              _buildCalendar(provider.events),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(List<CalendarEventEntity> events) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark background matching mockup
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDaysOfWeek(),
          const SizedBox(height: 8),
          _buildCalendarGrid(events),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
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
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                });
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

  Widget _buildCalendarGrid(List<CalendarEventEntity> events) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int firstWeekday = firstDayOfMonth.weekday % 7; 
    
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
          cellDate = DateTime(_currentMonth.year, _currentMonth.month, dayOffset);
        } else if (dayOffset <= 0) {
          cellDate = DateTime(_currentMonth.year, _currentMonth.month - 1, DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month - 1) + dayOffset);
        } else {
          cellDate = DateTime(_currentMonth.year, _currentMonth.month + 1, dayOffset - daysInMonth);
        }

        bool hasEvent = _hasEvent(cellDate, events);
        bool isSelected = DateUtils.isSameDay(cellDate, _selectedDate);

        Color textColor = Colors.white;
        if (!isCurrentMonth) {
          textColor = Colors.white30;
        } else if (isSelected) {
          textColor = Colors.black;
        } else if (hasEvent) {
          textColor = Colors.redAccent;
        }

        return GestureDetector(
          onTap: () {
            if (isCurrentMonth) {
              setState(() {
                _selectedDate = cellDate;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF90CAF9) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${cellDate.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
