import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member_entity.dart';

class ScheduleMatchingPage extends StatefulWidget {
  final String tripId;

  const ScheduleMatchingPage({super.key, required this.tripId});

  @override
  State<ScheduleMatchingPage> createState() => _ScheduleMatchingPageState();
}

class _ScheduleMatchingPageState extends State<ScheduleMatchingPage> {
  DateTime? _selectedStart;
  DateTime? _selectedEnd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTripDetails(widget.tripId);
    });
  }

  void _showDatePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DatePickerBottomSheet(
          initialStart: _selectedStart,
          initialEnd: _selectedEnd,
          onSave: (start, end) {
            setState(() {
              _selectedStart = start;
              _selectedEnd = end;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Jadwal berhasil disimulasikan!')),
            );
          },
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

          return Stack(
            children: [
              // Purple Header Background
              Container(
                height: 280,
                decoration: const BoxDecoration(
                  color: Color(0xFF26225B), // Deep purple
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
                          const SizedBox(width: 48), // Balance
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
                          // Left Image Placeholder (Statue of Liberty hardcoded)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 80,
                              height: 100,
                              color: Colors.grey.shade200,
                              // If they have an asset for this, they can use it. We'll use a placeholder icon for now
                              child: const Icon(Icons.image, size: 40, color: Colors.grey),
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
                                  style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Text('Tujuan Negara: ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                    Text('🇺🇸', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 4),
                                    Text('Amerika', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
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
                              border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid), // Simulated dotted via solid line for now
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                                  child: member.avatarUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    member.name ?? 'Unknown Member',
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                  ),
                                ),
                                if (isLeader)
                                  const Icon(Icons.star, size: 14, color: Colors.black54),
                                const SizedBox(width: 4),
                                Text(
                                  '• ${isLeader ? 'Group Leader' : 'Member'}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: isLeader ? FontWeight.bold : FontWeight.normal),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Add Member Button
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      label: const Text('Tambah Anggota', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF26225B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _showDatePickerBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE681),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Mulai Trip', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(width: 8),
                Icon(Icons.play_arrow, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Bottom Sheet & Custom Calendar
// ---------------------------------------------------------

class _DatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final void Function(DateTime start, DateTime end) onSave;

  const _DatePickerBottomSheet({
    required this.initialStart,
    required this.initialEnd,
    required this.onSave,
  });

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  DateTime? _start;
  DateTime? _end;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  void _onDateSelected(DateTime selected) {
    setState(() {
      if (_start == null) {
        _start = selected;
      } else if (_end == null) {
        if (selected.isBefore(_start!)) {
          _end = _start;
          _start = selected;
        } else {
          _end = selected;
        }
      } else {
        _start = selected;
        _end = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd/yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF8F8BB0), // Soft purple for header
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Text(
                'Pilih Tanggal Trip',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          // Date Inputs
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildDateField(
                  label: _start != null ? dateFormat.format(_start!) : 'mm/dd/yyyy',
                  isActive: _start != null,
                  onTap: () => setState(() => _showCalendar = true),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('To', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                ),
                _buildDateField(
                  label: _end != null ? dateFormat.format(_end!) : 'mm/dd/yyyy',
                  isActive: _end != null,
                  onTap: () => setState(() => _showCalendar = true),
                ),
                
                if (_showCalendar) ...[
                  const SizedBox(height: 24),
                  _CustomMockCalendar(
                    selectedStart: _start,
                    selectedEnd: _end,
                    onDateSelected: _onDateSelected,
                  ),
                ],

                if (_start != null && _end != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => widget.onSave(_start!, _end!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26225B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Jadwal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: isActive ? Colors.black87 : Colors.grey, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal),
            ),
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _CustomMockCalendar extends StatefulWidget {
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomMockCalendar({
    required this.selectedStart,
    required this.selectedEnd,
    required this.onDateSelected,
  });

  @override
  State<_CustomMockCalendar> createState() => _CustomMockCalendarState();
}

class _CustomMockCalendarState extends State<_CustomMockCalendar> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  bool _isClashDate(DateTime date) {
    // Mock logic: Make roughly some dates red to simulate clashes
    // e.g. 2nd, 3rd, 4th, 5th, 22nd, 24th, 25th, etc.
    final day = date.day;
    final clashDays = [2, 3, 4, 5, 22, 23, 24, 25, 26, 27, 28, 29, 30];
    return clashDays.contains(day) && date.month == _currentMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = _currentMonth.weekday % 7; // Sunday = 0
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),

          // Days of week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((d) => Text(d, style: const TextStyle(color: Colors.grey, fontSize: 12)))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar Grid
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

              final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
              final isClash = _isClashDate(date);
              
              bool isSelected = false;
              bool isInRange = false;

              if (widget.selectedStart != null && date.isAtSameMomentAs(widget.selectedStart!)) {
                isSelected = true;
              }
              if (widget.selectedEnd != null && date.isAtSameMomentAs(widget.selectedEnd!)) {
                isSelected = true;
              }
              if (widget.selectedStart != null && widget.selectedEnd != null) {
                if (date.isAfter(widget.selectedStart!) && date.isBefore(widget.selectedEnd!)) {
                  isInRange = true;
                }
              }

              return GestureDetector(
                onTap: isClash ? null : () => widget.onDateSelected(date),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : isInRange ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent,
                    border: isClash ? Border.all(color: Colors.red.shade300) : null,
                  ),
                  child: Center(
                    child: Text(
                      dayNum.toString(),
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : isClash 
                                ? Colors.red 
                                : (isInRange ? Colors.blue : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.radio_button_unchecked, color: Colors.red, size: 12),
              SizedBox(width: 4),
              Text('Bentrok dengan kegiatan lain', style: TextStyle(color: Colors.red, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
              TextButton(onPressed: () {}, child: const Text('Pilih')),
            ],
          )
        ],
      ),
    );
  }
}
