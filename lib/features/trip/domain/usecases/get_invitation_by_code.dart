import '../entities/invitation_entity.dart';
import '../repositories/invitation_repository.dart';

class GetInvitationByCode {
  final InvitationRepository repository;

  GetInvitationByCode(this.repository);

  Future<InvitationEntity?> call(String code) async {
    return await repository.getInvitationByCode(code);
  }
}
