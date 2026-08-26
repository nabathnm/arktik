import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/invitation_entity.dart';
import 'invitation_provider.dart';
import '../widgets/invitation_code_display.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class InvitationDetailPage extends StatefulWidget {
  final String invitationId;

  const InvitationDetailPage({Key? key, required this.invitationId})
    : super(key: key);

  @override
  State<InvitationDetailPage> createState() => _InvitationDetailPageState();
}

class _InvitationDetailPageState extends State<InvitationDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationProvider>().loadInvitationDetails(
        widget.invitationId,
      );
    });
  }

  void _leaveInvitation() async {
    final success = await context.read<InvitationProvider>().leave(
      widget.invitationId,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda telah keluar dari invitation')),
      );
      context.pop();
    }
  }

  void _closeInvitation() async {
    final success = await context.read<InvitationProvider>().close(
      widget.invitationId,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invitation ditutup')));
      // Status will reload via provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvitationProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (provider.status == InvitationStateStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final inv = provider.currentInvitation;
    if (inv == null || inv.id != widget.invitationId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final isCreator = inv.createdBy == authProvider.user?.id;
    final members = provider.currentMembers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitation'),
        actions: [
          if (isCreator && inv.status == InvitationStatus.active)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Tutup Invitation?'),
                    content: const Text(
                      'Orang lain tidak akan bisa bergabung lagi jika ditutup.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _closeInvitation();
                        },
                        child: const Text(
                          'Tutup',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (!isCreator)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Keluar dari Invitation?'),
                    content: const Text('Anda akan keluar dari grup ini.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _leaveInvitation();
                        },
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InvitationCodeDisplay(code: inv.code),
            const SizedBox(height: 24),
            Text(
              inv.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (inv.description != null && inv.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(inv.description!, style: const TextStyle(fontSize: 16)),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: Text('Status: ${inv.status.name.toUpperCase()}'),
              subtitle: Text(
                'Expires: ${DateFormat('dd MMM yyyy, HH:mm').format(inv.expiresAt)}',
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Members (${members.length} / ${inv.maxMembers})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: member.userAvatarUrl != null
                        ? NetworkImage(member.userAvatarUrl!)
                        : null,
                    child: member.userAvatarUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(member.userName ?? 'User'),
                  subtitle: Text(
                    'Joined: ${DateFormat('dd MMM').format(member.joinedAt)}',
                  ),
                  trailing: member.userId == inv.createdBy
                      ? const Chip(label: Text('Owner'))
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
