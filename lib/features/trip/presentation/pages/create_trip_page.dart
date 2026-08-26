import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';
import '../../../destination/domain/entities/destination_entity.dart';
import '../../../destination/presentation/providers/destination_provider.dart';

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

  DateTime? _startDate;
  DateTime? _endDate;
  TripType _selectedType = TripType.solo;

  // Nanti bisa menggunakan Dropdown yang terhubung dengan API destinations
  String? _selectedDestinationId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final firstDate = isStart ? DateTime.now() : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-adjust end date if it's before the new start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal mulai dan selesai'),
        ),
      );
      return;
    }

    try {
      await context.read<TripProvider>().createTrip(
        name: _nameController.text,
        destinationId: _selectedDestinationId, // Nullable for now
        startDate: _startDate!,
        endDate: _endDate!,
        type: _selectedType,
      );

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

              // Destination Selection
              const Text(
                'Destinasi (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Autocomplete<DestinationEntity>(
                displayStringForOption: (option) =>
                    '${option.name} - ${option.location}',
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final provider = context.read<DestinationProvider>();
                  final allDestinations = provider.destinations;
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<DestinationEntity>.empty();
                  }
                  return allDestinations.where((dest) {
                    final query = textEditingValue.text.toLowerCase();
                    return dest.name.toLowerCase().contains(query) ||
                        dest.location.toLowerCase().contains(query);
                  });
                },
                onSelected: (DestinationEntity selection) {
                  setState(() {
                    _selectedDestinationId = selection.id;
                  });
                },
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Cari destinasi...',
                          border: const OutlineInputBorder(),
                          suffixIcon: _selectedDestinationId != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    textEditingController.clear();
                                    setState(() {
                                      _selectedDestinationId = null;
                                    });
                                  },
                                )
                              : const Icon(Icons.search),
                        ),
                        onChanged: (val) {
                          if (val.isEmpty) {
                            setState(() {
                              _selectedDestinationId = null;
                            });
                          }
                        },
                      );
                    },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Pilih Tanggal',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Selesai',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Pilih Tanggal',
                        ),
                      ),
                    ),
                  ),
                ],
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
                        'Simpan & Kembali',
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
