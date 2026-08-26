import 'dart:typed_data';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/destination_entity.dart';
import '../../domain/repositories/destination_repository.dart';

import '../datasources/destination_remote_datasource.dart';

class DestinationRepositoryImpl implements DestinationRepository {
  final DestinationRemoteDatasource destinationRemoteDatasource;

  DestinationRepositoryImpl({required this.destinationRemoteDatasource});

  // EKSPLOR
  @override
  Future<List<DestinationEntity>> getAllDestinations() async {
    try {
      return await destinationRemoteDatasource.getAllDestinations();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Mencari destinasi berdasarkan nama atau lokasi
  Future<List<DestinationEntity>> searchDestinations(String query) async {
    try {
      final all = await destinationRemoteDatasource.getAllDestinations();
      final lowerQuery = query.toLowerCase();

      return all.where((destination) {
        return destination.name.toLowerCase().contains(lowerQuery) ||
            destination.location.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ADMIN
  Future<List<DestinationEntity>> getAdminDestinations() async {
    try {
      return await destinationRemoteDatasource.getAllDestinations();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Membuat destinasi baru
  Future<DestinationEntity> createDestination({
    required String name,
    required String description,
    required String location,
    required DestinationType type,
    required Uint8List imageBytes,
    required String imageName,
    required String createdBy,
  }) async {
    try {
      return await destinationRemoteDatasource.createDestination(
        name: name,
        description: description,
        location: location,
        type: type,
        imageBytes: imageBytes,
        imageName: imageName,
        createdBy: createdBy,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Update destinasi
  Future<DestinationEntity> updateDestination(
    DestinationEntity destination,
  ) async {
    try {
      return await destinationRemoteDatasource.updateDestination(destination);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Menghapus destinasi
  Future<void> deleteDestination(String destinationId) async {
    try {
      await destinationRemoteDatasource.deleteDestination(destinationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DestinationEntity> getDestinationById(String destinationId) async {
    try {
      return await destinationRemoteDatasource.getDestinationById(
        destinationId,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
