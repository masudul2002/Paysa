import 'package:paysa/core/app_exception.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

final class UpdatePerson {
  const UpdatePerson(this._repository);

  final PersonRepository _repository;

  Future<Person> call(Person person) async {
    if (person.id <= 0) {
      throw AppException('Invalid person record.');
    }
    if (person.name.trim().isEmpty) {
      throw AppException('Person name cannot be empty.');
    }
    if (person.name.trim().length > 100) {
      throw AppException('Person name must be under 100 characters.');
    }
    if (person.phone != null && person.phone!.trim().isEmpty) {
      throw AppException('Phone number cannot be empty.');
    }
    if (person.email != null && person.email!.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(person.email!.trim())) {
        throw AppException('Invalid email format.');
      }
    }

    return _repository.updatePerson(person);
  }
}
