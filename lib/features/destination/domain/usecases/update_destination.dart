import '../entities/destination_entity.dart';
import '../repositories/destination_repository.dart';

class UpdateDestination {
  final DestinationRepository repository;

  UpdateDestination(this.repository);

  Future<DestinationEntity> call(DestinationEntity destination) {
    return repository.updateDestination(destination);
  }
}
