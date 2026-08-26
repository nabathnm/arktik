import '../repositories/invitation_repository.dart';

class CloseInvitation {
  final InvitationRepository repository;

  CloseInvitation(this.repository);

  Future<void> call(String invitationId) async {
    return await repository.closeInvitation(invitationId);
  }
}
