import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/people/data/datasources/people_local_datasource.dart';
import 'package:paysa/features/people/data/models/person_record.dart';
import 'package:paysa/features/people/data/repositories/person_repository_impl.dart';
import 'package:paysa/features/people/domain/entities/person.dart';
import 'package:paysa/features/people/domain/repositories/person_repository.dart';

// ---------------------------------------------------------------------------
// In-memory datasource for testing (avoids Isar native dependency)
// ---------------------------------------------------------------------------

final class InMemoryPeopleLocalDataSource implements PeopleLocalDataSource {
  final _records = <int, PersonRecord>{};
  int _nextId = 1;

  @override
  Future<PersonRecord> put(PersonRecord record) async {
    if (record.id == 0) {
      record.id = _nextId++;
    }
    if (record.uuid.isEmpty) {
      record.uuid = 'test-uuid-${record.id}';
    }
    _records[record.id] = record;
    return record;
  }

  @override
  Future<PersonRecord?> getById(int id) async => _records[id];

  @override
  Future<PersonRecord?> getByPhone(String phone) async {
    final normalized = phone.trim().toLowerCase();
    for (final record in _records.values) {
      if (record.phone?.trim().toLowerCase() == normalized) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<List<PersonRecord>> getAll() async =>
      _records.values.toList(growable: false);

  @override
  Stream<List<PersonRecord>> watchAll() async* {
    yield _records.values.toList(growable: false);
  }

  @override
  Future<void> delete(int id) async {
    _records.remove(id);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Person _person({
  int id = 0,
  String name = 'Test Person',
  PersonType type = PersonType.other,
  String? phone,
  String? email,
  String? address,
  String? notes,
  int openingBalance = 0,
  OpeningBalanceDirection openingBalanceDirection = OpeningBalanceDirection.none,
  String currency = 'USD',
  bool isFavorite = false,
  PersonStatus status = PersonStatus.active,
  int version = 1,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return Person(
    id: id,
    name: name,
    type: type,
    phone: phone,
    email: email,
    address: address,
    notes: notes,
    openingBalance: openingBalance,
    openingBalanceDirection: openingBalanceDirection,
    currency: currency,
    isFavorite: isFavorite,
    status: status,
    version: version,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  late InMemoryPeopleLocalDataSource dataSource;
  late PersonRepository repository;

  setUp(() {
    dataSource = InMemoryPeopleLocalDataSource();
    repository = PersonRepositoryImpl(dataSource);
  });

  // ============================================================================
  // CREATE
  // ============================================================================

  group('createPerson', () {
    test('creates with valid minimal data', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));

      expect(p.id, greaterThan(0));
      expect(p.name, 'Rafiq');
      expect(p.uuid.isNotEmpty, true);
      expect(p.version, 1);
    });

    test('assigns uuid if not provided', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      expect(p.uuid.isNotEmpty, true);
      expect(p.uuid.length, greaterThan(20));
    });

    test('rejects empty name', () async {
      expect(
        () => repository.createPerson(_person(name: '')),
        throwsA(isA<AppException>()),
      );
    });

    test('rejects blank name', () async {
      expect(
        () => repository.createPerson(_person(name: '   ')),
        throwsA(isA<AppException>()),
      );
    });

    test('rejects name exceeding 100 characters', () async {
      expect(
        () => repository.createPerson(_person(name: 'A' * 101)),
        throwsA(isA<AppException>()),
      );
    });

    test('accepts name of exactly 100 characters', () async {
      final p = await repository.createPerson(_person(name: 'A' * 100));
      expect(p.name.length, 100);
    });

    test('rejects duplicate phone', () async {
      await repository.createPerson(
        _person(name: 'Alice', phone: '+8801111111111'),
      );
      expect(
        () => repository.createPerson(
          _person(name: 'Bob', phone: '+8801111111111'),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('allows duplicate phone across soft-deleted persons', () async {
      final a = await repository.createPerson(
        _person(name: 'Alice', phone: '+8801111111111'),
      );
      await repository.deletePerson(a.id);

      final b = await repository.createPerson(
        _person(name: 'Bob', phone: '+8801111111111'),
      );
      expect(b.phone, '+8801111111111');
    });

    test('rejects invalid email format', () async {
      expect(
        () => repository.createPerson(
          _person(name: 'Test', email: 'not-an-email'),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('accepts valid email', () async {
      final p = await repository.createPerson(
        _person(name: 'Test', email: 'user@example.com'),
      );
      expect(p.email, 'user@example.com');
    });

    test('rejects email with missing domain', () async {
      expect(
        () => repository.createPerson(
          _person(name: 'Test', email: 'user@'),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('allows null fields (phone, email, address, notes)', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      expect(p.phone, isNull);
      expect(p.email, isNull);
      expect(p.address, isNull);
      expect(p.notes, isNull);
    });

    test('trims whitespace from name', () async {
      final p = await repository.createPerson(_person(name: '  Alice  '));
      expect(p.name, 'Alice');
    });

    test('rejects negative opening balance', () async {
      expect(
        () => repository.createPerson(
          _person(name: 'Test', openingBalance: -5000),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('rejects opening balance without direction', () async {
      expect(
        () => repository.createPerson(
          _person(name: 'Test', openingBalance: 5000),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('accepts opening balance with give direction', () async {
      final p = await repository.createPerson(
        _person(
          name: 'Test',
          openingBalance: 50000,
          openingBalanceDirection: OpeningBalanceDirection.give,
        ),
      );
      expect(p.openingBalance, 50000);
      expect(p.openingBalanceDirection, OpeningBalanceDirection.give);
    });

    test('accepts opening balance with receive direction', () async {
      final p = await repository.createPerson(
        _person(
          name: 'Test',
          openingBalance: 30000,
          openingBalanceDirection: OpeningBalanceDirection.receive,
        ),
      );
      expect(p.openingBalance, 30000);
      expect(p.openingBalanceDirection, OpeningBalanceDirection.receive);
    });
  });

  // ============================================================================
  // UPDATE
  // ============================================================================

  group('updatePerson', () {
    test('updates name and increments version', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq Ahmed'));
      final updated = await repository.updatePerson(
        p.copyWith(name: 'Rafiq Karim'),
      );
      expect(updated.name, 'Rafiq Karim');
      expect(updated.version, 2);
    });

    test('rejects update for non-existent person', () async {
      expect(
        () => repository.updatePerson(
          _person(id: 999, name: 'Ghost'),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('blocks phone takeover by different person', () async {
      await repository.createPerson(
        _person(name: 'Alice', phone: '+8801111111111'),
      );
      final bob = await repository.createPerson(
        _person(name: 'Bob', phone: '+8802222222222'),
      );
      expect(
        () => repository.updatePerson(
          bob.copyWith(phone: '+8801111111111'),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('allows updating own phone (same number)', () async {
      final p = await repository.createPerson(
        _person(name: 'Rafiq', phone: '+8801111111111'),
      );
      final updated = await repository.updatePerson(
        p.copyWith(name: 'Rafiq Ahmed'),
      );
      expect(updated.phone, '+8801111111111');
    });

    test('allows adding phone to person without one', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      final updated = await repository.updatePerson(
        p.copyWith(phone: '+8801111111111'),
      );
      expect(updated.phone, '+8801111111111');
    });

    test('allows removing phone via empty string', () async {
      final p = await repository.createPerson(
        _person(name: 'Alice', phone: '+8801111111111'),
      );
      // toRecord() converts empty strings to null
      final updated = await repository.updatePerson(
        p.copyWith(phone: ''),
      );
      expect(updated.phone, isNull);
    });

    test('preserves uuid across updates', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      final updated = await repository.updatePerson(
        p.copyWith(name: 'Alice Smith'),
      );
      expect(updated.uuid, p.uuid);
    });
  });

  // ============================================================================
  // READ / QUERY
  // ============================================================================

  group('getPeople', () {
    test('returns all non-deleted people', () async {
      await repository.createPerson(_person(name: 'Alice'));
      await repository.createPerson(_person(name: 'Bob'));
      expect((await repository.getPeople()).length, 2);
    });

    test('excludes soft-deleted people', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      await repository.deletePerson(p.id);
      final all = await repository.getPeople();
      expect(all.where((x) => x.id == p.id).isEmpty, true);
    });

    test('filters by type — customer', () async {
      await repository.createPerson(
        _person(name: 'Alice', type: PersonType.customer),
      );
      await repository.createPerson(
        _person(name: 'Bob', type: PersonType.supplier),
      );
      final filtered = await repository.getPeople(typeFilter: PersonType.customer);
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Alice');
    });

    test('filters by type — supplier', () async {
      await repository.createPerson(
        _person(name: 'Alice', type: PersonType.customer),
      );
      await repository.createPerson(
        _person(name: 'Bob', type: PersonType.supplier),
      );
      final filtered = await repository.getPeople(typeFilter: PersonType.supplier);
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Bob');
    });

    test('filters by type — friend', () async {
      await repository.createPerson(
        _person(name: 'Charlie', type: PersonType.friend),
      );
      final filtered = await repository.getPeople(typeFilter: PersonType.friend);
      expect(filtered.length, 1);
    });

    test('filters by type — family', () async {
      await repository.createPerson(
        _person(name: 'Mom', type: PersonType.family),
      );
      final filtered = await repository.getPeople(typeFilter: PersonType.family);
      expect(filtered.length, 1);
    });

    test('filters by type — employee', () async {
      await repository.createPerson(
        _person(name: 'Staff', type: PersonType.employee),
      );
      final filtered = await repository.getPeople(typeFilter: PersonType.employee);
      expect(filtered.length, 1);
    });

    test('filters by type — other', () async {
      await repository.createPerson(
        _person(name: 'Misc', type: PersonType.other),
      );
      final filtered = await repository.getPeople(typeFilter: PersonType.other);
      expect(filtered.length, 1);
    });

    test('returns empty list for unmatched type', () async {
      await repository.createPerson(
        _person(name: 'Alice', type: PersonType.customer),
      );
      final filtered = await repository.getPeople(typeFilter: PersonType.supplier);
      expect(filtered, isEmpty);
    });

    test('filters by active status', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      await repository.archivePerson(p.id);
      final active = await repository.getPeople(statusFilter: PersonStatus.active);
      expect(active.where((x) => x.name == 'Alice').isEmpty, true);
    });

    test('filters by archived status', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      await repository.archivePerson(p.id);
      final archived =
          await repository.getPeople(statusFilter: PersonStatus.archived);
      expect(archived.length, 1);
      expect(archived.first.name, 'Alice');
    });

    test('filters by favorites only', () async {
      await repository.createPerson(
        _person(name: 'Alice', isFavorite: true),
      );
      await repository.createPerson(
        _person(name: 'Bob', isFavorite: false),
      );
      final faves = await repository.getPeople(favoritesOnly: true);
      expect(faves.length, 1);
      expect(faves.first.name, 'Alice');
    });

    test('sorts favorites first, then alphabetical', () async {
      await repository.createPerson(
        _person(name: 'Zara', isFavorite: true),
      );
      await repository.createPerson(
        _person(name: 'Alpha', isFavorite: false),
      );
      await repository.createPerson(
        _person(name: 'Beta', isFavorite: true),
      );
      final all = await repository.getPeople();
      expect(all[0].name, 'Beta');
      expect(all[1].name, 'Zara');
      expect(all[2].name, 'Alpha');
    });

    test('searches by name (case-insensitive)', () async {
      await repository.createPerson(_person(name: 'Rafiq Ahmed'));
      await repository.createPerson(_person(name: 'Karim Hossain'));
      final results = await repository.getPeople(searchQuery: 'rafiq');
      expect(results.length, 1);
      expect(results.first.name, 'Rafiq Ahmed');
    });

    test('searches by partial name', () async {
      await repository.createPerson(_person(name: 'Mohammad Rafiq'));
      await repository.createPerson(_person(name: 'Rafiqul Islam'));
      final results = await repository.getPeople(searchQuery: 'Rafiq');
      expect(results.length, 2);
    });

    test('searches by phone number', () async {
      await repository.createPerson(
        _person(name: 'Rafiq', phone: '+8801712345678'),
      );
      final results = await repository.getPeople(searchQuery: '12345678');
      expect(results.length, 1);
    });

    test('searches by email', () async {
      await repository.createPerson(
        _person(name: 'Rafiq', email: 'rafiq@example.com'),
      );
      final results = await repository.getPeople(searchQuery: 'rafiq@example');
      expect(results.length, 1);
    });

    test('returns empty for unmatched search', () async {
      await repository.createPerson(_person(name: 'Alice'));
      final results = await repository.getPeople(searchQuery: 'zzzzz');
      expect(results, isEmpty);
    });

    test('returns all when search is empty', () async {
      await repository.createPerson(_person(name: 'Alice'));
      await repository.createPerson(_person(name: 'Bob'));
      final results = await repository.getPeople(searchQuery: '');
      expect(results.length, 2);
    });

    test('getPersonById returns correct person', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));
      final found = await repository.getPersonById(p.id);
      expect(found?.name, 'Rafiq');
    });

    test('getPersonById returns null for missing', () async {
      final found = await repository.getPersonById(999);
      expect(found, isNull);
    });

    test('getPersonByPhone returns correct person', () async {
      await repository.createPerson(
        _person(name: 'Rafiq', phone: '+8801712345678'),
      );
      final found = await repository.getPersonByPhone('+8801712345678');
      expect(found?.name, 'Rafiq');
    });

    test('getPersonByPhone returns null for unmatched', () async {
      final found = await repository.getPersonByPhone('+8800000000000');
      expect(found, isNull);
    });

    test('getPersonByPhone is case-insensitive', () async {
      await repository.createPerson(
        _person(name: 'Rafiq', phone: '+8801712345678'),
      );
      final found = await repository.getPersonByPhone('+8801712345678');
      expect(found?.name, 'Rafiq');
    });

    test('getActivePeople returns only active', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      await repository.createPerson(_person(name: 'Bob'));
      await repository.archivePerson(p.id);
      final active = await repository.getActivePeople();
      expect(active.length, 1);
      expect(active.first.name, 'Bob');
    });
  });

  // ============================================================================
  // DELETE
  // ============================================================================

  group('deletePerson', () {
    test('soft-deletes and excludes from listing', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));
      await repository.deletePerson(p.id);
      final all = await repository.getPeople();
      expect(all.where((x) => x.id == p.id), isEmpty);
    });

    test('rejects delete of person with opening balance', () async {
      final p = await repository.createPerson(
        _person(
          name: 'Rafiq',
          openingBalance: 50000,
          openingBalanceDirection: OpeningBalanceDirection.give,
        ),
      );
      expect(
        () => repository.deletePerson(p.id),
        throwsA(isA<AppException>()),
      );
    });

    test('rejects delete of non-existent person', () async {
      expect(
        () => repository.deletePerson(999),
        throwsA(isA<AppException>()),
      );
    });

    test('allows delete after balance is zero', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));
      await repository.deletePerson(p.id);
      final all = await repository.getPeople();
      expect(all, isEmpty);
    });

    test('soft-deleted person can be restored', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));
      await repository.deletePerson(p.id);
      await repository.restorePerson(p.id);
      final all = await repository.getPeople();
      expect(all.any((x) => x.id == p.id), true);
    });
  });

  // ============================================================================
  // ARCHIVE / RESTORE
  // ============================================================================

  group('archivePerson', () {
    test('archived person is not shown in active list', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));
      await repository.archivePerson(p.id);
      final active = await repository.getActivePeople();
      expect(active.where((x) => x.id == p.id), isEmpty);
    });

    test('archived person appears in archived filter', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));
      await repository.archivePerson(p.id);
      final archived =
          await repository.getPeople(statusFilter: PersonStatus.archived);
      expect(archived.any((x) => x.id == p.id), true);
    });

    test('archive and restore round-trip', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));
      final archived = await repository.archivePerson(p.id);
      expect(archived.isArchived, true);
      final restored = await repository.restorePerson(p.id);
      expect(restored.isActive, true);
    });

    test('restore clears deletedAt', () async {
      final p = await repository.createPerson(_person(name: 'Rafiq'));
      await repository.deletePerson(p.id);
      final restored = await repository.restorePerson(p.id);
      expect(restored.isActive, true);
      expect(restored.isDeleted, false);
    });

    test('rejects archive of non-existent person', () async {
      expect(
        () => repository.archivePerson(999),
        throwsA(isA<AppException>()),
      );
    });

    test('rejects restore of non-existent person', () async {
      expect(
        () => repository.restorePerson(999),
        throwsA(isA<AppException>()),
      );
    });
  });

  // ============================================================================
  // WATCH (STREAM)
  // ============================================================================

  group('watchPeople', () {
    test('emits initial data', () async {
      await repository.createPerson(_person(name: 'Alice'));
      final emitted = await repository.watchPeople().first;
      expect(emitted.length, 1);
      expect(emitted.first.name, 'Alice');
    });

    test('emits updated data after creation', () async {
      final stream = repository.watchPeople();
      await repository.createPerson(_person(name: 'Alice'));
      final emitted = await stream.first;
      expect(emitted.length, 1);
    });

    test('emits updated data after deletion', () async {
      final p = await repository.createPerson(_person(name: 'Alice'));
      final stream = repository.watchPeople();
      await repository.deletePerson(p.id);
      final emitted = await stream.first;
      expect(emitted.where((x) => x.id == p.id), isEmpty);
    });
  });

  // ============================================================================
  // PROVIDER / FILTER INTEGRATION
  // ============================================================================
  // These tests require isarProvider DI setup and are covered by repository
  // filter tests above (getPeople with typeFilter, statusFilter, etc.)

  // ============================================================================
  // CREATION VALIDATION (edge cases)
  // ============================================================================

  group('validation', () {
    test('trims whitespace from phone, email, address, notes', () async {
      final p = await repository.createPerson(_person(
        name: 'Test',
        phone: '  +8801111111111  ',
        email: '  a@b.com  ',
        address: '  Somewhere  ',
        notes: '  Hello  ',
      ));
      expect(p.phone, '+8801111111111');
      expect(p.email, 'a@b.com');
      expect(p.address, 'Somewhere');
      expect(p.notes, 'Hello');
    });

    test('converts currency to uppercase', () async {
      final p = await repository.createPerson(
        _person(name: 'Test', currency: 'usd'),
      );
      expect(p.currency, 'USD');
    });

    test('handles empty phone, email, address as null', () async {
      final p = await repository.createPerson(_person(
        name: 'Test',
        phone: '',
        email: '',
        address: '',
        notes: '',
      ));
      expect(p.phone, isNull);
      expect(p.email, isNull);
      expect(p.address, isNull);
      expect(p.notes, isNull);
    });

    test('preserves opening balance on update', () async {
      final p = await repository.createPerson(_person(
        name: 'Test',
        openingBalance: 50000,
        openingBalanceDirection: OpeningBalanceDirection.give,
      ));
      final updated = await repository.updatePerson(
        p.copyWith(name: 'Updated'),
      );
      expect(updated.openingBalance, 50000);
    });

    test('preserves favorite status on update', () async {
      final p = await repository.createPerson(
        _person(name: 'Test', isFavorite: true),
      );
      final updated = await repository.updatePerson(
        p.copyWith(name: 'Updated'),
      );
      expect(updated.isFavorite, true);
    });
  });
}
