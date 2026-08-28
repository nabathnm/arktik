import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/trip_member_entity.dart';

class MemberDetailPage extends StatelessWidget {
  final String tripId;
  final String userId;

  const MemberDetailPage({
    super.key,
    required this.tripId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TripProvider>();
    final member = provider.members.firstWhere(
      (m) => m.userId == userId,
      orElse: () => provider.leader!,
    );
    final isLeader = member.role == TripMemberRole.owner;
    final isMe = provider.myMembership?.userId == userId;
    final amIOwner = provider.myMembership?.role == TripMemberRole.owner;
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: AppTypography.h3),
        backgroundColor: AppColors.baseWhite,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.neutralLightActive,
              backgroundImage: member.avatarUrl != null
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            Text(member.name ?? 'Unknown', style: AppTypography.h1),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLeader
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.neutralLightActive,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLeader)
                    const Text('👑 ', style: TextStyle(fontSize: 16)),
                  Text(
                    isLeader ? 'TRIP LEADER' : 'Trip Member',
                    style: AppTypography.captionBold.copyWith(
                      color: isLeader
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoRow('Joined', dateFormat.format(member.joinedAt)),
            const Spacer(),
            if (amIOwner && !isLeader && !isMe)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirmRemove(context, provider, member),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    foregroundColor: AppColors.error,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Remove from Trip',
                    style: AppTypography.buttonLg,
                  ),
                ),
              ),
            if (isMe && !isLeader)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirmLeave(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    foregroundColor: AppColors.error,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Leave Trip',
                    style: AppTypography.buttonLg,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.bodyLg.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  void _confirmRemove(
    BuildContext context,
    TripProvider provider,
    TripMemberEntity member,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.name ?? 'this member'} from this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeMember(tripId, member.userId);
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, TripProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Trip'),
        content: const Text('Are you sure you want to leave this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.leaveTrip(tripId);
              Navigator.pop(ctx);
              context.go('/my-trips');
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
