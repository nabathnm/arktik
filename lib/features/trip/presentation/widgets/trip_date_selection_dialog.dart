import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/schedule_matching_provider.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/candidate_date_entity.dart';

class TripDateSelectionDialog extends StatefulWidget {
  final String tripId;

  const TripDateSelectionDialog({super.key, required this.tripId});

  @override
  State<TripDateSelectionDialog> createState() => _TripDateSelectionDialogState();
}

class _TripDateSelectionDialogState extends State<TripDateSelectionDialog> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ScheduleMatchingProvider>();
      provider.setSearchPeriod(DateTime.now(), DateTime.now().add(const Duration(days: 90)));
      provider.findAvailableDates(widget.tripId);
    });
  }

  void _onSaveSchedule() async {
    if (_selectedStartDate == null || _selectedEndDate == null) return;
    try {
      await context.read<ScheduleMatchingProvider>().selectTripDateRange(
        widget.tripId, 
        _selectedStartDate!, 
        _selectedEndDate!
      );
      if (mounted) {
        context.read<TripProvider>().loadTripDetails(widget.tripId);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.baseWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF867DA6), // Muted purple as per screenshot
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Text(
                'Pilih Tanggal Trip',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildDateField(
                    label: _selectedStartDate != null 
                        ? DateFormat('MM/dd/yyyy').format(_selectedStartDate!)
                        : 'mm/dd/yyyy',
                    onTap: () {
                      setState(() {
                        _showCalendar = !_showCalendar;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('To', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _buildDateField(
                    label: _selectedEndDate != null 
                        ? DateFormat('MM/dd/yyyy').format(_selectedEndDate!)
                        : 'mm/dd/yyyy',
                    onTap: () {
                      setState(() {
                        _showCalendar = !_showCalendar;
                      });
                    },
                  ),

                  if (_showCalendar) ...[
                    const SizedBox(height: 16),
                    _buildCustomCalendar(),
                  ],

                  if (!_showCalendar && _selectedStartDate != null && _selectedEndDate != null) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSaveSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C1959), // Dark purple
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Simpan Jadwal',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCalendar() {
    return Consumer<ScheduleMatchingProvider>(
      builder: (context, provider, child) {
        if (provider.status == ScheduleMatchingStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: AppLoading(),
          );
        }

        final candidates = provider.candidateDates;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              _buildCalendarGrid(candidates),
              const SizedBox(height: 16),
              // Legend
              Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bentrok dengan kegiatan lain',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCalendar = false;
                      });
                    },
                    child: const Text('Tutup', style: TextStyle(color: Colors.blue)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCalendar = false;
                      });
                    },
                    child: const Text('Pilih', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(List<CandidateDateEntity> candidates) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int firstWeekday = firstDayOfMonth.weekday % 7; 
    
    int totalCells = 42; 

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0, 
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        int dayOffset = index - firstWeekday + 1;
        bool isCurrentMonth = dayOffset > 0 && dayOffset <= daysInMonth;
        
        if (!isCurrentMonth) {
          DateTime cellDate;
          if (dayOffset <= 0) {
            cellDate = DateTime(_currentMonth.year, _currentMonth.month - 1, DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month - 1) + dayOffset);
          } else {
            cellDate = DateTime(_currentMonth.year, _currentMonth.month + 1, dayOffset - daysInMonth);
          }
          return Center(
            child: Text('${cellDate.day}', style: const TextStyle(color: Colors.grey)),
          );
        }

        DateTime cellDate = DateTime(_currentMonth.year, _currentMonth.month, dayOffset);
        
        CandidateDateEntity? candidate;
        try {
          candidate = candidates.firstWhere((c) => DateUtils.isSameDay(c.date, cellDate));
        } catch (_) {}

        bool isSelectedStart = _selectedStartDate != null && DateUtils.isSameDay(cellDate, _selectedStartDate!);
        bool isSelectedEnd = _selectedEndDate != null && DateUtils.isSameDay(cellDate, _selectedEndDate!);
        
        bool isInRange = false;
        if (_selectedStartDate != null && _selectedEndDate != null) {
          if ((cellDate.isAfter(_selectedStartDate!) && cellDate.isBefore(_selectedEndDate!)) ||
              DateUtils.isSameDay(cellDate, _selectedStartDate!) ||
              DateUtils.isSameDay(cellDate, _selectedEndDate!)) {
            isInRange = true;
          }
        } else if (isSelectedStart) {
          isInRange = true;
        }

        bool hasConflict = false;
        if (candidate != null && candidate.availabilityPercentage < 100) {
          hasConflict = true; // Bentrok
        }

        Color textColor = Colors.black87;
        Color boxColor = Colors.transparent;

        if (isInRange) {
          textColor = Colors.blueAccent;
          boxColor = Colors.blue.withOpacity(0.1);
        }

        if (isSelectedStart || isSelectedEnd) {
          textColor = Colors.white;
          boxColor = Colors.blueAccent;
        }

        if (hasConflict && !isSelectedStart && !isSelectedEnd) {
           textColor = Colors.red;
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedStartDate == null || (_selectedStartDate != null && _selectedEndDate != null)) {
                _selectedStartDate = cellDate;
                _selectedEndDate = null;
              } else if (cellDate.isBefore(_selectedStartDate!)) {
                _selectedStartDate = cellDate;
              } else {
                _selectedEndDate = cellDate;
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: boxColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${cellDate.day}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: (isSelectedStart || isSelectedEnd) ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (hasConflict)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4, height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
