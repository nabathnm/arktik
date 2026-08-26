import '../../domain/entities/destination_entity.dart';

class DestinationModel extends DestinationEntity {
  const DestinationModel({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    required super.type,
    required super.imageUrl,
    required super.createdBy,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'] ?? '',
      type: json['type'] == 'culinary'
          ? DestinationType.culinary
          : DestinationType.tourism,
      imageUrl: json['image_url'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'type': type == DestinationType.culinary ? 'culinary' : 'tourism',
      'image_url': imageUrl,
      'created_by': createdBy,
    };
  }
}
