import 'dart:io';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';
import '../../../../features/destination/domain/entities/destination_entity.dart';
import '../../../../features/destination/data/models/destination_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
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
  }) async {
    try {
      final response = await remoteDataSource.createDestination(
        name: name,
        description: description,
        location: location,
        latitude: latitude,
        longitude: longitude,
        type: type == DestinationType.culinary ? 'culinary' : 'tourism',
        imageFile: imageFile,
        isActive: isActive,
        createdBy: createdBy,
      );

      return DestinationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateDestinationStatus(String id, bool isActive) async {
    try {
      await remoteDataSource.updateDestinationStatus(id, isActive);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
