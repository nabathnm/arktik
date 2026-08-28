import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invitation_model.dart';
import '../models/invitation_member_model.dart';

abstract class InvitationRemoteDataSource {
  Future<InvitationModel> createInvitation({
    required int maxMembers,
    required DateTime expiresAt,
    required String tripId,
  });
  Future<InvitationModel?> getInvitationByCode(String code);
  Future<InvitationModel> joinInvitation(String code);
  Future<void> leaveInvitation(String invitationId);
  Future<void> closeInvitation(String invitationId);
  Future<List<InvitationModel>> getMyInvitations();
  Future<List<InvitationMemberModel>> getInvitationMembers(String invitationId);
}

class InvitationRemoteDataSourceImpl implements InvitationRemoteDataSource {
  final SupabaseClient supabase;

  InvitationRemoteDataSourceImpl(this.supabase);

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluded I, O, 0, 1
    final rnd = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  @override
  Future<InvitationModel> createInvitation({
    required int maxMembers,
    required DateTime expiresAt,
    required String tripId,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    String code = _generateCode();

    final insertData = {
      'code': code,
      'trip_id': tripId,
      'max_members': maxMembers,
      'expires_at': expiresAt.toUtc().toIso8601String(),
    };

    final data = await supabase
        .from('invitations')
        .insert(insertData)
        .select()
        .single();

    return InvitationModel.fromJson(data);
  }

  @override
  Future<InvitationModel?> getInvitationByCode(String code) async {
    final normalizedCode = code.trim().toUpperCase();
    final data = await supabase
        .from('invitations')
        .select()
        .eq('code', normalizedCode)
        .maybeSingle();

    if (data == null) return null;
    return InvitationModel.fromJson(data);
  }

  @override
  Future<InvitationModel> joinInvitation(String code) async {
    final normalizedCode = code.trim().toUpperCase();

    // Call the RPC function (Runs as SECURITY DEFINER to bypass RLS)
    final response = await supabase.rpc(
      'join_trip_with_code',
      params: {'p_code': normalizedCode},
    );

    // If success, fetch the full invitation data
    final data = await supabase
        .from('invitations')
        .select()
        .eq('code', normalizedCode)
        .single();

    return InvitationModel.fromJson(data);
  }

  @override
  Future<void> leaveInvitation(String invitationId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await supabase
        .from('invitation_members')
        .update({'status': 'left'})
        .eq('invitation_id', invitationId)
        .eq('user_id', userId);
  }

  @override
  Future<void> closeInvitation(String invitationId) async {
    await supabase
        .from('invitations')
        .update({'status': 'closed'})
        .eq('id', invitationId);
  }

  @override
  Future<List<InvitationModel>> getMyInvitations() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Get invitations created by the user OR where the user is an active member
    final data = await supabase
        .from('invitations')
        .select('*, invitation_members!inner(user_id, status)')
        .or(
          'created_by.eq.$userId,and(invitation_members.user_id.eq.$userId,invitation_members.status.eq.active)',
        )
        .order('created_at', ascending: false);

    // We filter unique invitations because the join might duplicate rows
    // if the creator is also somehow a member, though they shouldn't be by default.
    final List<InvitationModel> result = [];
    final Set<String> seenIds = {};

    for (var row in data as List<dynamic>) {
      if (!seenIds.contains(row['id'])) {
        seenIds.add(row['id']);
        result.add(InvitationModel.fromJson(row));
      }
    }

    return result;
  }

  @override
  Future<List<InvitationMemberModel>> getInvitationMembers(
    String invitationId,
  ) async {
    // Join with profiles to get the user's name and avatar
    final data = await supabase
        .from('invitation_members')
        .select('*, profiles(name, avatar_url)')
        .eq('invitation_id', invitationId)
        .eq('status', 'active');

    return (data as List<dynamic>)
        .map((json) => InvitationMemberModel.fromJson(json))
        .toList();
  }
}
