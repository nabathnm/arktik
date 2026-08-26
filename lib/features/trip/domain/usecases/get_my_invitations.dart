import '../entities/invitation_entity.dart';
import '../repositories/invitation_repository.dart';

class GetMyInvitations {
  final InvitationRepository repository;

  GetMyInvitations(this.repository);

  Future<List<InvitationEntity>> call() async {
    return await repository.getMyInvitations();
  }
}
