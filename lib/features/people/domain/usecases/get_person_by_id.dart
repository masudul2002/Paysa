import '../entities/person.dart';
import '../repositories/person_repository.dart';

final class GetPersonById {
  const GetPersonById(this._repository);

  final PersonRepository _repository;

  Future<Person?> call(int id) => _repository.getPersonById(id);
}
