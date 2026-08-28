import '../entities/invitation_entity.dart';
import '../entities/invitation_member_entity.dart';

abstract class InvitationRepository {
  Future<InvitationEntity> createInvitation({
    required int maxMembers,
    required DateTime expiresAt,
    required String tripId,
  });

  Future<InvitationEntity?> getInvitationByCode(String code);

  Future<InvitationEntity> joinInvitation(String code);

  Future<void> leaveInvitation(String invitationId);

  Future<void> closeInvitation(String invitationId);

  Future<List<InvitationEntity>> getMyInvitations();

  Future<List<InvitationMemberEntity>> getInvitationMembers(
    String invitationId,
  );
}
