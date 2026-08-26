import '../repositories/invitation_repository.dart';

class LeaveInvitation {
  final InvitationRepository repository;

  LeaveInvitation(this.repository);

  Future<void> call(String invitationId) async {
    return await repository.leaveInvitation(invitationId);
  }
}
