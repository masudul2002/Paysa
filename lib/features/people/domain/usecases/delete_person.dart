import 'package:paysa/core/app_exception.dart';
import '../repositories/person_repository.dart';

final class DeletePerson {
  const DeletePerson(this._repository);

  final PersonRepository _repository;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw AppException('Invalid person.');
    }
    return _repository.deletePerson(id);
  }
}
