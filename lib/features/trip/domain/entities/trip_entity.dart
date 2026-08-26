import 'package:equatable/equatable.dart';

enum TripType { solo, group, family }

enum TripStatus { draft, active, ready, completed, cancelled }

class TripEntity extends Equatable {
  final String id;
  final String name;
  final String? destinationId;
  final DateTime startDate;
  final DateTime endDate;
  final TripType type;
  final String createdBy;
  final DateTime createdAt;

  const TripEntity({
    required this.id,
    required this.name,
    this.destinationId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    destinationId,
    startDate,
    endDate,
    type,
    createdBy,
    createdAt,
  ];
}
