import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';
import '../../../destination/domain/entities/destination_entity.dart';
import '../../../destination/presentation/providers/destination_provider.dart';
import '../../../google_calendar/presentation/providers/google_calendar_provider.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final destProvider = context.read<DestinationProvider>();
      if (destProvider.destinations.isEmpty) {
        destProvider.fetchDestinations();
      }
    });
  }

  TripType _selectedType = TripType.solo;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<TripProvider>().createTrip(
        name: _nameController.text,
        destinationId: null,
        startDate: null,
        endDate: null,
        type: _selectedType,
      );

      if (!mounted) return;

      // Sinkronisasi kalender Google untuk leader setelah membuat trip
      try {
        await context.read<GoogleCalendarProvider>().syncSchedulesToDatabase();
      } catch (_) {
        // Sync gagal tidak menghalangi pembuatan trip
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip dibuat, tapi sinkronisasi kalender gagal. Silakan coba sync manual.')),
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trip berhasil dibuat!')));
      context.pop(); // Kembali ke halaman sebelumnya
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat trip: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final isLoading = tripProvider.status == TripStateStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Trip Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Trip',
                  hintText: 'Cth: Bromo Weekend Trip',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama trip harus diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Tipe Trip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TripType>(
                segments: const [
                  ButtonSegment(value: TripType.solo, label: Text('Solo')),
                  ButtonSegment(value: TripType.group, label: Text('Geng')),
                  ButtonSegment(value: TripType.family, label: Text('Family')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TripType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Buat Trip',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
