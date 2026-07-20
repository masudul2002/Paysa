import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/person.dart';
import '../providers/people_providers.dart';
import '../widgets/person_form_sheet.dart';
import '../widgets/person_visuals.dart';
import 'person_detail_page.dart';

/// People list screen.
///
/// Displays all non-deleted people with avatar, name, phone,
/// outstanding balance, favorite indicator, and archive status.
/// Supports search, filter (type/status/favorites), and sort.
class PeoplePage extends ConsumerStatefulWidget {
  const PeoplePage({super.key});

  @override
  ConsumerState<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage> {
  final _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(peopleListProvider);
    final searchQuery = ref.watch(peopleSearchQueryProvider);
    final typeFilter = ref.watch(peopleTypeFilterProvider);
    final statusFilter = ref.watch(peopleStatusFilterProvider);
    final favoritesOnly = ref.watch(peopleFavoritesOnlyProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by name, phone, or email...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(peopleSearchQueryProvider.notifier).state = value;
                },
              )
            : const Text('People'),
        actions: [
          if (_showSearchBar)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _showSearchBar = false);
                _searchController.clear();
                ref.read(peopleSearchQueryProvider.notifier).state = '';
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _showSearchBar = true),
            ),
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort_outlined),
            tooltip: 'Sort',
            onSelected: (option) {
              ref.read(peopleSortProvider.notifier).state = {
                'field': option.field.name,
                'direction': option.direction.name,
              };
            },
            itemBuilder: (_) => [
              _sortItem(_sortOptionNameAsc, 'Name (A-Z)'),
              _sortItem(_sortOptionNameDesc, 'Name (Z-A)'),
              _sortItem(_sortOptionNewest, 'Newest first'),
              _sortItem(_sortOptionOldest, 'Oldest first'),
              _sortItem(_sortOptionBalanceAsc, 'Balance (low-high)'),
              _sortItem(_sortOptionBalanceDesc, 'Balance (high-low)'),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddForm(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Filter row ---
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(
                      label: 'All',
                      selected: typeFilter == null && statusFilter == null,
                      onSelected: () {
                        ref.read(peopleTypeFilterProvider.notifier).state = null;
                        ref.read(peopleStatusFilterProvider.notifier).state = null;
                      },
                    ),
                    _buildFilterChip(
                      label: 'Active',
                      selected: statusFilter == PersonStatus.active,
                      onSelected: () => ref
                          .read(peopleStatusFilterProvider.notifier)
                          .state = PersonStatus.active,
                    ),
                    _buildFilterChip(
                      label: 'Archived',
                      selected: statusFilter == PersonStatus.archived,
                      onSelected: () => ref
                          .read(peopleStatusFilterProvider.notifier)
                          .state = PersonStatus.archived,
                    ),
                    _buildFilterChip(
                      label: 'Favorites',
                      selected: favoritesOnly,
                      onSelected: () => ref
                          .read(peopleFavoritesOnlyProvider.notifier)
                          .state = !favoritesOnly,
                    ),
                    // PersonType quick filters
                    ...PersonType.values.map((type) => _buildFilterChip(
                          label: type.label,
                          selected: typeFilter == type,
                          onSelected: () => ref
                              .read(peopleTypeFilterProvider.notifier)
                              .state = typeFilter == type ? null : type,
                        )),
                  ],
                ),
              ),

              // --- Active search indicator ---
              if (searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text('Search: "$searchQuery"'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    _searchController.clear();
                    ref.read(peopleSearchQueryProvider.notifier).state = '';
                  },
                ),
              ],

              const SizedBox(height: 12),

              // --- People list ---
              Expanded(
                child: peopleAsync.when(
                  loading: () => const Center(
                    child: LoadingWidget(message: 'Loading people...'),
                  ),
                  error: (error, _) => Center(
                    child: AppErrorWidget(
                      title: 'Could not load people',
                      details: error.toString(),
                    ),
                  ),
                  data: (people) {
                    if (people.isEmpty) {
                      return _buildEmptyState(
                        hasFilters: searchQuery.isNotEmpty ||
                            typeFilter != null ||
                            statusFilter != null,
                      );
                    }

                    if (isWide) {
                      return _buildWideGrid(people);
                    }
                    return _buildNarrowList(people);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // List variants
  // --------------------------------------------------------------------------

  Widget _buildNarrowList(List<Person> people) {
    return ListView.separated(
      itemCount: people.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _buildPersonItem(people[index]),
    );
  }

  Widget _buildWideGrid(List<Person> people) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 88,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: people.length,
      itemBuilder: (_, index) => _buildPersonItem(people[index]),
    );
  }

  // --------------------------------------------------------------------------
  // Person item (card/tile)
  // --------------------------------------------------------------------------

  Widget _buildPersonItem(Person person) {
    final theme = Theme.of(context);
    final typeColor = personTypeColor(person.type);
    final hasBalance = person.openingBalance > 0;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetail(context, person),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: typeColor.withValues(alpha: 0.14),
                child: Icon(
                  personTypeIcon(person.type),
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Name + phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            person.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (person.isFavorite) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                        ],
                        if (person.isArchived) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.archive_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _TypeBadge(type: person.type, color: typeColor),
                        if (person.phone != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              person.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Balance
              if (hasBalance)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatBalance(person),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: person.openingBalanceDirection ==
                                OpeningBalanceDirection.receive
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                    Text(
                      person.openingBalanceDirection.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Empty state
  // --------------------------------------------------------------------------

  Widget _buildEmptyState({required bool hasFilters}) {
    if (hasFilters) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'No matching people',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No people yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add customers, suppliers, friends, and family\nto track your financial relationships.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Filter chip builder
  // --------------------------------------------------------------------------

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Sort helpers
  // --------------------------------------------------------------------------

  PopupMenuItem<_SortOption> _sortItem(_SortOption option, String label) {
    return PopupMenuItem(
      value: option,
      child: Text(label),
    );
  }

  // --------------------------------------------------------------------------
  // Formatting
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // Form actions
  // --------------------------------------------------------------------------

  void _openAddForm(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const PersonFormSheet(),
    );
  }

  void _openDetail(BuildContext context, Person person) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonDetailPage(personId: person.id),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Formatting
  // --------------------------------------------------------------------------

  String _formatBalance(Person person) {
    final amount = person.openingBalance / 100;
    return '${person.currency} ${amount.toStringAsFixed(2)}';
  }
}

// ----------------------------------------------------------------------------
// Shared widgets
// ----------------------------------------------------------------------------

/// Colored badge showing the person's type label.
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.color});

  final PersonType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Sort option for the popup menu.
class _SortOption {
  const _SortOption(this.field, this.direction);

  final PeopleSortField field;
  final PeopleSortDirection direction;
}

const _sortOptionNameAsc = _SortOption(
  PeopleSortField.name,
  PeopleSortDirection.ascending,
);
const _sortOptionNameDesc = _SortOption(
  PeopleSortField.name,
  PeopleSortDirection.descending,
);
const _sortOptionNewest = _SortOption(
  PeopleSortField.createdAt,
  PeopleSortDirection.descending,
);
const _sortOptionOldest = _SortOption(
  PeopleSortField.createdAt,
  PeopleSortDirection.ascending,
);
const _sortOptionBalanceAsc = _SortOption(
  PeopleSortField.balance,
  PeopleSortDirection.ascending,
);
const _sortOptionBalanceDesc = _SortOption(
  PeopleSortField.balance,
  PeopleSortDirection.descending,
);
