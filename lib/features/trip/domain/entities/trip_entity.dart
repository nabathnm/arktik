import 'package:equatable/equatable.dart';

enum TripType { solo, group, family }

enum TripStatus { draft, matching, dateSelected, planning, active, completed, cancelled }

class TripEntity extends Equatable {
  final String id;
  final String name;
  final String? destinationId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? selectedDate;
  final TripType type;
  final TripStatus status;
  final String createdBy;
  final DateTime createdAt;
  final List<bool>? checklistStatus;

  const TripEntity({
    required this.id,
    required this.name,
    this.destinationId,
    this.startDate,
    this.endDate,
    this.selectedDate,
    required this.type,
    this.status = TripStatus.draft,
    required this.createdBy,
    required this.createdAt,
    this.checklistStatus,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    destinationId,
    startDate,
    endDate,
    selectedDate,
    type,
    status,
    createdBy,
    createdAt,
    checklistStatus,
  ];
}
