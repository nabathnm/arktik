import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../domain/entities/candidate_date_entity.dart';
import '../../domain/repositories/schedule_matching_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../../google_calendar/domain/repositories/google_calendar_repository.dart';
import '../../../google_calendar/domain/entities/availability_entity.dart';

class ScheduleMatchingRepositoryImpl implements ScheduleMatchingRepository {
  final SupabaseClient supabaseClient;
  final TripRepository tripRepository;
  final GoogleCalendarRepository googleCalendarRepository;

  ScheduleMatchingRepositoryImpl(
    this.supabaseClient,
    this.tripRepository,
    this.googleCalendarRepository,
  );

  @override
  Future<List<CandidateDateEntity>> findAvailableDates({
    required String tripId,
    required DateTime searchStartDate,
    required DateTime searchEndDate,
  }) async {
    try {
      // 1. Dapatkan semua anggota trip untuk mengetahui totalMembersCount
      final members = await tripRepository.getTripMembers(tripId);
      final totalMembers = members.length;
      final memberIds = members.map((m) => m.userId).toList();

      // 2. Fetch seluruh jadwal sibuk dari database (hanya untuk anggota trip)
      // dalam rentang searchStartDate dan searchEndDate
      final response = await supabaseClient
          .from('user_availabilities')
          .select()
          .inFilter('user_id', memberIds)
          .gte('end_time', searchStartDate.toIso8601String())
          .lte('start_time', searchEndDate.add(const Duration(days: 1)).toIso8601String());

      final List<dynamic> busyData = response as List<dynamic>;

      // Map dari userId ke list event sibuk
      final Map<String, List<Map<String, DateTime>>> memberBusySchedules = {};
      for (var id in memberIds) {
        memberBusySchedules[id] = [];
      }

      for (var data in busyData) {
        final userId = data['user_id'] as String;
        final start = DateTime.parse(data['start_time']).toLocal();
        final end = DateTime.parse(data['end_time']).toLocal();
        
        memberBusySchedules[userId]?.add({'start': start, 'end': end});
      }

      final List<CandidateDateEntity> candidates = [];
      
      // 3. Iterasi setiap hari dari start sampai end
      DateTime currentDate = searchStartDate;
      while (currentDate.isBefore(searchEndDate.add(const Duration(days: 1)))) {
        int availableCount = 0;

        for (var member in members) {
          bool isMemberFree = true;
          final schedules = memberBusySchedules[member.userId] ?? [];

          // Cek apakah member ini ada jadwal sibuk di tanggal 'currentDate'
          final currentDay = DateTime(currentDate.year, currentDate.month, currentDate.day);
          
          final isBusy = schedules.any((schedule) {
            final eventStart = schedule['start']!;
            final eventEnd = schedule['end']!;
            
            final eStart = DateTime(eventStart.year, eventStart.month, eventStart.day);
            final eEnd = DateTime(eventEnd.year, eventEnd.month, eventEnd.day);
            
            // Event mencakup hari ini
            return (currentDay.isAtSameMomentAs(eStart) || currentDay.isAfter(eStart)) && 
                   (currentDay.isAtSameMomentAs(eEnd) || currentDay.isBefore(eEnd));
          });

          isMemberFree = !isBusy;

          if (isMemberFree) {
            availableCount++;
          }
        }

        // Masukkan semua tanggal di range pencarian ke candidate (bahkan jika 0 orang yang bisa)
        candidates.add(CandidateDateEntity(
          date: currentDate,
          availableMembersCount: availableCount,
          totalMembersCount: totalMembers,
        ));

        currentDate = currentDate.add(const Duration(days: 1));
      }

      // Sort by date ASC so it's easier to process
      candidates.sort((a, b) => a.date.compareTo(b.date));

      // Kembalikan semua tanggal dalam rentang, bukan hanya 10 terbaik, agar kalender bisa menampilkan data lengkap
      return candidates;
    } catch (e) {
      throw Exception('Failed to calculate schedules: $e');
    }
  }

  @override
  Future<void> selectTripDateRange({
    required String tripId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await supabaseClient
        .from('trips')
        .update({
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'status': 'date_selected',
        })
        .eq('id', tripId);
  }
}
