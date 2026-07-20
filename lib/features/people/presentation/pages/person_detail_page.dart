import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/person.dart';
import '../providers/people_providers.dart';
import '../widgets/person_visuals.dart';

/// Person detail/profile screen.
///
/// Displays full person information with placeholders for future
/// ledger history, reminders, and sharing.
class PersonDetailPage extends ConsumerWidget {
  const PersonDetailPage({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personByIdProvider(personId));

    return personAsync.when(
      loading: () => _scaffold(context, const Center(
        child: LoadingWidget(message: 'Loading person...'),
      )),
      error: (err, _) => _scaffold(context, Center(
        child: AppErrorWidget(title: 'Could not load person', details: err.toString()),
      )),
      data: (person) {
        if (person == null) {
          return _scaffold(context, const Center(
            child: AppErrorWidget(title: 'Person not found'),
          ));
        }
        return _PersonContentView(person: person);
      },
    );
  }

  Widget _scaffold(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

class _PersonContentView extends StatelessWidget {
  const _PersonContentView({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = personTypeColor(person.type);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: isWide
          ? _buildWideLayout(context, theme, typeColor)
          : _buildNarrowLayout(context, theme, typeColor),
    );
  }

  // --------------------------------------------------------------------------
  // Narrow (phone)
  // --------------------------------------------------------------------------

  Widget _buildNarrowLayout(
      BuildContext context, ThemeData theme, Color typeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, theme, typeColor),
        const SizedBox(height: 20),
        _buildInfoCards(context, theme, typeColor),
        const SizedBox(height: 20),
        _buildNotesSection(context, theme),
        const SizedBox(height: 20),
        _buildPlaceholders(context, theme),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Wide (tablet)
  // --------------------------------------------------------------------------

  Widget _buildWideLayout(
      BuildContext context, ThemeData theme, Color typeColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeader(context, theme, typeColor),
              const SizedBox(height: 20),
              _buildNotesSection(context, theme),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildInfoCards(context, theme, typeColor),
              const SizedBox(height: 20),
              _buildPlaceholders(context, theme),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Header: photo, name, type, actions
  // --------------------------------------------------------------------------

  Widget _buildHeader(
      BuildContext context, ThemeData theme, Color typeColor) {
    return Center(
      child: Column(
        children: [
          // Photo
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: typeColor.withValues(alpha: 0.14),
                child: Icon(
                  personTypeIcon(person.type),
                  size: 48,
                  color: typeColor,
                ),
              ),
              if (person.isFavorite)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star, size: 20, color: Colors.amber.shade600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            person.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              person.type.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: typeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Phone
          if (person.phone != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(person.phone!, style: theme.textTheme.bodyMedium),
              ],
            ),

          // Email
          if (person.email != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(person.email!, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Info cards
  // --------------------------------------------------------------------------

  Widget _buildInfoCards(
      BuildContext context, ThemeData theme, Color typeColor) {
    return Column(
      children: [
        // Balance row
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Opening Balance',
                value: person.openingBalance > 0
                    ? '${person.currency} ${(person.openingBalance / 100).toStringAsFixed(2)}'
                    : 'None set',
                valueColor: person.openingBalance > 0
                    ? (person.openingBalanceDirection ==
                            OpeningBalanceDirection.receive
                        ? Colors.red.shade700
                        : Colors.green.shade700)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.trending_up_outlined,
                label: 'Outstanding',
                value: person.openingBalance > 0
                    ? '${person.currency} ${(person.openingBalance / 100).toStringAsFixed(2)}'
                    : 'Tk 0.00',
                valueColor: person.openingBalance > 0
                    ? (person.openingBalanceDirection ==
                            OpeningBalanceDirection.receive
                        ? Colors.red.shade700
                        : Colors.green.shade700)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Detail row
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.person_outlined,
                label: 'Direction',
                value: person.openingBalance > 0
                    ? person.openingBalanceDirection.label
                    : 'N/A',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.monetization_on_outlined,
                label: 'Currency',
                value: person.currency,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Status row
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.circle_outlined,
                label: 'Status',
                value: person.isActive ? 'Active' : 'Archived',
                valueColor: person.isActive
                    ? Colors.green.shade700
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.star_outline,
                label: 'Favorite',
                value: person.isFavorite ? 'Yes' : 'No',
              ),
            ),
          ],
        ),
        if (person.address != null) ...[
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: person.address!,
          ),
        ],
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Notes
  // --------------------------------------------------------------------------

  Widget _buildNotesSection(BuildContext context, ThemeData theme) {
    if (person.notes == null || person.notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes_outlined,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Notes', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              person.notes!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Placeholder sections
  // --------------------------------------------------------------------------

  Widget _buildPlaceholders(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _PlaceholderSection(
          icon: Icons.swap_vert_outlined,
          title: 'Ledger History',
          subtitle: 'Record and view money given to or received from this person.',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ledger coming in next sprint')),
            );
          },
        ),
        const SizedBox(height: 8),
        _PlaceholderSection(
          icon: Icons.notifications_outlined,
          title: 'Payment Reminders',
          subtitle: 'Set reminders for due payments and received amounts.',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminders coming soon')),
            );
          },
        ),
        const SizedBox(height: 8),
        _PlaceholderSection(
          icon: Icons.share_outlined,
          title: 'Share Statement',
          subtitle: 'Share outstanding balance and ledger history.',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing coming soon')),
            );
          },
        ),
        const SizedBox(height: 8),
        _PlaceholderSection(
          icon: Icons.bar_chart_outlined,
          title: 'Statistics',
          subtitle: 'View monthly trends, totals, and payment patterns.',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Statistics coming soon')),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable card
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder section tile
// ---------------------------------------------------------------------------

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
