import '../entities/invitation_entity.dart';
import '../repositories/invitation_repository.dart';

class CreateInvitation {
  final InvitationRepository repository;

  CreateInvitation(this.repository);

  Future<InvitationEntity> call({
    required String title,
    String? description,
    required int maxMembers,
    required DateTime expiresAt,
    String? tripId,
  }) async {
    return await repository.createInvitation(
      title: title,
      description: description,
      maxMembers: maxMembers,
      expiresAt: expiresAt,
      tripId: tripId,
    );
  }
}
