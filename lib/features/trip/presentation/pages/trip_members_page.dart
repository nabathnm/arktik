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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip Members', style: LivestTypography.h3),
        backgroundColor: AppColors.baseWhite,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          final leader = provider.leader;
          final members = provider.members.where((m) => m.role == TripMemberRole.member).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('LEADER', style: LivestTypography.captionBold),
              const SizedBox(height: 8),
              if (leader != null) _buildMemberCard(context, leader, isLeader: true),
              const SizedBox(height: 24),
              const Text('MEMBERS', style: LivestTypography.captionBold),
              const SizedBox(height: 8),
              ...members.map((m) => _buildMemberCard(context, m)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, TripMemberEntity member, {bool isLeader = false}) {
    return GestureDetector(
      onTap: () => context.push('/trip/$tripId/members/${member.userId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.baseWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isLeader ? AppColors.primary : AppColors.neutralLightActive),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.neutralLightActive,
              backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
              child: member.avatarUrl == null ? const Icon(Icons.person, color: AppColors.textSecondary) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name ?? 'Unknown', style: LivestTypography.h3),
                  Text(
                    isLeader ? 'Trip Leader' : 'Member',
                    style: LivestTypography.bodySm.copyWith(
                      color: isLeader ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isLeader) const Text('👑', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
