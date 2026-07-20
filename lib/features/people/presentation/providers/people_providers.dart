import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_people_local_datasource.dart';
import '../../data/repositories/person_repository_impl.dart';
import '../../domain/entities/person.dart';
import '../../domain/repositories/person_repository.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Provides the [PersonRepository] singleton, backed by Isar.
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return PersonRepositoryImpl(IsarPeopleLocalDataSource(isar));
});

// ---------------------------------------------------------------------------
// Filter / Sort State
// ---------------------------------------------------------------------------

/// Current type filter. Null means no filter (show all types).
final peopleTypeFilterProvider = StateProvider<PersonType?>((ref) => null);

/// Current status filter. Null means no filter (show all statuses).
final peopleStatusFilterProvider = StateProvider<PersonStatus?>((ref) => null);

/// Current search query string. Empty means no search filter.
final peopleSearchQueryProvider = StateProvider<String>((ref) => '');

/// Whether to show only favorites.
final peopleFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

/// Current sort field.
enum PeopleSortField { name, createdAt, balance }

/// Current sort direction.
enum PeopleSortDirection { ascending, descending }

/// Sort configuration.
final peopleSortProvider =
    StateProvider<Map<String, dynamic>>((ref) => <String, dynamic>{
          'field': PeopleSortField.name.name,
          'direction': PeopleSortDirection.ascending.name,
        });

/// Currently selected person ID. Null means no selection.
final selectedPersonIdProvider = StateProvider<int?>((ref) => null);

// ---------------------------------------------------------------------------
// Reactive People Stream
// ---------------------------------------------------------------------------

/// Streams all non-deleted people, applying current filters and sort.
final peopleListProvider = StreamProvider.autoDispose<List<Person>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  final typeFilter = ref.watch(peopleTypeFilterProvider);
  final statusFilter = ref.watch(peopleStatusFilterProvider);
  final favoritesOnly = ref.watch(peopleFavoritesOnlyProvider);
  final searchQuery = ref.watch(peopleSearchQueryProvider);
  final sortConfig = ref.watch(peopleSortProvider);

  final sortField = PeopleSortField.values.firstWhere(
    (f) => f.name == sortConfig['field'],
    orElse: () => PeopleSortField.name,
  );
  final sortDirection = PeopleSortDirection.values.firstWhere(
    (d) => d.name == sortConfig['direction'],
    orElse: () => PeopleSortDirection.ascending,
  );

  return repository.watchPeople().map((people) {
    var filtered = people.toList();

    // Type filter
    if (typeFilter != null) {
      filtered = filtered.where((p) => p.type == typeFilter).toList();
    }

    // Status filter
    if (statusFilter != null) {
      filtered =
          filtered.where((p) => p.status == statusFilter).toList();
    }

    // Favorites only
    if (favoritesOnly) {
      filtered = filtered.where((p) => p.isFavorite).toList();
    }

    // Search
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.phone?.toLowerCase().contains(query) ?? false) ||
            (p.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort
    filtered.sort((a, b) {
      int cmp;
      switch (sortField) {
        case PeopleSortField.name:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case PeopleSortField.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
        case PeopleSortField.balance:
          cmp = a.openingBalance.compareTo(b.openingBalance);
      }
      return sortDirection == PeopleSortDirection.ascending ? cmp : -cmp;
    });

    return filtered;
  });
});

// ---------------------------------------------------------------------------
// Single Person
// ---------------------------------------------------------------------------

/// Fetches a single person by ID. Auto-disposes when no listener.
final personByIdProvider =
    FutureProvider.autoDispose.family<Person?, int>((ref, id) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.getPersonById(id);
});

// ---------------------------------------------------------------------------
// People Count
// ---------------------------------------------------------------------------

/// Streams the total count of active (non-deleted, non-archived) people.
final activePeopleCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchPeople().map(
    (people) => people.where((p) => p.isActive).length,
  );
});

/// Streams the count of people with a non-zero outstanding balance.
final peopleWithBalanceCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchPeople().map(
    (people) => people.where((p) => p.openingBalance != 0).length,
  );
});

// ---------------------------------------------------------------------------
// Search (debounced convenience)
// ---------------------------------------------------------------------------

/// Sets [peopleSearchQueryProvider] after a debounce delay.
/// Call `ref.read(peopleSearchControllerProvider.notifier).search(term)`.
final peopleSearchControllerProvider =
    StateNotifierProvider<PeopleSearchController, String>((ref) {
  return PeopleSearchController(ref);
});

class PeopleSearchController extends StateNotifier<String> {
  PeopleSearchController(this._ref) : super('');

  final Ref _ref;

  void search(String query) {
    state = query;
    _ref.read(peopleSearchQueryProvider.notifier).state = query;
  }

  void clear() {
    state = '';
    _ref.read(peopleSearchQueryProvider.notifier).state = '';
  }
}

// ---------------------------------------------------------------------------
// Action providers — expose repository methods via DI
// ---------------------------------------------------------------------------

/// Provides the create function for adding a new person.
final createPersonProvider = Provider<CreatePersonFn>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return (Person person) => repository.createPerson(person);
});

/// Provides the update function for editing a person.
final updatePersonProvider = Provider<UpdatePersonFn>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return (Person person) => repository.updatePerson(person);
});

/// Provides the delete function for removing a person by ID.
final deletePersonProvider = Provider<DeletePersonFn>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return (int id) => repository.deletePerson(id);
});

/// Provides the archive function.
final archivePersonProvider = Provider<ArchivePersonFn>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return (int id) => repository.archivePerson(id);
});

/// Provides the restore function.
final restorePersonProvider = Provider<RestorePersonFn>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return (int id) => repository.restorePerson(id);
});

typedef CreatePersonFn = Future<Person> Function(Person person);
typedef UpdatePersonFn = Future<Person> Function(Person person);
typedef DeletePersonFn = Future<void> Function(int id);
typedef ArchivePersonFn = Future<Person> Function(int id);
typedef RestorePersonFn = Future<Person> Function(int id);
