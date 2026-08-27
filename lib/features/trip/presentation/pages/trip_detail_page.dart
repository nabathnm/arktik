import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member_entity.dart';
import '../../domain/entities/trip_summary_entity.dart';

class TripDetailPage extends StatefulWidget {
  final String tripId;

  const TripDetailPage({super.key, required this.tripId});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTripDetails(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          if (provider.status == TripStateStatus.loading) {
            return const AppLoading();
          }

          if (provider.status == TripStateStatus.error ||
              provider.currentTrip == null) {
            return AppError(
              message: provider.errorMessage ?? 'Failed to load trip',
              onRetry: () => provider.loadTripDetails(widget.tripId),
            );
          }

          final trip = provider.currentTrip!;
          final dateFormat = DateFormat('dd MMM yyyy');

          // Calculate trip duration
          int durationInDays = 1;
          DateTime startDate =
              trip.startDate ?? trip.selectedDate ?? DateTime.now();
          if (trip.startDate != null && trip.endDate != null) {
            durationInDays =
                trip.endDate!.difference(trip.startDate!).inDays + 1;
          }
          if (durationInDays < 1) durationInDays = 1;

          return DefaultTabController(
            length: durationInDays,
            child: Stack(
              children: [
                // Purple Header Background
                Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    color: Color(0xFF26225B), // Deep purple from mockup
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom AppBar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE681),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black87,
                                ),
                                onPressed: () => context.pop(),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Placeholder for Logo, using Text for now
                            Row(
                              children: [
                                const Icon(Icons.explore, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Arktik',
                                  style: LivestTypography.h3.copyWith(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const SizedBox(
                              width: 48,
                            ), // Balance the back button
                          ],
                        ),
                      ),

                      // Subtitle Info
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text(
                          '${trip.startDate != null ? dateFormat.format(trip.startDate!) : ''} - ${trip.endDate != null ? dateFormat.format(trip.endDate!) : ''} | ${provider.leader?.name ?? 'Unknown'} (Mode ${trip.type == TripType.group ? 'Grup' : 'Solo'})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Info Card
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 80,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Right Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.name,
                                    style: LivestTypography.h3.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Tujuan Negara: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const Text(
                                        '🇺🇸',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Amerika',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => context.push(
                                          '/trip/${widget.tripId}/members',
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF26225B),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Detail Peserta',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.people, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${provider.members.length}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    trip.startDate != null &&
                                            trip.endDate != null
                                        ? '${dateFormat.format(trip.startDate!)} — ${dateFormat.format(trip.endDate!)}'
                                        : 'Tanggal belum ditentukan',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tabs
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: TabBar(
                            isScrollable: true,
                            indicator: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF1EA5C4),
                                width: 2,
                              ), // Cyan border
                              borderRadius: BorderRadius.circular(16),
                            ),
                            labelColor: const Color(0xFF1EA5C4),
                            unselectedLabelColor: Colors.black87,
                            tabs: List.generate(durationInDays, (index) {
                              return Tab(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'Hari ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Timeline Content
                      Expanded(
                        child: TabBarView(
                          children: List.generate(durationInDays, (index) {
                            final currentDate = startDate.add(
                              Duration(days: index),
                            );

                            // Filter itineraries for this day
                            final dayItineraries = provider.itineraries.where((
                              it,
                            ) {
                              return it.visitDate.year == currentDate.year &&
                                  it.visitDate.month == currentDate.month &&
                                  it.visitDate.day == currentDate.day;
                            }).toList();

                            if (dayItineraries.isEmpty) {
                              return Center(
                                child: InkWell(
                                  onTap: () {
                                    context.push(
                                      '/trip/${widget.tripId}/explore',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Pilih destinasi lalu tekan Add to Trip',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF26225B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tambah Aktivitas',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              itemCount: dayItineraries.length,
                              itemBuilder: (context, i) {
                                final it = dayItineraries[i];
                                final dest = it.destination;

                                String startStr = it.startTime != null
                                    ? '${it.startTime!.hour.toString().padLeft(2, '0')}.${it.startTime!.minute.toString().padLeft(2, '0')}'
                                    : '00.00';
                                String endStr = it.endTime != null
                                    ? '${it.endTime!.hour.toString().padLeft(2, '0')}.${it.endTime!.minute.toString().padLeft(2, '0')}'
                                    : '00.00';

                                return IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Time column
                                      SizedBox(
                                        width: 50,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 12),
                                            Text(
                                              startStr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              endStr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Timeline line & dot
                                      Column(
                                        children: [
                                          const SizedBox(height: 16),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF1EA5C4),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          if (i != dayItineraries.length - 1)
                                            Expanded(
                                              child: Container(
                                                width: 1,
                                                color: Colors.grey.shade300,
                                              ),
                                            )
                                          else
                                            const Expanded(child: SizedBox()),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      // Card Content
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dest?.name ??
                                                    'Unknown Destination',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .lightBlue
                                                          .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Wisata',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Text(
                                                    '4.8',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                dest?.location ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),

                      // Mulai Trip Button
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: InkWell(
                          onTap: () {
                            // Action
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF26225B),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Mulai Trip',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
