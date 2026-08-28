import 'package:flutter_test/flutter_test.dart';
import 'package:arktik/features/google_calendar/domain/entities/availability_entity.dart';
import 'package:arktik/features/google_calendar/data/utils/availability_calculator.dart';

void main() {
  group('AvailabilityCalculator Tests', () {
    final queryStart = DateTime(2026, 8, 23, 0, 0); // Sunday
    final queryEnd = DateTime(2026, 8, 23, 23, 59);

    test('Test 1: Tidak ada event (Full FREE)', () {
      final result = AvailabilityCalculator.calculateAvailability(
        queryStart: queryStart,
        queryEnd: queryEnd,
        busyPeriods: [],
      );

      expect(result.length, 1);
      expect(result.first.status, AvailabilityStatus.free);
    });

    test('Test 2: Satu event di tengah hari kerja', () {
      final busyPeriods = [
        AvailabilityEntity(
          start: DateTime(2026, 8, 23, 10, 0),
          end: DateTime(2026, 8, 23, 11, 0),
          status: AvailabilityStatus.busy,
        ),
      ];

      final result = AvailabilityCalculator.calculateAvailability(
        queryStart: queryStart,
        queryEnd: queryEnd,
        busyPeriods: busyPeriods,
      );

      expect(result.length, 3);

      expect(result[0].status, AvailabilityStatus.free);
      expect(result[0].start.hour, 9);
      expect(result[0].end.hour, 10);

      expect(result[1].status, AvailabilityStatus.busy);
      expect(result[1].start.hour, 10);
      expect(result[1].end.hour, 11);

      expect(result[2].status, AvailabilityStatus.free);
      expect(result[2].start.hour, 11);
      expect(result[2].end.hour, 17);
    });

    test('Test 3: Overlapping events digabung', () {
      final busyPeriods = [
        AvailabilityEntity(
          start: DateTime(2026, 8, 23, 10, 0),
          end: DateTime(2026, 8, 23, 11, 0),
          status: AvailabilityStatus.busy,
        ),
        AvailabilityEntity(
          start: DateTime(2026, 8, 23, 10, 30),
          end: DateTime(2026, 8, 23, 12, 0),
          status: AvailabilityStatus.busy,
        ),
      ];

      final result = AvailabilityCalculator.calculateAvailability(
        queryStart: queryStart,
        queryEnd: queryEnd,
        busyPeriods: busyPeriods,
      );

      // Harusnya: 9-10 Free, 10-12 Busy, 12-17 Free
      expect(result.length, 3);
      expect(result[1].status, AvailabilityStatus.busy);
      expect(result[1].start.hour, 10);
      expect(result[1].end.hour, 12);
    });

    test('Test 4: Adjacent events digabung', () {
      final busyPeriods = [
        AvailabilityEntity(
          start: DateTime(2026, 8, 23, 10, 0),
          end: DateTime(2026, 8, 23, 11, 0),
          status: AvailabilityStatus.busy,
        ),
        AvailabilityEntity(
          start: DateTime(2026, 8, 23, 11, 0),
          end: DateTime(2026, 8, 23, 12, 0),
          status: AvailabilityStatus.busy,
        ),
      ];

      final result = AvailabilityCalculator.calculateAvailability(
        queryStart: queryStart,
        queryEnd: queryEnd,
        busyPeriods: busyPeriods,
      );

      expect(result.length, 3);
      expect(result[1].status, AvailabilityStatus.busy);
      expect(result[1].start.hour, 10);
      expect(result[1].end.hour, 12);
    });

    test('Test 5: All-day event (atau event menutupi seluruh hari kerja)', () {
      final busyPeriods = [
        AvailabilityEntity(
          start: DateTime(2026, 8, 23, 0, 0), // Dari tengah malam
          end: DateTime(2026, 8, 24, 0, 0), // Sampai tengah malam besoknya
          status: AvailabilityStatus.busy,
        ),
      ];

      final result = AvailabilityCalculator.calculateAvailability(
        queryStart: queryStart,
        queryEnd: queryEnd,
        busyPeriods: busyPeriods,
      );

      // Karena di-clip ke jam kerja, harusnya hanya ada 1 event BUSY dari 09:00 - 17:00
      expect(result.length, 1);
      expect(result[0].status, AvailabilityStatus.busy);
    });

    test('Test 6: Event di luar jam kerja (diabaikan)', () {
      final busyPeriods = [
        AvailabilityEntity(
          start: DateTime(2026, 8, 23, 6, 0),
          end: DateTime(2026, 8, 23, 7, 0),
          status: AvailabilityStatus.busy,
        ),
        AvailabilityEntity(
          start: DateTime(2026, 8, 23, 19, 0),
          end: DateTime(2026, 8, 23, 20, 0),
          status: AvailabilityStatus.busy,
        ),
      ];

      final result = AvailabilityCalculator.calculateAvailability(
        queryStart: queryStart,
        queryEnd: queryEnd,
        busyPeriods: busyPeriods,
      );

      // Tetap 9-17 Free karena event di luar range
      expect(result.length, 1);
      expect(result[0].status, AvailabilityStatus.free);
    });
  });
}
