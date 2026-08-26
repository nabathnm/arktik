import 'package:equatable/equatable.dart';

enum InvitationMemberStatus { active, left }

class InvitationMemberEntity extends Equatable {
  final String id;
  final String invitationId;
  final String userId;
  final DateTime joinedAt;
  final InvitationMemberStatus status;

  final String? userName;
  final String? userAvatarUrl;

  const InvitationMemberEntity({
    required this.id,
    required this.invitationId,
    required this.userId,
    required this.joinedAt,
    required this.status,
    this.userName,
    this.userAvatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    invitationId,
    userId,
    joinedAt,
    status,
    userName,
    userAvatarUrl,
  ];
}
