import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/trip_provider.dart';
import '../providers/schedule_matching_provider.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member_entity.dart';
import '../../domain/entities/candidate_date_entity.dart';

class ScheduleMatchingPage extends StatefulWidget {
  final String tripId;

  const ScheduleMatchingPage({super.key, required this.tripId});

  @override
  State<ScheduleMatchingPage> createState() => _ScheduleMatchingPageState();
}

class _ScheduleMatchingPageState extends State<ScheduleMatchingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load trip details
      context.read<TripProvider>().loadTripDetails(widget.tripId);

      // Load real candidate dates from Supabase (100 days forward)
      final scheduleProvider = context.read<ScheduleMatchingProvider>();
      scheduleProvider.setSearchPeriod(
        DateTime.now(),
        DateTime.now().add(const Duration(days: 100)),
      );
      scheduleProvider.findAvailableDates(widget.tripId);
    });
  }

  void _showDatePickerBottomSheet(BuildContext outerContext, List<CandidateDateEntity> candidateDates) {
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // useRootNavigator=false agar bottom sheet masih bisa akses Provider tree yang sama
      useRootNavigator: false,
      builder: (ctx) {
        // Inject providers dari outer context agar bisa diakses di dalam bottom sheet
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ScheduleMatchingProvider>.value(
              value: outerContext.read<ScheduleMatchingProvider>(),
            ),
            ChangeNotifierProvider<TripProvider>.value(
              value: outerContext.read<TripProvider>(),
            ),
          ],
          child: _DatePickerSheet(
            tripId: widget.tripId,
            candidateDates: candidateDates,
          ),
        );
      },
    );
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

          if (provider.status == TripStateStatus.error || provider.currentTrip == null) {
            return AppError(
              message: provider.errorMessage ?? 'Failed to load trip',
              onRetry: () => provider.loadTripDetails(widget.tripId),
            );
          }

          final trip = provider.currentTrip!;
          final members = provider.members;
          final leader = provider.leader;

          return Consumer<ScheduleMatchingProvider>(
            builder: (context, scheduleProvider, _) {
              final candidateDates = scheduleProvider.candidateDates;
              final isLoadingSchedule = scheduleProvider.status == ScheduleMatchingStatus.loading;

              return Stack(
                children: [
                  // Purple Header Background
                  Container(
                    height: 280,
                    decoration: const BoxDecoration(
                      color: Color(0xFF26225B),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Header Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE681),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                                  onPressed: () => context.pop(),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Image.asset('assets/images/splash/bird.png', width: 24, height: 24),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    'assets/images/splash/arktik.png',
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),

                        // Subtitle Info
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            'Tanggal belum ditentukan | ${leader?.name ?? 'Unknown'} (Mode ${trip.type == TripType.group ? 'Grup' : trip.type == TripType.family ? 'Keluarga' : 'Solo'})',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Trip Info Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 80,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trip.name,
                                      style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    // Status sinkronisasi kalender
                                    if (isLoadingSchedule)
                                      const Row(
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Menganalisis jadwal...',
                                            style: TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      )
                                    else
                                      Text(
                                        '${members.length} peserta • ${candidateDates.where((d) => d.availabilityPercentage == 100).length} hari tersedia',
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Peserta Trip Title
                        const Text(
                          'Peserta Trip',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),

                        // Members List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              final isLeader = member.role == TripMemberRole.owner;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.grey.shade400, width: 1),
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
                                          ? const Icon(Icons.person, color: Colors.grey)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        member.name ?? 'Unknown Member',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500, fontSize: 14),
                                      ),
                                    ),
                                    if (isLeader) const Icon(Icons.star, size: 14, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    Text(
                                      '• ${isLeader ? 'Group Leader' : 'Member'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<ScheduleMatchingProvider>(
        builder: (context, scheduleProvider, _) {
          final candidateDates = scheduleProvider.candidateDates;
          final isLoadingSchedule = scheduleProvider.status == ScheduleMatchingStatus.loading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: isLoadingSchedule
                    ? null
                    : () => _showDatePickerBottomSheet(context, candidateDates),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE681),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoadingSchedule
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Pilih Tanggal Trip',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// Bottom Sheet Pemilihan Tanggal (menggunakan data nyata)
// ---------------------------------------------------------

class _DatePickerSheet extends StatefulWidget {
  final String tripId;
  final List<CandidateDateEntity> candidateDates;

  const _DatePickerSheet({
    required this.tripId,
    required this.candidateDates,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  DateTime? _start;
  DateTime? _end;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  bool _isClashDate(DateTime date) {
    try {
      final candidate = widget.candidateDates.firstWhere(
        (c) => DateUtils.isSameDay(c.date, date),
      );
      // Tanggal clash jika ada SALAH SATU anggota yang tidak bisa
      return candidate.availabilityPercentage < 100;
    } catch (_) {
      // Tidak ada data = anggapan bebas (belum ada jadwal yang disinkronkan)
      return false;
    }
  }

  void _onDateSelected(DateTime selected) {
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        // Mulai pemilihan baru
        _start = selected;
        _end = null;
      } else {
        // _start sudah dipilih, sekarang pilih _end
        if (selected.isBefore(_start!)) {
          _end = _start;
          _start = selected;
        } else {
          _end = selected;
        }
      }
    });
  }

  Future<void> _onSave() async {
    if (_start == null || _end == null) return;
    try {
      await context.read<ScheduleMatchingProvider>().selectTripDateRange(
            widget.tripId,
            _start!,
            _end!,
          );
      if (mounted) {
        context.read<TripProvider>().loadTripDetails(widget.tripId);
        Navigator.pop(context); // tutup bottom sheet
        // Kembali ke trip detail setelah simpan jadwal
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil disimpan! Silakan mulai trip.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan jadwal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isLoading = context.watch<ScheduleMatchingProvider>().status ==
        ScheduleMatchingStatus.loading;

    // Hitung di dalam build() agar selalu fresh saat bulan berganti
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = _currentMonth.weekday % 7; // Mon=1 → offset 1, Sun=7 → offset 0

    return Container(
      margin: const EdgeInsets.only(top: 64),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF26225B),
            ),
            child: const Center(
              child: Text(
                'Pilih Tanggal Trip',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Tampilan tanggal terpilih
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateBox(
                          label: 'Mulai',
                          value: _start != null ? dateFormat.format(_start!) : null,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.arrow_forward, color: Colors.grey),
                      ),
                      Expanded(
                        child: _buildDateBox(
                          label: 'Selesai',
                          value: _end != null ? dateFormat.format(_end!) : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Navigasi bulan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() {
                          _currentMonth = DateTime(
                              _currentMonth.year, _currentMonth.month - 1, 1);
                        }),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_currentMonth),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() {
                          _currentMonth = DateTime(
                              _currentMonth.year, _currentMonth.month + 1, 1);
                        }),
                      ),
                    ],
                  ),

                  // Header hari
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(d,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),

                  // Grid kalender
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final dayNum = index - firstDayOffset + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return const SizedBox();
                      }

                      final date = DateTime(
                          _currentMonth.year, _currentMonth.month, dayNum);
                      final isClash = _isClashDate(date);
                      final isPast = date.isBefore(
                          DateTime.now().subtract(const Duration(days: 1)));

                      final isStart = _start != null && DateUtils.isSameDay(date, _start!);
                      final isEnd = _end != null && DateUtils.isSameDay(date, _end!);
                      final isSelected = isStart || isEnd;
                      final isInRange = _start != null &&
                          _end != null &&
                          date.isAfter(_start!) &&
                          date.isBefore(_end!);

                      Color bgColor = Colors.transparent;
                      Color textColor = isPast ? Colors.grey.shade400 : Colors.black87;
                      if (isSelected) {
                        bgColor = const Color(0xFF26225B);
                        textColor = Colors.white;
                      } else if (isInRange) {
                        bgColor = const Color(0xFF26225B).withValues(alpha: 0.15);
                        textColor = const Color(0xFF26225B);
                      }

                      return GestureDetector(
                        onTap: isPast ? null : () => _onDateSelected(date),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bgColor,
                            border: isClash && !isSelected
                                ? Border.all(color: Colors.red.shade400, width: 1.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayNum.toString(),
                                style: TextStyle(
                                  color: isClash && !isSelected
                                      ? Colors.red.shade600
                                      : textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Legenda
                  const Row(
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: Colors.transparent,
                        child: Icon(Icons.radio_button_unchecked, color: Colors.red, size: 14)),
                      SizedBox(width: 4),
                      Text('Ada anggota yang bentrok',
                          style: TextStyle(color: Colors.red, fontSize: 11)),
                      SizedBox(width: 16),
                      CircleAvatar(radius: 6, backgroundColor: Color(0xFF26225B)),
                      SizedBox(width: 4),
                      Text('Tanggal dipilih',
                          style: TextStyle(color: Color(0xFF26225B), fontSize: 11)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tombol simpan
                  if (_start != null && _end != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26225B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Simpan & Mulai Trip',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox({required String label, String? value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
            color: value != null ? const Color(0xFF26225B) : Colors.grey.shade300,
            width: value != null ? 1.5 : 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value ?? 'Belum dipilih',
            style: TextStyle(
              fontSize: 13,
              fontWeight: value != null ? FontWeight.bold : FontWeight.normal,
              color: value != null ? const Color(0xFF26225B) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
