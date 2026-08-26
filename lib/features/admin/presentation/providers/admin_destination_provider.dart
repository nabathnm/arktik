import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../../features/destination/domain/entities/destination_entity.dart';

enum AdminDestinationState { initial, loading, loaded, creating, updating, error }

class AdminDestinationProvider extends ChangeNotifier {
  final AdminRepository adminRepository;

  AdminDestinationProvider(this.adminRepository);

  AdminDestinationState _state = AdminDestinationState.initial;
  AdminDestinationState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(AdminDestinationState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AdminDestinationState.error;
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> createDestination({
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
    _setState(AdminDestinationState.creating);
    try {
      await adminRepository.createDestination(
        name: name,
        description: description,
        location: location,
        latitude: latitude,
        longitude: longitude,
        type: type,
        imageFile: imageFile,
        isActive: isActive,
        createdBy: createdBy,
      );
      _setState(AdminDestinationState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateDestinationStatus(String id, bool isActive) async {
    _setState(AdminDestinationState.updating);
    try {
      await adminRepository.updateDestinationStatus(id, isActive);
      _setState(AdminDestinationState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }
}
