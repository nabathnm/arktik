import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/google_calendar_provider.dart';
import 'package:intl/intl.dart';

class GoogleCalendarTestPage extends StatelessWidget {
  const GoogleCalendarTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoogleCalendarProvider>();
    final dateFormat = DateFormat('MMM dd, HH:mm');

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
            
            // Events List
            Text(
              'Events:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (provider.status == CalendarStateStatus.loading)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
            else if (provider.events.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No events found.')))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.events.length,
                itemBuilder: (context, index) {
                  final event = provider.events[index];
                  final isTestEvent = event.title?.contains('Flutter Google Calendar Integration Test') == true;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(event.title ?? '(No title)'),
                      subtitle: Text(
                        '${event.start != null ? dateFormat.format(event.start!) : "Unknown"} - '
                        '${event.end != null ? dateFormat.format(event.end!) : "Unknown"}',
                      ),
                      trailing: isTestEvent ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: provider.status == CalendarStateStatus.updating 
                                ? null 
                                : () => provider.updateTestEvent(event),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: provider.status == CalendarStateStatus.deleting 
                                ? null 
                                : () => provider.deleteTestEvent(event.id),
                          ),
                        ],
                      ) : null,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
