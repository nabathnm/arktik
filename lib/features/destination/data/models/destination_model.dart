import '../../domain/entities/destination_entity.dart';

class DestinationModel extends DestinationEntity {
  const DestinationModel({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    required super.latitude,
    required super.longitude,
    required super.type,
    required super.imageUrl,
    required super.rating,
    required super.reviewCount,
    required super.isActive,
    required super.createdBy,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] == 'culinary'
          ? DestinationType.culinary
          : DestinationType.tourism,
      imageUrl: json['image_url'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'type': type == DestinationType.culinary ? 'culinary' : 'tourism',
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'is_active': isActive,
      'created_by': createdBy,
    };
  }
}
