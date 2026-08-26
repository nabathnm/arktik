import '../entities/destination_entity.dart';
import '../repositories/destination_repository.dart';

class GetDestinations {
  final DestinationRepository repository;

  GetDestinations(this.repository);

  Future<List<DestinationEntity>> call() {
    return repository.getAdminDestinations();
  }
}
