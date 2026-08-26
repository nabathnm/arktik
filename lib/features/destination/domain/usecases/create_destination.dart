import 'dart:typed_data';
import 'package:rantau/features/destination/domain/repositories/destination_repository.dart';
import '../entities/destination_entity.dart';

class CreateDestination {
  final DestinationRepository repository;

  CreateDestination(this.repository);

  Future<DestinationEntity> call({
    required String name,
    required String description,
    required String location,
    required DestinationType type,
    required Uint8List imageBytes,
    required String imageName,
    required String createdBy,
  }) {
    return repository.createDestination(
      name: name,
      description: description,
      location: location,
      type: type,
      imageBytes: imageBytes,
      imageName: imageName,
      createdBy: createdBy,
    );
  }
}
