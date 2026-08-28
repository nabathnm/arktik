import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rantau/main.dart';
import '../providers/availability_provider.dart';
import '../widgets/custom_grid_calendar.dart';
import '../widgets/availability_day_view.dart';

class AvailabilityCalendarPage extends StatefulWidget {
  const AvailabilityCalendarPage({super.key});

  @override
  State<AvailabilityCalendarPage> createState() =>
      _AvailabilityCalendarPageState();
}

class _AvailabilityCalendarPageState extends State<AvailabilityCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: config.availabilityProvider..selectDate(DateTime.now()),
      child: const _AvailabilityCalendarView(),
    );
  }
}

class _AvailabilityCalendarView extends StatelessWidget {
  const _AvailabilityCalendarView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Availability')),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomGridCalendar(),
              const SizedBox(height: 32),

              // Selected Date Header
              Text(
                'Selected Date',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(provider.selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 32),

              // Error State
              if (provider.state == AvailabilityState.error) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage ?? 'An error occurred',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: provider.refresh,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ]
              // Loaded or Loading State
              else ...[
                AvailabilityDayView(
                  slots: provider.currentAvailability,
                  isLoading: provider.state == AvailabilityState.loading,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
