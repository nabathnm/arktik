import 'package:equatable/equatable.dart';

enum InvitationStatus { active, expired, closed }

class InvitationEntity extends Equatable {
  final String id;
  final String code;
  final String tripId;
  final InvitationStatus status;
  final int maxMembers;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvitationEntity({
    required this.id,
    required this.code,
    required this.tripId,
    required this.status,
    required this.maxMembers,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    tripId,
    status,
    maxMembers,
    expiresAt,
    createdAt,
    updatedAt,
  ];
}
