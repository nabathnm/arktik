import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member_entity.dart';
import '../../domain/entities/trip_summary_entity.dart';

abstract class TripRemoteDataSource {
  Future<TripEntity> createTrip({
    required String name,
    String? destinationId,
    required DateTime startDate,
    required DateTime endDate,
    required TripType type,
  });

  Future<List<TripSummaryEntity>> getMyTrips();

  Future<TripEntity> getTripById(String tripId);

  Future<List<TripMemberEntity>> getTripMembers(String tripId);

  Future<TripMemberEntity?> getTripLeader(String tripId);

  Future<TripMemberEntity?> getMyMembership(String tripId);

  Future<void> leaveTrip(String tripId);

  Future<void> removeTripMember({
    required String tripId,
    required String memberUserId,
  });

  Future<void> deleteTrip(String tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final SupabaseClient supabaseClient;

  TripRemoteDataSourceImpl(this.supabaseClient);

  TripType _parseType(String type) {
    switch (type) {
      case 'group':
        return TripType.group;
      case 'family':
        return TripType.family;
      case 'solo':
      default:
        return TripType.solo;
    }
  }

  TripStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return TripStatus.active;
      case 'ready':
        return TripStatus.ready;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      case 'draft':
      default:
        return TripStatus.draft;
    }
  }

  TripEntity _mapToEntity(Map<String, dynamic> data) {
    return TripEntity(
      id: data['id'],
      name: data['name'],
      destinationId: data['destination_id'],
      startDate: DateTime.parse(data['start_date']),
      endDate: DateTime.parse(data['end_date']),
      type: _parseType(data['type']),
      createdBy: data['created_by'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  @override
  Future<TripEntity> createTrip({
    required String name,
    String? destinationId,
    required DateTime startDate,
    required DateTime endDate,
    required TripType type,
  }) async {
    final response = await supabaseClient
        .from('trips')
        .insert({
          'name': name,
          'destination_id': destinationId,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'type': type.name,
          'created_by': supabaseClient.auth.currentUser!.id,
        })
        .select()
        .single();

    // After creating a trip, we also need to add the creator to trip_members as owner.
    // However, we can handle it at the database layer using a trigger, or do it here manually.
    // Let's do it manually here for simplicity to ensure they are joined.
    final tripId = response['id'];

    await supabaseClient.from('trip_members').insert({
      'trip_id': tripId,
      'user_id': supabaseClient.auth.currentUser!.id,
      'role': 'owner',
      'status': 'active',
    });

    if (type == TripType.group || type == TripType.family) {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final rnd = Random.secure();
      final part1 = String.fromCharCodes(
        Iterable.generate(
          4,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
        ),
      );
      final part2 = String.fromCharCodes(
        Iterable.generate(
          5,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
        ),
      );
      final code = '$part1-$part2';

      await supabaseClient.from('invitations').insert({
        'code': code,
        'max_members': 100,
        'expires_at': endDate.toUtc().toIso8601String(),
        'trip_id': tripId,
      });
    }

    return _mapToEntity(response);
  }

  @override
  Future<List<TripSummaryEntity>> getMyTrips() async {
    final currentUserId = supabaseClient.auth.currentUser!.id;
    final response = await supabaseClient
        .from('trip_members')
        .select('''
          role,
          trips (
            id,
            name,
            start_date,
            end_date,
            destinations (
              name
            ),
            trip_members (
              role,
              status,
              profiles (
                name,
                avatar_url
              )
            ),
            invitations (
              code
            )
          )
        ''')
        .eq('user_id', currentUserId)
        .eq('status', 'active');

    final summaries = (response as List).map((row) {
      final myRoleStr = row['role'] as String;
      final trip = row['trips'] as Map<String, dynamic>;
      
      final destinations = trip['destinations'];
      final destinationName = (destinations is Map) ? destinations['name'] as String? : null;
      
      final allMembers = (trip['trip_members'] as List?)?.where((m) => m['status'] == 'active').toList() ?? [];
      final leader = allMembers.firstWhere(
        (m) => m['role'] == 'owner',
        orElse: () => <String, dynamic>{},
      );
      final profiles = leader['profiles'];
      
      final invitations = trip['invitations'];
      String? code;
      if (invitations is List && invitations.isNotEmpty) {
        code = invitations.first['code'] as String?;
      } else if (invitations is Map) {
        code = invitations['code'] as String?;
      }

      return TripSummaryEntity(
        id: trip['id'],
        name: trip['name'],
        destinationName: destinationName,
        startDate: DateTime.parse(trip['start_date']),
        endDate: DateTime.parse(trip['end_date']),
        myRole: myRoleStr == 'owner' ? TripMemberRole.owner : TripMemberRole.member,
        leaderName: profiles != null ? profiles['name'] : null,
        leaderAvatarUrl: profiles != null ? profiles['avatar_url'] : null,
        memberCount: allMembers.length,
        invitationCode: code,
      );
    }).toList();

    summaries.sort((a, b) => a.startDate.compareTo(b.startDate));
    return summaries;
  }

  @override
  Future<TripEntity> getTripById(String tripId) async {
    final response = await supabaseClient
        .from('trips')
        .select()
        .eq('id', tripId)
        .single();
    return _mapToEntity(response);
  }

  @override
  Future<List<TripMemberEntity>> getTripMembers(String tripId) async {
    final response = await supabaseClient
        .from('trip_members')
        .select('*, profiles(name, avatar_url)')
        .eq('trip_id', tripId)
        .eq('status', 'active');

    return (response as List).map((e) => _mapToTripMemberEntity(e)).toList();
  }

  @override
  Future<TripMemberEntity?> getTripLeader(String tripId) async {
    final response = await supabaseClient
        .from('trip_members')
        .select('*, profiles(name, avatar_url)')
        .eq('trip_id', tripId)
        .eq('role', 'owner')
        .eq('status', 'active')
        .maybeSingle();

    if (response == null) return null;
    return _mapToTripMemberEntity(response);
  }

  @override
  Future<TripMemberEntity?> getMyMembership(String tripId) async {
    final response = await supabaseClient
        .from('trip_members')
        .select('*, profiles(name, avatar_url)')
        .eq('trip_id', tripId)
        .eq('user_id', supabaseClient.auth.currentUser!.id)
        .eq('status', 'active')
        .maybeSingle();

    if (response == null) return null;
    return _mapToTripMemberEntity(response);
  }

  @override
  Future<void> leaveTrip(String tripId) async {
    await supabaseClient
        .from('trip_members')
        .update({'status': 'left', 'left_at': DateTime.now().toIso8601String()})
        .eq('trip_id', tripId)
        .eq('user_id', supabaseClient.auth.currentUser!.id)
        .eq('role', 'member'); // Ensuring owners can't leave via this method
  }

  @override
  Future<void> removeTripMember({
    required String tripId,
    required String memberUserId,
  }) async {
    await supabaseClient
        .from('trip_members')
        .update({'status': 'left', 'left_at': DateTime.now().toIso8601String()})
        .eq('trip_id', tripId)
        .eq('user_id', memberUserId);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    // Delete related records first to avoid foreign key constraint errors
    await supabaseClient.from('trip_members').delete().eq('trip_id', tripId);

    await supabaseClient.from('invitations').delete().eq('trip_id', tripId);

    // Then delete the trip
    await supabaseClient.from('trips').delete().eq('id', tripId);
  }

  TripMemberEntity _mapToTripMemberEntity(Map<String, dynamic> data) {
    return TripMemberEntity(
      id: data['id'],
      tripId: data['trip_id'],
      userId: data['user_id'],
      role: data['role'] == 'owner'
          ? TripMemberRole.owner
          : TripMemberRole.member,
      joinedAt: DateTime.parse(data['joined_at']),
      name: data['profiles']?['name'],
      avatarUrl: data['profiles']?['avatar_url'],
    );
  }
}
