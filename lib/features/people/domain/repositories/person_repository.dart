import '../entities/person.dart';

abstract interface class PersonRepository {
  Future<Person> createPerson(Person person);

  Future<Person> updatePerson(Person person);

  Future<void> deletePerson(int id);

  Future<Person> archivePerson(int id);

  Future<Person> restorePerson(int id);

  Future<Person?> getPersonById(int id);

  Future<Person?> getPersonByPhone(String phone);

  Future<List<Person>> getPeople({
    PersonType? typeFilter,
    PersonStatus? statusFilter,
    bool? favoritesOnly,
    String? searchQuery,
  });

  Future<List<Person>> getActivePeople();

  Stream<List<Person>> watchPeople();
}
