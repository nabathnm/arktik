import 'dart:typed_data';
import '../entities/destination_entity.dart';

abstract class DestinationRepository {
  Future<List<DestinationEntity>> getAllDestinations();
  Future<List<DestinationEntity>> getAdminDestinations();

  Future<DestinationEntity> createDestination({
    required String name,
    required String description,
    required String location,
    required DestinationType type,
    required Uint8List imageBytes,
    required String imageName,
    required String createdBy,
  });

  Future<DestinationEntity> updateDestination(DestinationEntity destination);

  Future<void> deleteDestination(String destinationId);
  Future<DestinationEntity> getDestinationById(String destinationId);
}
