import 'package:arktik/features/google_calendar/domain/entities/availability_entity.dart';

class AvailabilityCalculator {
  /// Mengubah list dari start/end periods (Busy) menjadi Availability list (FREE/BUSY)
  /// dalam batasan waktu tertentu berdasarkan jam kerja default.
  static List<AvailabilityEntity> calculateAvailability({
    required DateTime queryStart,
    required DateTime queryEnd,
    required List<AvailabilityEntity> busyPeriods,
  }) {
    // 1. Sort busy periods berdasarkan waktu mulai
    busyPeriods.sort((a, b) => a.start.compareTo(b.start));

    // 2. Merge overlapping and adjacent busy periods
    final List<AvailabilityEntity> mergedBusy = [];
    for (final period in busyPeriods) {
      if (mergedBusy.isEmpty) {
        mergedBusy.add(period);
      } else {
        final last = mergedBusy.last;
        // Jika overlap atau nempel (adjacent)
        if (period.start.isBefore(last.end) ||
            period.start.isAtSameMomentAs(last.end)) {
          // Ambil end time terpanjang
          final newEnd = period.end.isAfter(last.end) ? period.end : last.end;
          mergedBusy[mergedBusy.length - 1] = AvailabilityEntity(
            start: last.start,
            end: newEnd,
            status: AvailabilityStatus.busy,
          );
        } else {
          mergedBusy.add(period);
        }
      }
    }

    final List<AvailabilityEntity> finalAvailability = [];

    // Kita iterasi per hari dari queryStart sampai queryEnd.
    // Asumsi: queryStart dan queryEnd selalu berada pada pukul 00:00 (full day rentang).
    // Jika tidak, kita gunakan iterasi hari.
    DateTime currentDay = DateTime(
      queryStart.year,
      queryStart.month,
      queryStart.day,
    );
    final endDay = DateTime(queryEnd.year, queryEnd.month, queryEnd.day);

    while (currentDay.isBefore(endDay) || currentDay.isAtSameMomentAs(endDay)) {
      final workStart = DateTime(
        currentDay.year,
        currentDay.month,
        currentDay.day,
        9,
        0,
      );
      final workEnd = DateTime(
        currentDay.year,
        currentDay.month,
        currentDay.day,
        17,
        0,
      );

      // Cari busy periods yang bersinggungan dengan hari kerja ini
      final todaysBusy = mergedBusy.where((b) {
        // Bersinggungan jika start-nya sebelum workEnd DAN end-nya sesudah workStart
        return b.start.isBefore(workEnd) && b.end.isAfter(workStart);
      }).toList();

      if (todaysBusy.isEmpty) {
        // Seharian penuh free
        finalAvailability.add(
          AvailabilityEntity(
            start: workStart,
            end: workEnd,
            status: AvailabilityStatus.free,
          ),
        );
      } else {
        DateTime cursor = workStart;

        for (final busy in todaysBusy) {
          // Clip busy period ke workStart dan workEnd
          final clippedStart = busy.start.isBefore(workStart)
              ? workStart
              : busy.start;
          final clippedEnd = busy.end.isAfter(workEnd) ? workEnd : busy.end;

          // Jika ada ruang free sebelum busy
          if (clippedStart.isAfter(cursor)) {
            finalAvailability.add(
              AvailabilityEntity(
                start: cursor,
                end: clippedStart,
                status: AvailabilityStatus.free,
              ),
            );
          }

          // Tambahkan busy (jika valid > 0 detik)
          if (clippedStart.isBefore(clippedEnd)) {
            finalAvailability.add(
              AvailabilityEntity(
                start: clippedStart,
                end: clippedEnd,
                status: AvailabilityStatus.busy,
              ),
            );
          }

          cursor = clippedEnd.isAfter(cursor) ? clippedEnd : cursor;
        }

        // Tambahkan sisa hari sebagai free
        if (cursor.isBefore(workEnd)) {
          finalAvailability.add(
            AvailabilityEntity(
              start: cursor,
              end: workEnd,
              status: AvailabilityStatus.free,
            ),
          );
        }
      }

      currentDay = currentDay.add(const Duration(days: 1));
    }

    return finalAvailability;
  }
}
