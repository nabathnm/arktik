import 'package:equatable/equatable.dart';

enum TripMemberRole { owner, member }

class TripMemberEntity extends Equatable {
  final String id;
  final String tripId;
  final String userId;
  final TripMemberRole role;
  final DateTime joinedAt;

  final String? name;
  final String? avatarUrl;

  const TripMemberEntity({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    tripId,
    userId,
    role,
    joinedAt,
    name,
    avatarUrl,
  ];
}
