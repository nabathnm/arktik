import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_matching_provider.dart';
import '../providers/trip_provider.dart';

class TripDateSelectionDialog extends StatefulWidget {
  final String tripId;

  const TripDateSelectionDialog({super.key, required this.tripId});

  @override
  State<TripDateSelectionDialog> createState() =>
      _TripDateSelectionDialogState();
}

class _TripDateSelectionDialogState extends State<TripDateSelectionDialog> {
  DateTime? _start;
  DateTime? _end;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ScheduleMatchingProvider>();
      // Default search period: today to next 2 months
      provider.setSearchPeriod(
        DateTime.now(),
        DateTime.now().add(const Duration(days: 100)),
      );
      provider.findAvailableDates(widget.tripId);
    });
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil disimpan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan jadwal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd/yyyy');
    final isLoading =
        context.watch<ScheduleMatchingProvider>().status ==
        ScheduleMatchingStatus.loading;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Date Inputs
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildDateField(
                    label: _start != null
                        ? dateFormat.format(_start!)
                        : 'mm/dd/yyyy',
                    isActive: _start != null,
                    onTap: () => setState(() => _showCalendar = true),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'To',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _buildDateField(
                    label: _end != null
                        ? dateFormat.format(_end!)
                        : 'mm/dd/yyyy',
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
                        onPressed: isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26225B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan Jadwal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
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
              style: TextStyle(
                color: isActive ? Colors.black87 : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
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
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  bool _isClashDate(DateTime date) {
    final candidateDates = context
        .read<ScheduleMatchingProvider>()
        .candidateDates;
    try {
      final candidate = candidateDates.firstWhere(
        (c) => DateUtils.isSameDay(c.date, date),
      );
      return candidate.availabilityPercentage < 100;
    } catch (_) {
      return false; // No data means no clash known, or could treat as clash. Let's say false.
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final firstDayOffset = _currentMonth.weekday % 7; // Sunday = 0

    // Listen to changes in case candidate dates are loaded
    context.watch<ScheduleMatchingProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                          1,
                        );
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
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                          1,
                        );
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Days of week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map(
                  (d) => Text(
                    d,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
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

              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayNum,
              );
              final isClash = _isClashDate(date);

              bool isSelected = false;
              bool isInRange = false;

              if (widget.selectedStart != null &&
                  date.isAtSameMomentAs(widget.selectedStart!)) {
                isSelected = true;
              }
              if (widget.selectedEnd != null &&
                  date.isAtSameMomentAs(widget.selectedEnd!)) {
                isSelected = true;
              }
              if (widget.selectedStart != null && widget.selectedEnd != null) {
                if (date.isAfter(widget.selectedStart!) &&
                    date.isBefore(widget.selectedEnd!)) {
                  isInRange = true;
                }
              }

              // Disabling clash dates from being selected? Mockup just says "Bentrok", let's allow it but warn,
              // or disable. The plan says "indikator titik merah". It doesn't explicitly disable.
              // Let's add a small red dot underneath the text if it's a clash.

              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.blue
                        : isInRange
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNum.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isInRange ? Colors.blue : Colors.black87),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          height: 1.0, // prevent huge gaps
                        ),
                      ),
                      if (isClash)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.circle, color: Colors.red, size: 8),
              SizedBox(width: 8),
              Text(
                'Bentrok dengan kegiatan lain',
                style: TextStyle(color: Colors.red, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(
                  () =>
                      context
                              .findAncestorStateOfType<
                                _TripDateSelectionDialogState
                              >()!
                              ._showCalendar =
                          false,
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => setState(
                  () =>
                      context
                              .findAncestorStateOfType<
                                _TripDateSelectionDialogState
                              >()!
                              ._showCalendar =
                          false,
                ),
                child: const Text(
                  'Pilih',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
