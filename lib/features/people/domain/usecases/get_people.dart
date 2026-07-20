import '../entities/person.dart';
import '../repositories/person_repository.dart';

final class GetPeople {
  const GetPeople(this._repository);

  final PersonRepository _repository;

  Future<List<Person>> call({
    PersonType? typeFilter,
    PersonStatus? statusFilter,
    bool? favoritesOnly,
    String? searchQuery,
  }) {
    return _repository.getPeople(
      typeFilter: typeFilter,
      statusFilter: statusFilter,
      favoritesOnly: favoritesOnly,
      searchQuery: searchQuery,
    );
  }
}
