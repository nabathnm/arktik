import '../entities/invitation_entity.dart';
import '../repositories/invitation_repository.dart';

class CreateInvitation {
  final InvitationRepository repository;

  CreateInvitation(this.repository);

  Future<InvitationEntity> call({
    required int maxMembers,
    required DateTime expiresAt,
    required String tripId,
  }) async {
    return await repository.createInvitation(
      maxMembers: maxMembers,
      expiresAt: expiresAt,
      tripId: tripId,
    );
  }
}
