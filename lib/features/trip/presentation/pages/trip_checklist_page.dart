import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/trip_provider.dart';

class TripChecklistPage extends StatefulWidget {
  final String tripId;

  const TripChecklistPage({super.key, required this.tripId});

  @override
  State<TripChecklistPage> createState() => _TripChecklistPageState();
}

class _TripChecklistPageState extends State<TripChecklistPage> {
  late List<bool> _checklistState;
  final List<String> _tasks = [
    "Sudah tentukan destinasi dan pergi dengan siapa?",
    "Sudah cari Jadwal dan beli tiket pulang pergi?",
    "Sudah booking hotel?",
    "Sudah buat itinerary dan siapkan budget?",
    "Sudah cek cuaca dan siapkan pakaian yang sesuai?",
    "Sudah packing semuanya?",
  ];

  @override
  void initState() {
    super.initState();
    _checklistState = List.filled(6, false);
    
    // Load existing state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trip = context.read<TripProvider>().currentTrip;
      if (trip != null && trip.checklistStatus != null && trip.checklistStatus!.length == 6) {
        setState(() {
          _checklistState = List.from(trip.checklistStatus!);
        });
      }
    });
  }

  void _onCheckChanged(int index, bool? value) {
    if (value == null) return;
    setState(() {
      _checklistState[index] = value;
    });
    
    // Update provider and database
    context.read<TripProvider>().updateChecklist(widget.tripId, _checklistState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7D972),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF26225B)),
          ),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Assuming there is an Arktik logo in assets or we can just use text
            // Image.asset('assets/arktik_logo.png', height: 30),
            const Text(
              'Arktik',
              style: TextStyle(
                color: Color(0xFF26225B),
                fontSize: 24,
                fontFamily: 'Cursive', // Or appropriate font
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)], // Balance the leading icon
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sebelum memulai Perjalanan, yuk pastikan semuanya udah lengkap!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.separated(
                  itemCount: _tasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _checklistState[index],
                            onChanged: (val) => _onCheckChanged(index, val),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: const Color(0xFF26225B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _tasks[index],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26225B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
