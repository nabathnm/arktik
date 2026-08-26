import 'dart:io';
import '../../../../features/destination/domain/entities/destination_entity.dart';

abstract class AdminRepository {
  Future<DestinationEntity> createDestination({
    required String name,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required DestinationType type,
    required File imageFile,
    required bool isActive,
    required String createdBy,
  });

  Future<void> updateDestinationStatus(String id, bool isActive);
}
