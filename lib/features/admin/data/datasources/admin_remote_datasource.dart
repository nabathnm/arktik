import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

abstract class AdminRemoteDataSource {
  Future<Map<String, dynamic>> createDestination({
    required String name,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required String type,
    required File imageFile,
    required bool isActive,
    required String createdBy,
  });

  Future<void> updateDestinationStatus(String id, bool isActive);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabaseClient;

  AdminRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<Map<String, dynamic>> createDestination({
    required String name,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required String type,
    required File imageFile,
    required bool isActive,
    required String createdBy,
  }) async {
    // 1. Upload Image to Supabase Storage
    final extension = p.extension(imageFile.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${supabaseClient.auth.currentUser!.id}$extension';
    final imagePath = 'destinations/$fileName';
    
    await supabaseClient.storage.from('destinations').upload(
      imagePath,
      imageFile,
    );

    final imageUrl = supabaseClient.storage.from('destinations').getPublicUrl(imagePath);

    // 2. Insert into destinations table
    final response = await supabaseClient
        .from('destinations')
        .insert({
          'name': name,
          'description': description,
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
          'type': type,
          'image_url': imageUrl,
          'is_active': isActive,
          'created_by': createdBy,
        })
        .select()
        .single();

    return response;
  }

  @override
  Future<void> updateDestinationStatus(String id, bool isActive) async {
    await supabaseClient
        .from('destinations')
        .update({'is_active': isActive})
        .eq('id', id);
  }
}
