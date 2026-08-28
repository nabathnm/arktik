import 'package:flutter/material.dart';

class NotificationSetting extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const NotificationSetting({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, size: 28),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Notifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF1E1E5C), // Dark blue
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
