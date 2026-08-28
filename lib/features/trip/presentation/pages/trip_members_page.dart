import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/trip_member_entity.dart';

class TripMembersPage extends StatelessWidget {
  final String tripId;

  const TripMembersPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Peserta Trip',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          final trip = provider.currentTrip;
          if (trip == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: provider.members.length,
                  itemBuilder: (context, index) {
                    final member = provider.members[index];
                    final isMemberLeader = member.role == TripMemberRole.owner;

                    return GestureDetector(
                      onTap: () => context.push(
                        '/trip/$tripId/members/${member.userId}',
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: member.avatarUrl != null
                                  ? NetworkImage(member.avatarUrl!)
                                  : null,
                              child: member.avatarUrl == null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                member.name ?? 'Unknown Member',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (isMemberLeader)
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.black54,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              '• ${isMemberLeader ? 'Group Leader' : 'Member'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: isMemberLeader
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
