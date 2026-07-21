import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import 'theme/design_tokens.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final repo = ref.watch(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (settings) => ListView(
            padding: const EdgeInsets.all(DesignTokens.space16),
            children: [
              _Section(title: 'Appearance', children: [
                _ThemeSelectorTile(settings: settings, repo: repo),
              ]),
              const SizedBox(height: 16),
              _Section(title: 'Privacy & Security', children: [
                _SwitchTile(title: 'Hide balance on dashboard', value: settings.hideBalance,
                  onChanged: (v) => repo.save(settings.copyWith(hideBalance: v))),
              ]),
              const SizedBox(height: 16),
              _Section(title: 'Notifications', children: [
                _SwitchTile(title: 'Payment reminders', value: settings.notifications.paymentReminders,
                  onChanged: (v) => repo.save(settings.copyWith(notifications: settings.notifications.copyWith(paymentReminders: v)))),
                _SwitchTile(title: 'Ledger reminders', value: settings.notifications.ledgerReminders,
                  onChanged: (v) => repo.save(settings.copyWith(notifications: settings.notifications.copyWith(ledgerReminders: v)))),
              ]),
              const SizedBox(height: 16),
              _Section(title: 'Accessibility', children: [
                _SwitchTile(title: 'Large text', value: settings.accessibility.largeText,
                  onChanged: (v) => repo.save(settings.copyWith(accessibility: settings.accessibility.copyWith(largeText: v)))),
                _SwitchTile(title: 'Reduced motion', value: settings.accessibility.reducedMotion,
                  onChanged: (v) => repo.save(settings.copyWith(accessibility: settings.accessibility.copyWith(reducedMotion: v)))),
              ]),
              const SizedBox(height: 16),
              _Section(title: 'About', children: [
                _InfoTile(title: 'Version', value: '0.3.0-alpha'),
                _InfoTile(title: 'Build', value: '1'),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title; final List<Widget> children;
  @override Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))),
      Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: Column(children: children.toList())),
    ]);
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({required this.title, required this.value, required this.onChanged});
  final String title; final bool value; final ValueChanged<bool> onChanged;
  @override Widget build(BuildContext context) => SwitchListTile(title: Text(title), value: value, onChanged: onChanged, dense: true);
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});
  final String title; final String value;
  @override Widget build(BuildContext context) => ListTile(title: Text(title), trailing: Text(value, style: Theme.of(context).textTheme.bodySmall), dense: true);
}

class _ThemeSelectorTile extends StatelessWidget {
  const _ThemeSelectorTile({required this.settings, required this.repo});
  final AppSettings settings; final SettingsRepository repo;

  @override Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Theme'),
      trailing: SegmentedButton<ThemeModePreference>(
        segments: const [
          ButtonSegment(value: ThemeModePreference.system, label: Text('System', style: TextStyle(fontSize: 12))),
          ButtonSegment(value: ThemeModePreference.light, label: Text('Light', style: TextStyle(fontSize: 12))),
          ButtonSegment(value: ThemeModePreference.dark, label: Text('Dark', style: TextStyle(fontSize: 12))),
        ],
        selected: {settings.themeMode},
        onSelectionChanged: (v) => repo.save(settings.copyWith(themeMode: v.first)),
        style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ),
    );
  }
}
