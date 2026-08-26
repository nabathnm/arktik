import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/destination_entity.dart';
import '../models/destination_model.dart';

class DestinationRemoteDatasource {
  final SupabaseClient supabaseClient;

  DestinationRemoteDatasource(this.supabaseClient);

  // GET ALL DESTINATIONS
  Future<List<DestinationEntity>> getAllDestinations() async {
    try {
      final response = await supabaseClient
          .from('destinations')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(
        response,
      ).map<DestinationEntity>((e) => DestinationModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // SEARCH DESTINATIONS
  Future<List<DestinationEntity>> searchDestinations(String query) async {
    try {
      final all = await getAllDestinations();

      final lowerQuery = query.toLowerCase().trim();

      if (lowerQuery.isEmpty) {
        return all;
      }

      return all.where((destination) {
        return destination.name.toLowerCase().contains(lowerQuery) ||
            destination.location.toLowerCase().contains(lowerQuery) ||
            destination.description.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // CREATE DESTINATION
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
      // 1. Generate unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$imageName';

      // 2. Upload image
      await supabaseClient.storage
          .from('destinations')
          .uploadBinary(fileName, imageBytes);

      // 3. Get public image URL
      final imageUrl = supabaseClient.storage
          .from('destinations')
          .getPublicUrl(fileName);

      // 4. Prepare database data
      final destinationData = {
        'name': name,
        'description': description,
        'location': location,
        'type': type == DestinationType.culinary ? 'culinary' : 'tourism',
        'image_url': imageUrl,
        'created_by': createdBy,
      };

      // 5. Insert destination
      final response = await supabaseClient
          .from('destinations')
          .insert(destinationData)
          .select()
          .single();

      return DestinationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // UPDATE DESTINATION
  Future<DestinationEntity> updateDestination(
    DestinationEntity destination,
  ) async {
    try {
      final destinationData = {
        'name': destination.name,
        'description': destination.description,
        'location': destination.location,
        'type': destination.type == DestinationType.culinary
            ? 'culinary'
            : 'tourism',
        'image_url': destination.imageUrl,
      };

      final response = await supabaseClient
          .from('destinations')
          .update(destinationData)
          .eq('id', destination.id)
          .select()
          .single();

      return DestinationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // DELETE DESTINATION
  Future<void> deleteDestination(String destinationId) async {
    try {
      await supabaseClient
          .from('destinations')
          .delete()
          .eq('id', destinationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // GET DESTINATION BY ID
  Future<DestinationEntity> getDestinationById(String destinationId) async {
    try {
      final response = await supabaseClient
          .from('destinations')
          .select()
          .eq('id', destinationId)
          .single();

      return DestinationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // FILTER BY TYPE
  Future<List<DestinationEntity>> getDestinationsByType(
    DestinationType type,
  ) async {
    try {
      final typeValue = type == DestinationType.culinary
          ? 'culinary'
          : 'tourism';

      final response = await supabaseClient
          .from('destinations')
          .select()
          .eq('type', typeValue)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(
        response,
      ).map<DestinationEntity>((e) => DestinationModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
