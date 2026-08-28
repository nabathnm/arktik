import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'invitation_provider.dart';
import '../../../google_calendar/presentation/providers/google_calendar_provider.dart';

class JoinInvitationPage extends StatefulWidget {
  const JoinInvitationPage({Key? key}) : super(key: key);

  @override
  State<JoinInvitationPage> createState() => _JoinInvitationPageState();
}

class _JoinInvitationPageState extends State<JoinInvitationPage> {
  final _codeController = TextEditingController();
  bool _isValidating = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onJoinPressed() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidating = true);

    // Tampilkan popup untuk sinkronisasi kalender TERLEBIH DAHULU
    final shouldSync = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hubungkan Kalender?'),
        content: const Text(
          'Agar kami dapat mencocokkan jadwal Anda dengan anggota trip lainnya secara akurat, izinkan kami mengimpor jadwal kosong Anda dari Google Calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hubungkan'),
          ),
        ],
      ),
    );

    if (shouldSync == true && mounted) {
      try {
        await context.read<GoogleCalendarProvider>().syncSchedulesToDatabase();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kalender berhasil disinkronisasi!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal sinkronisasi kalender: $e')),
          );
        }
      }
    }

    if (!mounted) return;

    final provider = context.read<InvitationProvider>();
    final success = await provider.join(code);

    setState(() => _isValidating = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil bergabung dengan trip!')),
      );

      context.go('/user/my-trips');
    } else if (mounted) {
      final error = provider.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Gagal bergabung dengan invitation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isJoining =
        context.watch<InvitationProvider>().status ==
        InvitationStateStatus.joining;
    final isLoading = _isValidating || isJoining;

    return Scaffold(
      appBar: AppBar(title: const Text('Join Invitation')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan kode invitation',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 4.0,
                fontWeight: FontWeight.bold,
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _onJoinPressed(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading || _codeController.text.trim().isEmpty
                  ? null
                  : _onJoinPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Join Invitation',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
