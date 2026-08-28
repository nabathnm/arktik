import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InvitationCodeDisplay extends StatelessWidget {
  final String code;

  const InvitationCodeDisplay({Key? key, required this.code}) : super(key: key);

  void _copyToClipboard(BuildContext context) async {
    final rawCode = code.length >= 6 ? code.substring(0, 6).toUpperCase() : code.toUpperCase();
    await Clipboard.setData(ClipboardData(text: rawCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation code copied to clipboard')),
      );
    }
  }

  void _shareCode() {
    final rawCode = code.length >= 6 ? code.substring(0, 6).toUpperCase() : code.toUpperCase();
    debugPrint('Sharing code: Yuk gabung! Gunakan invitation code: $rawCode');
  }

  @override
  Widget build(BuildContext context) {
    final displayCode = code.length >= 6
        ? code.substring(0, 6).toUpperCase().split('').join(' - ')
        : code.toUpperCase().split('').join(' - ');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Invitation Code:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayCode,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF26225B),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 48), // Added spacing instead of Spacer
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareCode,
            icon: const Icon(Icons.share, color: Colors.black),
            label: const Text(
              'Bagikan',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _copyToClipboard(context),
            icon: const Icon(Icons.link, color: Colors.white),
            label: const Text(
              'Salin Kode',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
