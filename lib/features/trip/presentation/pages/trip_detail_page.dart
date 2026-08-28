import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member_entity.dart';

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
      extendBody: true,
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
                  height: 320,
                  decoration: const BoxDecoration(
                    color:
                        AppColors.blueNormalActive, // Deep purple from mockup
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
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/user/my-trips');
                                  }
                                },
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
                                Image.asset(
                                  'assets/images/splash/bird.png',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/images/splash/arktik.png',
                                  height: 24,
                                  color: Colors.white,
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
                        padding: EdgeInsets.only(
                          top: 24,
                          left: 24,
                          right: 24,
                          bottom: 12,
                        ),
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            '${trip.startDate != null && trip.endDate != null ? "${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}" : "Tanggal belum ditentukan"} | ${provider.leader?.name ?? 'Unknown'} (Mode ${trip.type == TripType.group
                                ? 'Grup'
                                : trip.type == TripType.family
                                ? 'Keluarga'
                                : 'Solo'})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Info Card
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
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
                                child: Image.network(
                                  "https://picsum.photos/seed/${trip.id}/200",
                                  width: 90,
                                  height: 140,
                                  fit: BoxFit.fill,
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
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Text(
                                          'Tujuan Negara: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Indonesia',
                                          style: TextStyle(
                                            fontSize: 14,
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Detail Peserta',
                                              style: TextStyle(
                                                color: AppColors.yellowNormal,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.people, size: 22),
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (trip.startDate == null || trip.endDate == null) ...[
                        // STATE 1: Date not selected
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Peserta Trip',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: provider.members.length,
                            itemBuilder: (context, index) {
                              final member = provider.members[index];
                              final isMemberLeader =
                                  member.role == TripMemberRole.owner;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: member.avatarUrl != null
                                          ? NetworkImage(member.avatarUrl!)
                                          : null,
                                      child: member.avatarUrl == null
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        member.name ?? 'Unknown Member',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (isMemberLeader)
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.black54,
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '• ${isMemberLeader ? 'Group Leader' : 'Member'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: isMemberLeader
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: TextButton.icon(
                            onPressed: () =>
                                context.push('/trip-share', extra: trip),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: const Text(
                              'Tambah Anggota',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF26225B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // STATE 2: Date is selected
                        // Tabs
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Builder(
                            builder: (context) {
                              final tabController = DefaultTabController.of(
                                context,
                              );
                              return AnimatedBuilder(
                                animation: tabController,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black87,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(24),
                                        topLeft: Radius.circular(24),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: TabBar(
                                        isScrollable: true,
                                        tabAlignment: TabAlignment.center,
                                        dividerColor: AppColors.textPrimary,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        labelPadding: EdgeInsets.zero,
                                        indicatorPadding: EdgeInsets.zero,
                                        indicator: const BoxDecoration(),
                                        labelColor: const Color(0xFF1EA5C4),
                                        unselectedLabelColor: Colors.black87,
                                        tabs: List.generate(durationInDays, (
                                          index,
                                        ) {
                                          return Tab(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 14,
                                                  ),
                                              child: Text(
                                                'Hari ${index + 1}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
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

                              // Filter itineraries for this day and sort by start time
                              final dayItineraries =
                                  provider.itineraries.where((it) {
                                    return it.visitDate.year ==
                                            currentDate.year &&
                                        it.visitDate.month ==
                                            currentDate.month &&
                                        it.visitDate.day == currentDate.day;
                                  }).toList()..sort((a, b) {
                                    if (a.startTime == null &&
                                        b.startTime == null) {
                                      return 0;
                                    }
                                    if (a.startTime == null) return 1;
                                    if (b.startTime == null) return -1;
                                    final aTime =
                                        a.startTime!.hour * 60 +
                                        a.startTime!.minute;
                                    final bTime =
                                        b.startTime!.hour * 60 +
                                        b.startTime!.minute;
                                    return aTime.compareTo(bTime);
                                  });

                              if (dayItineraries.isEmpty) {
                                return Center(
                                  child: InkWell(
                                    onTap: () {
                                      context.push(
                                        '/trip/${widget.tripId}/explore',
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                itemCount: dayItineraries.length + 1,
                                itemBuilder: (context, i) {
                                  if (i == dayItineraries.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16.0,
                                        bottom: 32.0,
                                      ),
                                      child: Center(
                                        child: InkWell(
                                          onTap: () {
                                            context.push(
                                              '/trip/${widget.tripId}/explore',
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                      ),
                                    );
                                  }

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
                                              borderRadius:
                                                  BorderRadius.circular(16),
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
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<TripProvider>(
        builder: (context, provider, child) {
          if (provider.currentTrip == null) return const SizedBox.shrink();
          final trip = provider.currentTrip!;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/trip/${trip.id}/checklist');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mulai Trip',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
