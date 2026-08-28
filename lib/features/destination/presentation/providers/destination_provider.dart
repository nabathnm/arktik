import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rantau/features/destination/domain/repositories/destination_repository.dart';

import '../../domain/entities/destination_entity.dart';

enum DestinationState {
  initial,
  loading,
  loaded,
  empty,
  creating,
  updating,
  deleting,
  error,
}

class DestinationProvider extends ChangeNotifier {
  final DestinationRepository _repository;

  DestinationProvider({required this._repository});

  // ============================================================
  // STATE
  // ============================================================

  DestinationState _state = DestinationState.initial;
  DestinationState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ============================================================
  // DESTINATIONS
  // ============================================================

  List<DestinationEntity> _destinations = [];

  List<DestinationEntity> get destinations => _destinations;

  // ============================================================
  // FILTER & SEARCH
  // ============================================================

  String _selectedCategory = 'Semua';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool get isSearching => _searchQuery.isNotEmpty;

  // ============================================================
  // DISPLAYED DESTINATIONS
  // ============================================================

  List<DestinationEntity> get displayedDestinations {
    return _destinations.where((destination) {
      // ----------------------------------------------------------
      // Category Filter
      // ----------------------------------------------------------

      bool matchesCategory = true;

      if (_selectedCategory == 'Wisata') {
        matchesCategory = destination.type == DestinationType.tourism;
      } else if (_selectedCategory == 'Kuliner') {
        matchesCategory = destination.type == DestinationType.culinary;
      }

      // ----------------------------------------------------------
      // Search Filter
      // ----------------------------------------------------------

      bool matchesSearch = true;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();

        matchesSearch =
            destination.name.toLowerCase().contains(query) ||
            destination.location.toLowerCase().contains(query) ||
            destination.description.toLowerCase().contains(query);
      }

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ============================================================
  // GET DESTINATIONS
  // ============================================================

  Future<void> fetchDestinations() async {
    _state = DestinationState.loading;
    _errorMessage = '';

    notifyListeners();

    try {
      _destinations = await _repository.getAllDestinations();

      if (_destinations.isEmpty) {
        _state = DestinationState.empty;
      } else {
        _state = DestinationState.loaded;
      }
    } catch (e) {
      _state = DestinationState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // ============================================================
  // CREATE DESTINATION
  // ============================================================

  Future<bool> addDestination({
    required String name,
    required String description,
    required String location,
    required DestinationType type,
    required Uint8List imageBytes,
    required String imageName,
    required String createdBy,
  }) async {
    _state = DestinationState.creating;
    _errorMessage = '';

    notifyListeners();

    try {
      final newDestination = await _repository.createDestination(
        name: name,
        description: description,
        location: location,
        type: type,
        imageBytes: imageBytes,
        imageName: imageName,
        createdBy: createdBy,
      );

      _destinations.insert(0, newDestination);

      _state = DestinationState.loaded;

      notifyListeners();

      return true;
    } catch (e) {
      _state = DestinationState.error;
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // UPDATE DESTINATION
  // ============================================================

  Future<bool> editDestination(DestinationEntity destination) async {
    _state = DestinationState.updating;
    _errorMessage = '';

    notifyListeners();

    try {
      final updatedDestination = await _repository.updateDestination(
        destination,
      );

      final index = _destinations.indexWhere(
        (destination) => destination.id == updatedDestination.id,
      );

      if (index != -1) {
        _destinations[index] = updatedDestination;
      }

      _state = DestinationState.loaded;

      notifyListeners();

      return true;
    } catch (e) {
      _state = DestinationState.error;
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // DELETE DESTINATION
  // ============================================================

  Future<bool> removeDestination(String destinationId) async {
    _state = DestinationState.deleting;
    _errorMessage = '';

    notifyListeners();

    try {
      await _repository.deleteDestination(destinationId);

      _destinations.removeWhere(
        (destination) => destination.id == destinationId,
      );

      if (_destinations.isEmpty) {
        _state = DestinationState.empty;
      } else {
        _state = DestinationState.loaded;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _state = DestinationState.error;
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // GET DESTINATION BY ID
  // ============================================================

  Future<DestinationEntity?> getDestinationById(String destinationId) async {
    try {
      return await _repository.getDestinationById(destinationId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();

      return null;
    }
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void setCategory(String category) {
    if (_selectedCategory == category) return;

    _selectedCategory = category;

    _updateFilteredState();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void search(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;

    _updateFilteredState();
  }

  // ============================================================
  // UPDATE FILTERED STATE
  // ============================================================

  void _updateFilteredState() {
    if (displayedDestinations.isEmpty) {
      _state = DestinationState.empty;
    } else {
      _state = DestinationState.loaded;
    }

    notifyListeners();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void clearSearch() {
    if (_searchQuery.isEmpty) return;

    _searchQuery = '';

    _updateFilteredState();
  }

  // ============================================================
  // RESET FILTER
  // ============================================================

  void resetFilter() {
    _selectedCategory = 'Semua';
    _searchQuery = '';

    _updateFilteredState();
  }
}
