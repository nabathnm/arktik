import '../../domain/entities/invitation_entity.dart';

class InvitationModel extends InvitationEntity {
  const InvitationModel({
    required super.id,
    required super.code,
    required super.tripId,
    required super.status,
    required super.maxMembers,
    required super.expiresAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] as String,
      code: json['code'] as String,
      tripId: json['trip_id'] as String,
      status: _parseStatus(json['status'] as String),
      maxMembers: json['max_members'] as int,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static InvitationStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'expired':
        return InvitationStatus.expired;
      case 'closed':
        return InvitationStatus.closed;
      case 'active':
      default:
        return InvitationStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'trip_id': tripId,
      'status': status.name,
      'max_members': maxMembers,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
