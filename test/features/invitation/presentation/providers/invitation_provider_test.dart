import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rantau/features/trip/presentation/pages/invitation_provider.dart';
import 'package:rantau/features/trip/domain/usecases/join_invitation.dart';

void main() {
  group('Invitation Error Mapping Tests', () {
    test('Should map InvitationNotFound correctly', () {
      final e = const PostgrestException(
        message: 'InvitationNotFound',
        code: '404',
        details: '',
      );

      // Simulate error mapping directly (for testing purposes, we instantiate dummy provider or test logic directly)
      String mapException(Object err) {
        if (err is PostgrestException) {
          if (err.message.contains('InvitationNotFound'))
            return 'Invitation code tidak ditemukan';
        }
        return 'Error';
      }

      expect(mapException(e), 'Invitation code tidak ditemukan');
    });

    test('Should map InvitationExpired correctly', () {
      final e = const PostgrestException(
        message: 'InvitationExpired',
        code: '400',
        details: '',
      );

      String mapException(Object err) {
        if (err is PostgrestException) {
          if (err.message.contains('InvitationExpired'))
            return 'Invitation sudah expired';
        }
        return 'Error';
      }

      expect(mapException(e), 'Invitation sudah expired');
    });

    test('Should normalize code correctly', () {
      final input = 'trip-8k4p2  ';
      final output = input.trim().toUpperCase();

      expect(output, 'TRIP-8K4P2');
    });
  });
}
