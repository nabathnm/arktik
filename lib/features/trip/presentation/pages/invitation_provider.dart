import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/entities/invitation_member_entity.dart';
import '../../domain/usecases/create_invitation.dart';
import '../../domain/usecases/get_invitation_by_code.dart';
import '../../domain/usecases/join_invitation.dart';
import '../../domain/usecases/leave_invitation.dart';
import '../../domain/usecases/close_invitation.dart';
import '../../domain/usecases/get_my_invitations.dart';
import '../../domain/repositories/invitation_repository.dart';

enum InvitationStateStatus {
  initial,
  loading,
  creating,
  joining,
  loaded,
  success,
  error,
}

class InvitationProvider extends ChangeNotifier {
  final CreateInvitation createInvitationUseCase;
  final GetInvitationByCode getInvitationByCodeUseCase;
  final JoinInvitation joinInvitationUseCase;
  final LeaveInvitation leaveInvitationUseCase;
  final CloseInvitation closeInvitationUseCase;
  final GetMyInvitations getMyInvitationsUseCase;
  final InvitationRepository repository; // Needed for getInvitationMembers

  InvitationProvider({
    required this.createInvitationUseCase,
    required this.getInvitationByCodeUseCase,
    required this.joinInvitationUseCase,
    required this.leaveInvitationUseCase,
    required this.closeInvitationUseCase,
    required this.getMyInvitationsUseCase,
    required this.repository,
  });

  InvitationStateStatus _status = InvitationStateStatus.initial;
  InvitationStateStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  InvitationEntity? _currentInvitation;
  InvitationEntity? get currentInvitation => _currentInvitation;

  List<InvitationEntity> _myInvitations = [];
  List<InvitationEntity> get myInvitations => _myInvitations;

  List<InvitationMemberEntity> _currentMembers = [];
  List<InvitationMemberEntity> get currentMembers => _currentMembers;

  void _setStatus(InvitationStateStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  void _mapExceptionToMessage(Object e) {
    String msg = 'An unexpected error occurred';
    if (e is PostgrestException) {
      if (e.message.contains('InvitationNotFound')) {
        msg = 'Invitation code tidak ditemukan';
      } else if (e.message.contains('InvitationExpired')) {
        msg = 'Invitation sudah expired';
      } else if (e.message.contains('InvitationClosed')) {
        msg = 'Invitation sudah ditutup';
      } else if (e.message.contains('InvitationFull')) {
        msg = 'Kapasitas invitation sudah penuh';
      } else if (e.message.contains('AlreadyJoined')) {
        msg = 'Kamu sudah bergabung';
      } else {
        msg = e.message;
      }
    } else if (e is Exception) {
      msg = e.toString().replaceAll('Exception: ', '');
    }
    _setStatus(InvitationStateStatus.error, error: msg);
  }

  Future<void> loadMyInvitations() async {
    _setStatus(InvitationStateStatus.loading);
    try {
      _myInvitations = await getMyInvitationsUseCase();
      _setStatus(InvitationStateStatus.loaded);
    } catch (e) {
      _mapExceptionToMessage(e);
    }
  }

  Future<void> loadInvitationDetails(String invitationId) async {
    _setStatus(InvitationStateStatus.loading);
    try {
      // Find in local list first or fetch it
      _currentInvitation = _myInvitations.cast<InvitationEntity?>().firstWhere(
        (inv) => inv?.id == invitationId,
        orElse: () => null,
      );

      // Load members
      _currentMembers = await repository.getInvitationMembers(invitationId);

      _setStatus(InvitationStateStatus.loaded);
    } catch (e) {
      _mapExceptionToMessage(e);
    }
  }

  Future<bool> createNewInvitation({
    required int maxMembers,
    required DateTime expiresAt,
    required String tripId,
  }) async {
    _setStatus(InvitationStateStatus.creating);
    try {
      final newInv = await createInvitationUseCase(
        maxMembers: maxMembers,
        expiresAt: expiresAt,
        tripId: tripId,
      );
      _currentInvitation = newInv;
      _myInvitations.insert(0, newInv);
      _setStatus(InvitationStateStatus.success);
      return true;
    } catch (e) {
      _mapExceptionToMessage(e);
      return false;
    }
  }

  Future<InvitationEntity?> previewInvitation(String code) async {
    _setStatus(InvitationStateStatus.loading);
    try {
      final inv = await getInvitationByCodeUseCase(code);
      if (inv == null) {
        _setStatus(
          InvitationStateStatus.error,
          error: 'Invitation code tidak ditemukan',
        );
        return null;
      }
      _setStatus(InvitationStateStatus.loaded);
      return inv;
    } catch (e) {
      _mapExceptionToMessage(e);
      return null;
    }
  }

  Future<bool> join(String code) async {
    _setStatus(InvitationStateStatus.joining);
    try {
      final inv = await joinInvitationUseCase(code);
      _currentInvitation = inv;
      _setStatus(InvitationStateStatus.success);
      return true;
    } catch (e) {
      _mapExceptionToMessage(e);
      return false;
    }
  }

  Future<bool> leave(String invitationId) async {
    _setStatus(InvitationStateStatus.loading);
    try {
      await leaveInvitationUseCase(invitationId);
      _myInvitations.removeWhere((i) => i.id == invitationId);
      _setStatus(InvitationStateStatus.success);
      return true;
    } catch (e) {
      _mapExceptionToMessage(e);
      return false;
    }
  }

  Future<bool> close(String invitationId) async {
    _setStatus(InvitationStateStatus.loading);
    try {
      await closeInvitationUseCase(invitationId);
      // Update local status
      final index = _myInvitations.indexWhere((i) => i.id == invitationId);
      if (index != -1) {
        final inv = _myInvitations[index];
        _myInvitations[index] = InvitationEntity(
          id: inv.id,
          code: inv.code,
          tripId: inv.tripId,
          status: InvitationStatus.closed,
          maxMembers: inv.maxMembers,
          expiresAt: inv.expiresAt,
          createdAt: inv.createdAt,
          updatedAt: DateTime.now(),
        );
        _currentInvitation = _myInvitations[index];
      }
      _setStatus(InvitationStateStatus.success);
      return true;
    } catch (e) {
      _mapExceptionToMessage(e);
      return false;
    }
  }
}
