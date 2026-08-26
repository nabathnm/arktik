import '../entities/invitation_entity.dart';
import '../repositories/invitation_repository.dart';

class JoinInvitation {
  final InvitationRepository repository;

  JoinInvitation(this.repository);

  Future<InvitationEntity> call(String code) async {
    return await repository.joinInvitation(code);
  }
}
