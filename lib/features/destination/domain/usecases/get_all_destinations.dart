import '../entities/destination_entity.dart';
import '../repositories/destination_repository.dart';

class GetAllDestinations {
  final DestinationRepository repository;

  GetAllDestinations(this.repository);

  Future<List<DestinationEntity>> call() async {
    return await repository.getAllDestinations();
  }
}
