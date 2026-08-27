import 'package:equatable/equatable.dart';

class CandidateDateEntity extends Equatable {
  final DateTime date;
  final int availableMembersCount;
  final int totalMembersCount;

  const CandidateDateEntity({
    required this.date,
    required this.availableMembersCount,
    required this.totalMembersCount,
  });

  double get availabilityPercentage =>
      totalMembersCount == 0 ? 0 : (availableMembersCount / totalMembersCount) * 100;

  @override
  List<Object?> get props => [
    date,
    availableMembersCount,
    totalMembersCount,
  ];
}
