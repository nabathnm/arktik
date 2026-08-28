import 'package:equatable/equatable.dart';
import 'trip_entity.dart';
import 'trip_member_entity.dart';

class TripSummaryEntity extends Equatable {
  final String id;
  final String name;
  final String? destinationName;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? selectedDate;
  final TripStatus status;
  final TripMemberRole myRole;
  final String? leaderName;
  final String? leaderAvatarUrl;
  final int memberCount;
  final String? invitationCode;

  const TripSummaryEntity({
    required this.id,
    required this.name,
    this.destinationName,
    this.startDate,
    this.endDate,
    this.selectedDate,
    required this.status,
    required this.myRole,
    this.leaderName,
    this.leaderAvatarUrl,
    required this.memberCount,
    this.invitationCode,
  });

  int get duration {
    if (startDate != null && endDate != null) {
      return endDate!.difference(startDate!).inDays + 1;
    }
    return 0;
  }

  double get progress {
    if (startDate == null || endDate == null) return 0.0;
    
    final now = DateTime.now();
    if (now.isAfter(endDate!) || now.isAtSameMomentAs(endDate!)) {
      return 1.0;
    } else if (now.isAfter(startDate!)) {
      final totalDuration = duration;
      return totalDuration > 0
          ? now.difference(startDate!).inDays / totalDuration
          : 0.0;
    }
    return 0.0;
  }
  
  int get progressPercent => (progress.clamp(0.0, 1.0) * 100).toInt();

  @override
  List<Object?> get props => [
    id,
    name,
    destinationName,
    startDate,
    endDate,
    selectedDate,
    status,
    myRole,
    leaderName,
    leaderAvatarUrl,
    memberCount,
    invitationCode,
  ];
}
