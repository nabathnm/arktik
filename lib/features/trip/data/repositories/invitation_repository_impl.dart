import '../../domain/entities/invitation_entity.dart';
import '../../domain/entities/invitation_member_entity.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../datasources/invitation_remote_datasource.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  final InvitationRemoteDataSource remoteDataSource;

  InvitationRepositoryImpl(this.remoteDataSource);

  @override
  Future<InvitationEntity> createInvitation({
    required int maxMembers,
    required DateTime expiresAt,
    required String tripId,
  }) async {
    return await remoteDataSource.createInvitation(
      maxMembers: maxMembers,
      expiresAt: expiresAt,
      tripId: tripId,
    );
  }

  @override
  Future<InvitationEntity?> getInvitationByCode(String code) async {
    return await remoteDataSource.getInvitationByCode(code);
  }

  @override
  Future<InvitationEntity> joinInvitation(String code) async {
    return await remoteDataSource.joinInvitation(code);
  }

  @override
  Future<void> leaveInvitation(String invitationId) async {
    await remoteDataSource.leaveInvitation(invitationId);
  }

  @override
  Future<void> closeInvitation(String invitationId) async {
    await remoteDataSource.closeInvitation(invitationId);
  }

  @override
  Future<List<InvitationEntity>> getMyInvitations() async {
    return await remoteDataSource.getMyInvitations();
  }

  @override
  Future<List<InvitationMemberEntity>> getInvitationMembers(
    String invitationId,
  ) async {
    return await remoteDataSource.getInvitationMembers(invitationId);
  }
}
