import 'package:equatable/equatable.dart';
import 'trip_entity.dart';
import 'trip_member_entity.dart';

class TripSummaryEntity extends Equatable {
  final String id;
  final String name;
  final String? destinationName;
  final DateTime startDate;
  final DateTime endDate;
  final TripMemberRole myRole;
  final String? leaderName;
  final String? leaderAvatarUrl;
  final int memberCount;
  final String? invitationCode;

  const TripSummaryEntity({
    required this.id,
    required this.name,
    this.destinationName,
    required this.startDate,
    required this.endDate,
    required this.myRole,
    this.leaderName,
    this.leaderAvatarUrl,
    required this.memberCount,
    this.invitationCode,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    destinationName,
    startDate,
    endDate,
    myRole,
    leaderName,
    leaderAvatarUrl,
    memberCount,
    invitationCode,
  ];
}
