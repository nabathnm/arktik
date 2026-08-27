import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/schedule_matching_provider.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/candidate_date_entity.dart';
import '../../domain/entities/trip_member_entity.dart';

class ScheduleMatchingPage extends StatefulWidget {
  final String tripId;

  const ScheduleMatchingPage({super.key, required this.tripId});

  @override
  State<ScheduleMatchingPage> createState() => _ScheduleMatchingPageState();
}

class _ScheduleMatchingPageState extends State<ScheduleMatchingPage> {
  DateTime? _searchStart;
  DateTime? _searchEnd;

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ScheduleMatchingProvider>();
      provider.setSearchPeriod(DateTime.now(), DateTime.now().add(const Duration(days: 30)));
      setState(() {
        _searchStart = provider.searchStartDate;
        _searchEnd = provider.searchEndDate;
      });
      _onFindDates();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_searchStart ?? DateTime.now())
        : (_searchEnd ?? _searchStart ?? DateTime.now());
    final firstDate = isStart ? DateTime.now() : (_searchStart ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _searchStart = picked;
          if (_searchEnd != null && _searchEnd!.isBefore(_searchStart!)) {
            _searchEnd = _searchStart;
          }
        } else {
          _searchEnd = picked;
        }
      });
      if (mounted) {
        context.read<ScheduleMatchingProvider>().setSearchPeriod(_searchStart!, _searchEnd!);
      }
    }
  }

  void _onFindDates() {
    if (_searchStart == null || _searchEnd == null) return;
    context.read<ScheduleMatchingProvider>().findAvailableDates(widget.tripId);
  }

  void _onSelectCandidate() async {
    if (_selectedStartDate == null || _selectedEndDate == null) return;
    
    final dateFormat = DateFormat('dd MMM yyyy');
    final rangeStr = _selectedStartDate == _selectedEndDate 
        ? dateFormat.format(_selectedStartDate!)
        : '${dateFormat.format(_selectedStartDate!)} - ${dateFormat.format(_selectedEndDate!)}';
        
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Trip Date'),
        content: Text('Set trip date to $rangeStr?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<ScheduleMatchingProvider>().selectTripDateRange(widget.tripId, _selectedStartDate!, _selectedEndDate!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip date selected!')),
          );
          // Refresh the trip details so the status updates
          context.read<TripProvider>().loadTripDetails(widget.tripId);
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLeader = context.watch<TripProvider>().myMembership?.role == TripMemberRole.owner;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find Trip Date'),
        backgroundColor: AppColors.baseWhite,
        elevation: 1,
      ),
      body: Consumer<ScheduleMatchingProvider>(
        builder: (context, provider, child) {
          final isLoading = provider.status == ScheduleMatchingStatus.loading;
          
          return Column(
            children: [
              if (isLeader) _buildSearchForm(),
              
              if (isLoading)
                const Expanded(child: Center(child: AppLoading()))
              else if (provider.status == ScheduleMatchingStatus.error)
                Expanded(
                  child: Center(
                    child: Text(
                      provider.errorMessage ?? 'An error occurred',
                      style: const TextStyle(color: AppColors.redNormal),
                    ),
                  ),
                )
              else if (provider.status == ScheduleMatchingStatus.loaded && provider.candidateDates.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No dates found. Try a different period.'),
                  ),
                )
              else if (provider.status == ScheduleMatchingStatus.loaded)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCalendar(provider.candidateDates, isLeader),
                        if (isLeader && _selectedStartDate != null) ...[
                          const SizedBox(height: 24),
                          _buildSelectedDateDetails(provider.candidateDates),
                        ],
                      ],
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text('Select a period and tap Find Dates', style: LivestTypography.bodyLg),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDateDetails(List<CandidateDateEntity> candidates) {
    if (_selectedStartDate == null) return const SizedBox.shrink();
    
    // Hitung rata-rata availability untuk range ini
    int totalAvailable = 0;
    int totalMembers = candidates.isNotEmpty ? candidates.first.totalMembersCount : 0;
    int dayCount = 0;
    
    final end = _selectedEndDate ?? _selectedStartDate!;
    
    for (var candidate in candidates) {
      if ((candidate.date.isAfter(_selectedStartDate!.subtract(const Duration(days: 1))) && 
           candidate.date.isBefore(end.add(const Duration(days: 1))))) {
        totalAvailable += candidate.availableMembersCount;
        dayCount++;
      }
    }
    
    double avgAvailable = dayCount > 0 ? (totalAvailable / dayCount) : 0.0;
    double avgPercentage = totalMembers > 0 ? (avgAvailable / totalMembers) * 100 : 0.0;
    
    final dateFormat = DateFormat('EEEE, dd MMM yyyy');
    final rangeStr = _selectedStartDate == _selectedEndDate 
        ? dateFormat.format(_selectedStartDate!)
        : '${dateFormat.format(_selectedStartDate!)} -\n${dateFormat.format(_selectedEndDate!)}';
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected Trip Date', style: LivestTypography.h3),
            const SizedBox(height: 12),
            Text(
              rangeStr,
              style: LivestTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.group, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dayCount > 0 
                      ? 'Avg Available: ${avgAvailable.toStringAsFixed(1)} / $totalMembers members (${avgPercentage.toInt()}%)'
                      : 'Outside search period or no data',
                    style: LivestTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSelectCandidate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.baseWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Confirm Trip Date', style: LivestTypography.buttonLg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(List<CandidateDateEntity> candidates, bool isLeader) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark background
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDaysOfWeek(),
          const SizedBox(height: 8),
          _buildCalendarGrid(candidates, isLeader),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) => Expanded(
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(List<CandidateDateEntity> candidates, bool isLeader) {
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
        
        DateTime cellDate;
        if (isCurrentMonth) {
          cellDate = DateTime(_currentMonth.year, _currentMonth.month, dayOffset);
        } else if (dayOffset <= 0) {
          cellDate = DateTime(_currentMonth.year, _currentMonth.month - 1, DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month - 1) + dayOffset);
        } else {
          cellDate = DateTime(_currentMonth.year, _currentMonth.month + 1, dayOffset - daysInMonth);
        }

        // Cari apakah tanggal ini ada di list candidates
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

        Color textColor = Colors.white;
        Color boxColor = Colors.transparent;

        if (!isCurrentMonth) {
          textColor = Colors.white30;
        } else if (candidate != null) {
          // Highlight based on availability percentage
          if (candidate.availabilityPercentage == 100) {
            textColor = Colors.greenAccent; 
            if (isInRange) boxColor = Colors.greenAccent.withOpacity(0.3);
          } else if (candidate.availabilityPercentage >= 50) {
            textColor = Colors.yellowAccent; 
            if (isInRange) boxColor = Colors.yellowAccent.withOpacity(0.3);
          } else {
            textColor = Colors.orangeAccent; 
            if (isInRange) boxColor = Colors.orangeAccent.withOpacity(0.3);
          }
        } else if (isInRange) {
          textColor = Colors.black;
          boxColor = const Color(0xFF90CAF9);
        }

        if (isInRange && candidate == null) {
          boxColor = const Color(0xFF90CAF9);
          textColor = Colors.black;
        } else if (isInRange && candidate != null) {
           boxColor = textColor.withOpacity(0.3);
        }

        return GestureDetector(
          onTap: () {
            if (isCurrentMonth && isLeader) {
              setState(() {
                if (_selectedStartDate == null || (_selectedStartDate != null && _selectedEndDate != null)) {
                  // Start new range selection
                  _selectedStartDate = cellDate;
                  _selectedEndDate = null;
                } else if (cellDate.isBefore(_selectedStartDate!)) {
                  // Reset start date if selected date is earlier
                  _selectedStartDate = cellDate;
                } else {
                  // Complete range selection
                  _selectedEndDate = cellDate;
                }
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: boxColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${cellDate.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isInRange || candidate != null ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchForm() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.baseWhite,
        border: Border(bottom: BorderSide(color: AppColors.neutralNormal)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Search Period', style: LivestTypography.h3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      _searchStart != null ? dateFormat.format(_searchStart!) : 'Select Date',
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
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      _searchEnd != null ? dateFormat.format(_searchEnd!) : 'Select Date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_searchStart != null && _searchEnd != null) ? _onFindDates : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.baseWhite,
            ),
            child: const Text('Find Available Dates', style: LivestTypography.buttonLg),
          ),
        ],
      ),
    );
  }
}
