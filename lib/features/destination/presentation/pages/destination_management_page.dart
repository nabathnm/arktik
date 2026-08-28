import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/destination_provider.dart';

class DestinationManagementPage extends StatelessWidget {
  const DestinationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final destProvider = context.watch<DestinationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Destinations')),
      body: destProvider.state == DestinationState.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: destProvider.destinations.length,
              itemBuilder: (context, index) {
                final dest = destProvider.destinations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Image.network(
                      dest.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported),
                    ),
                    title: Text(
                      dest.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(dest.location)],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirm(
                        context,
                        destProvider,
                        dest.id,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/destinations/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    DestinationProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text(
          'Are you sure you want to delete this destination?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeDestination(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
