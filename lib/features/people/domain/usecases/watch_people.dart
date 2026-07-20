import '../entities/person.dart';
import '../repositories/person_repository.dart';

final class WatchPeople {
  const WatchPeople(this._repository);

  final PersonRepository _repository;

  Stream<List<Person>> call() => _repository.watchPeople();
}
