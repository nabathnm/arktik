enum DestinationType { tourism, culinary }

class DestinationEntity {
  final String id;
  final String name;
  final String description;
  final String location;
  final DestinationType type;
  final String imageUrl;
  final String createdBy;

  const DestinationEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.type,
    required this.imageUrl,
    required this.createdBy,
  });
}
