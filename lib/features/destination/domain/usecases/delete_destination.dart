import '../repositories/destination_repository.dart';

class DeleteDestination {
  final DestinationRepository repository;

  DeleteDestination(this.repository);

  Future<void> call(String destinationId) {
    return repository.deleteDestination(destinationId);
  }
}
