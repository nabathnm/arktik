enum DestinationType { tourism, culinary }

class DestinationEntity {
  final String id;
  final String name;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final DestinationType type;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final String createdBy;

  const DestinationEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isActive,
    required this.createdBy,
  });
}
