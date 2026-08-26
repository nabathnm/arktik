import '../../domain/entities/invitation_member_entity.dart';

class InvitationMemberModel extends InvitationMemberEntity {
  const InvitationMemberModel({
    required super.id,
    required super.invitationId,
    required super.userId,
    required super.joinedAt,
    required super.status,
    super.userName,
    super.userAvatarUrl,
  });

  factory InvitationMemberModel.fromJson(Map<String, dynamic> json) {
    // If the query includes a join with profiles table, we map the nested data
    String? name;
    String? avatar;
    if (json['profiles'] != null) {
      name = json['profiles']['name'] as String?;
      avatar = json['profiles']['avatar_url'] as String?;
    }

    return InvitationMemberModel(
      id: json['id'] as String,
      invitationId: json['invitation_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      status: _parseStatus(json['status'] as String),
      userName: name,
      userAvatarUrl: avatar,
    );
  }

  static InvitationMemberStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'left':
        return InvitationMemberStatus.left;
      case 'active':
      default:
        return InvitationMemberStatus.active;
    }
  }
}
