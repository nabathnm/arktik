import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member_entity.dart';
import '../../domain/entities/trip_summary_entity.dart';
import '../../domain/entities/trip_itinerary_entity.dart';
import '../../../destination/domain/entities/destination_entity.dart';

abstract class TripRemoteDataSource {
  Future<TripEntity> createTrip({
    required String name,
    String? destinationId,
    DateTime? startDate,
    DateTime? endDate,
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

  Future<List<TripItineraryEntity>> getTripItineraries(String tripId);

  Future<TripItineraryEntity> addDestinationToTrip({
    required String tripId,
    required String destinationId,
    required DateTime visitDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  });

  Future<void> removeDestinationFromTrip(String itineraryId);
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
      case 'planning':
        return TripStatus.planning;
      case 'matching':
        return TripStatus.matching;
      case 'date_selected':
        return TripStatus.date_selected;
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
      startDate: data['start_date'] != null
          ? DateTime.parse(data['start_date'])
          : null,
      endDate: data['end_date'] != null
          ? DateTime.parse(data['end_date'])
          : null,
      selectedDate: data['selected_date'] != null
          ? DateTime.parse(data['selected_date'])
          : null,
      type: _parseType(data['type']),
      status: _parseStatus(data['status'] ?? 'draft'),
      createdBy: data['created_by'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  @override
  Future<TripEntity> createTrip({
    required String name,
    String? destinationId,
    DateTime? startDate,
    DateTime? endDate,
    required TripType type,
  }) async {
    final Map<String, dynamic> insertData = {
      'name': name,
      'destination_id': destinationId,
      'type': type.name,
      'created_by': supabaseClient.auth.currentUser!.id,
      'status': 'draft', // or matching depending on logic
    };

    if (startDate != null) {
      insertData['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      insertData['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    final response = await supabaseClient
        .from('trips')
        .insert(insertData)
        .select()
        .single();

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
        'expires_at': endDate != null
            ? endDate.toUtc().toIso8601String()
            : DateTime.now()
                  .add(const Duration(days: 30))
                  .toUtc()
                  .toIso8601String(),
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
            selected_date,
            status,
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
      final destinationName = (destinations is Map)
          ? destinations['name'] as String?
          : null;

      final allMembers =
          (trip['trip_members'] as List?)
              ?.where((m) => m['status'] == 'active')
              .toList() ??
          [];
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
        startDate: trip['start_date'] != null
            ? DateTime.parse(trip['start_date'])
            : null,
        endDate: trip['end_date'] != null
            ? DateTime.parse(trip['end_date'])
            : null,
        selectedDate: trip['selected_date'] != null
            ? DateTime.parse(trip['selected_date'])
            : null,
        status: _parseStatus(trip['status'] ?? 'draft'),
        myRole: myRoleStr == 'owner'
            ? TripMemberRole.owner
            : TripMemberRole.member,
        leaderName: profiles != null ? profiles['name'] : null,
        leaderAvatarUrl: profiles != null ? profiles['avatar_url'] : null,
        memberCount: allMembers.length,
        invitationCode: code,
      );
    }).toList();

    summaries.sort((a, b) {
      final aDate = a.selectedDate ?? a.startDate ?? DateTime.now();
      final bDate = b.selectedDate ?? b.startDate ?? DateTime.now();
      return aDate.compareTo(bDate);
    });
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
    // Order matters here! Delete trip_members last so RLS policies on other tables
    // that check for trip membership don't fail.
    await supabaseClient.from('invitations').delete().eq('trip_id', tripId);
    await supabaseClient
        .from('trip_schedule_candidates')
        .delete()
        .eq('trip_id', tripId);
    await supabaseClient
        .from('trip_itineraries')
        .delete()
        .eq('trip_id', tripId);
    await supabaseClient.from('trip_members').delete().eq('trip_id', tripId);

    // Then delete the trip and return the deleted rows to verify
    final deletedTrips = await supabaseClient
        .from('trips')
        .delete()
        .eq('id', tripId)
        .select();

    if (deletedTrips.isEmpty) {
      throw Exception(
        'Gagal menghapus trip di database. Pastikan kebijakan RLS (Row Level Security) di Supabase mengizinkan operasi DELETE untuk tabel trips dan relasinya.',
      );
    }
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

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  @override
  Future<List<TripItineraryEntity>> getTripItineraries(String tripId) async {
    final response = await supabaseClient
        .from('trip_itineraries')
        .select('*, destinations(*)')
        .eq('trip_id', tripId)
        .order('order_index', ascending: true);

    return (response as List).map((row) {
      final destData = row['destinations'];
      DestinationEntity? destination;
      if (destData != null) {
        DestinationType parsedType = DestinationType.tourism;
        if (destData['type'] == 'culinary')
          parsedType = DestinationType.culinary;

        destination = DestinationEntity(
          id: destData['id'],
          name: destData['name'],
          description: destData['description'],
          location: destData['location'],
          type: parsedType,
          imageUrl: destData['image_url'],
          createdBy: destData['created_by'],
        );
      }

      return TripItineraryEntity(
        id: row['id'],
        tripId: row['trip_id'],
        destinationId: row['destination_id'],
        destination: destination,
        visitDate: DateTime.parse(row['visit_date']),
        startTime: _parseTime(row['start_time']),
        endTime: _parseTime(row['end_time']),
        orderIndex: row['order_index'] ?? 0,
        createdAt: DateTime.parse(row['created_at']),
      );
    }).toList();
  }

  @override
  Future<TripItineraryEntity> addDestinationToTrip({
    required String tripId,
    required String destinationId,
    required DateTime visitDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    // Get current max order_index
    final maxOrderResponse = await supabaseClient
        .from('trip_itineraries')
        .select('order_index')
        .eq('trip_id', tripId)
        .eq('visit_date', visitDate.toIso8601String().split('T')[0])
        .order('order_index', ascending: false)
        .limit(1)
        .maybeSingle();

    int nextOrderIndex = 0;
    if (maxOrderResponse != null && maxOrderResponse['order_index'] != null) {
      nextOrderIndex = (maxOrderResponse['order_index'] as int) + 1;
    }

    final insertData = {
      'trip_id': tripId,
      'destination_id': destinationId,
      'visit_date': visitDate.toIso8601String().split('T')[0],
      'start_time': _formatTime(startTime),
      'end_time': _formatTime(endTime),
      'order_index': nextOrderIndex,
    };

    final response = await supabaseClient
        .from('trip_itineraries')
        .insert(insertData)
        .select('*, destinations(*)')
        .single();

    final destData = response['destinations'];
    DestinationEntity? destination;
    if (destData != null) {
      DestinationType parsedType = DestinationType.tourism;
      if (destData['type'] == 'culinary') parsedType = DestinationType.culinary;

      destination = DestinationEntity(
        id: destData['id'],
        name: destData['name'],
        description: destData['description'],
        location: destData['location'],
        type: parsedType,
        imageUrl: destData['image_url'],
        createdBy: destData['created_by'],
      );
    }

    return TripItineraryEntity(
      id: response['id'],
      tripId: response['trip_id'],
      destinationId: response['destination_id'],
      destination: destination,
      visitDate: DateTime.parse(response['visit_date']),
      startTime: _parseTime(response['start_time']),
      endTime: _parseTime(response['end_time']),
      orderIndex: response['order_index'] ?? 0,
      createdAt: DateTime.parse(response['created_at']),
    );
  }

  @override
  Future<void> removeDestinationFromTrip(String itineraryId) async {
    await supabaseClient
        .from('trip_itineraries')
        .delete()
        .eq('id', itineraryId);
  }
}
