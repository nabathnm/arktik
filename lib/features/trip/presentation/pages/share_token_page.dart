import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/trip_entity.dart';
import '../widgets/invitation_code_display.dart';

import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'invitation_provider.dart';

class ShareTokenPage extends StatefulWidget {
  final TripEntity trip;

  const ShareTokenPage({super.key, required this.trip});

  @override
  State<ShareTokenPage> createState() => _ShareTokenPageState();
}

class _ShareTokenPageState extends State<ShareTokenPage> {
  String? _code;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrCreateCode();
  }

  Future<void> _fetchOrCreateCode() async {
    final client = Supabase.instance.client;
    try {
      final data = await client
          .from('invitations')
          .select('code')
          .eq('trip_id', widget.trip.id)
          .eq('status', 'active')
          .maybeSingle();

      if (data != null) {
        if (mounted) {
          setState(() {
            _code = data['code'];
            _isLoading = false;
          });
        }
      } else {
        // Create new
        final success = await context.read<InvitationProvider>().createNewInvitation(
              maxMembers: 20, // generous default
              expiresAt: DateTime.now().add(const Duration(days: 30)),
              tripId: widget.trip.id,
            );
        if (success && mounted) {
          final inv = context.read<InvitationProvider>().currentInvitation;
          setState(() {
            _code = inv?.code;
            _isLoading = false;
          });
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format code for display
    final displayCode = _isLoading 
        ? 'Memuat...' 
        : (_code ?? 'Gagal membuat kode');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFE681),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () {
                // Return to trip page
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/trip/${widget.trip.id}');
                }
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.trip.type == TripType.family ? 'Keluarga' : 'Tim',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.trip.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26225B),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              _isLoading 
                  ? const CircularProgressIndicator(color: Color(0xFF26225B))
                  : InvitationCodeDisplay(code: displayCode),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
