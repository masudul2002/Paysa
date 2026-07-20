import 'package:paysa/core/app_exception.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

final class RestorePerson {
  const RestorePerson(this._repository);

  final PersonRepository _repository;

  Future<Person> call(int id) async {
    if (id <= 0) {
      throw AppException('Invalid person.');
    }
    return _repository.restorePerson(id);
  }
}
