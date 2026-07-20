import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/person.dart';
import '../../domain/repositories/person_repository.dart';
import '../datasources/people_local_datasource.dart';
import '../models/person_record.dart';

/// Implementation of [PersonRepository] backed by [PeopleLocalDataSource].
final class PersonRepositoryImpl implements PersonRepository {
  const PersonRepositoryImpl(this._localDataSource);

  final PeopleLocalDataSource _localDataSource;

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  @override
  Future<Person> createPerson(Person person) async {
    _validateCreate(person);

    // Check phone uniqueness (exclude soft-deleted)
    if (person.phone != null) {
      final existing = await _localDataSource.getByPhone(person.phone!);
      if (existing != null && existing.deletedAt == null) {
        throw AppException('A person with this phone number already exists.');
      }
    }

    final now = DateTime.now();
    final record = person.copyWith(
      createdAt: now,
      updatedAt: now,
      version: 1,
    ).toRecord();

    final saved = await _localDataSource.put(record);
    return saved.toEntity();
  }

  @override
  Future<Person> updatePerson(Person person) async {
    if (person.id <= 0) {
      throw AppException('Invalid person record.');
    }

    final existing = await _localDataSource.getById(person.id);
    if (existing == null) {
      throw AppException('Person not found.');
    }

    // Check phone uniqueness (exclude self and soft-deleted)
    if (person.phone != null) {
      final dupe = await _localDataSource.getByPhone(person.phone!);
      if (dupe != null && dupe.id != person.id && dupe.deletedAt == null) {
        throw AppException('Another person with this phone number already exists.');
      }
    }

    final now = DateTime.now();
    final record = person.copyWith(
      updatedAt: now,
      version: existing.version + 1,
      uuid: existing.uuid,
    ).toRecord();

    final saved = await _localDataSource.put(record);
    return saved.toEntity();
  }

  @override
  Future<void> deletePerson(int id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw AppException('Person not found.');
    }
    if (existing.openingBalance != 0) {
      throw AppException(
        'Cannot delete person with non-zero balance. Archive instead.',
      );
    }

    // Soft-delete: set deletedAt and deactivate
    final now = DateTime.now();
    final updated = existing
      ..deletedAt = now
      ..active = false;
    await _localDataSource.put(updated);
  }

  // ---------------------------------------------------------------------------
  // Archive / Restore
  // ---------------------------------------------------------------------------

  @override
  Future<Person> archivePerson(int id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw AppException('Person not found.');
    }

    final now = DateTime.now();
    final updated = existing
      ..active = false
      ..updatedAt = now;

    final saved = await _localDataSource.put(updated);
    return saved.toEntity();
  }

  @override
  Future<Person> restorePerson(int id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw AppException('Person not found.');
    }

    final now = DateTime.now();
    final updated = existing
      ..active = true
      ..deletedAt = null
      ..updatedAt = now;

    final saved = await _localDataSource.put(updated);
    return saved.toEntity();
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  @override
  Future<Person?> getPersonById(int id) async {
    final record = await _localDataSource.getById(id);
    return record?.toEntity();
  }

  @override
  Future<Person?> getPersonByPhone(String phone) async {
    final record = await _localDataSource.getByPhone(phone);
    return record?.toEntity();
  }

  @override
  Future<List<Person>> getPeople({
    PersonType? typeFilter,
    PersonStatus? statusFilter,
    bool? favoritesOnly,
    String? searchQuery,
  }) async {
    var records = await _localDataSource.getAll();

    // Exclude soft-deleted
    records = records.where((r) => r.deletedAt == null).toList();

    if (typeFilter != null) {
      records = records.where((r) => r.personType == typeFilter).toList();
    }
    if (statusFilter != null) {
      records = records.where((r) {
        if (statusFilter == PersonStatus.active) return r.active;
        return !r.active;
      }).toList();
    }
    if (favoritesOnly == true) {
      records = records.where((r) => r.favorite).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      records = records.where((r) {
        return r.name.toLowerCase().contains(query) ||
            (r.phone?.toLowerCase().contains(query) ?? false) ||
            (r.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return records.map((r) => r.toEntity()).toList()
      ..sort(_comparePeople);
  }

  @override
  Future<List<Person>> getActivePeople() async {
    return getPeople(statusFilter: PersonStatus.active);
  }

  @override
  Stream<List<Person>> watchPeople() {
    return _localDataSource.watchAll().map((records) {
      return records
          .where((r) => r.deletedAt == null)
          .map((r) => r.toEntity())
          .toList()
        ..sort(_comparePeople);
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _comparePeople(Person a, Person b) {
    // Favorites first, then alphabetical
    if (a.isFavorite && !b.isFavorite) return -1;
    if (!a.isFavorite && b.isFavorite) return 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  void _validateCreate(Person person) {
    if (person.name.trim().isEmpty) {
      throw AppException('Person name cannot be empty.');
    }
    if (person.name.trim().length > 100) {
      throw AppException('Person name must be under 100 characters.');
    }
    if (person.openingBalance < 0) {
      throw AppException('Opening balance cannot be negative.');
    }
    if (person.openingBalance > 0 &&
        person.openingBalanceDirection == OpeningBalanceDirection.none) {
      throw AppException(
        'Opening balance direction must be set when balance is non-zero.',
      );
    }
    if (person.email != null && person.email!.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(person.email!.trim())) {
        throw AppException('Invalid email format.');
      }
    }
  }
}
