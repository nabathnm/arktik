import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InvitationCodeDisplay extends StatelessWidget {
  final String code;

  const InvitationCodeDisplay({Key? key, required this.code}) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invitation code copied to clipboard')),
    );
  }

  void _shareCode() {
    // Basic sharing logic, ideally use share_plus package
    // For now, we simulate with a print or placeholder
    debugPrint('Sharing code: Yuk gabung! Gunakan invitation code: $code');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Text(
            'Invitation Code',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            code,
            style: const TextStyle(
              fontSize: 32,
              letterSpacing: 4.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _shareCode,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
