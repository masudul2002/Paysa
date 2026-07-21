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
              _Section(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                children: [_ThemeSelectorTile(settings: settings, repo: repo)],
              ),
              gap16,
              _Section(
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
                children: [
                  _SwitchTile(icon: Icons.visibility_off_outlined, title: 'Hide balance on dashboard',
                    value: settings.hideBalance,
                    onChanged: (v) => repo.save(settings.copyWith(hideBalance: v))),
                ],
              ),
              gap16,
              _Section(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                children: [
                  _SwitchTile(icon: Icons.payment_outlined, title: 'Payment reminders',
                    value: settings.notifications.paymentReminders,
                    onChanged: (v) => repo.save(settings.copyWith(notifications: settings.notifications.copyWith(paymentReminders: v)))),
                  _SwitchTile(icon: Icons.receipt_long_outlined, title: 'Ledger reminders',
                    value: settings.notifications.ledgerReminders,
                    onChanged: (v) => repo.save(settings.copyWith(notifications: settings.notifications.copyWith(ledgerReminders: v)))),
                ],
              ),
              gap16,
              _Section(
                icon: Icons.accessibility_new_outlined,
                title: 'Accessibility',
                children: [
                  _SwitchTile(icon: Icons.text_fields, title: 'Large text',
                    value: settings.accessibility.largeText,
                    onChanged: (v) => repo.save(settings.copyWith(accessibility: settings.accessibility.copyWith(largeText: v)))),
                  _SwitchTile(icon: Icons.animation_outlined, title: 'Reduced motion',
                    value: settings.accessibility.reducedMotion,
                    onChanged: (v) => repo.save(settings.copyWith(accessibility: settings.accessibility.copyWith(reducedMotion: v)))),
                ],
              ),
              gap16,
              _Section(
                icon: Icons.info_outlined,
                title: 'About',
                children: [
                  _InfoTile(icon: Icons.tag_outlined, title: 'Version', value: '0.9.0-beta'),
                  _InfoTile(icon: Icons.build_outlined, title: 'Build', value: '1'),
                ],
              ),
              gap32,
            ],
          ),
        ),
      ),
    );
  }
}

const gap16 = SizedBox(height: 16);
const gap32 = SizedBox(height: 32);

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children});
  final IconData icon; final String title; final List<Widget> children;

  @override Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Row(children: [
          Icon(icon, size: 16, color: t.colorScheme.primary),
          const SizedBox(width: 6),
          Text(title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: t.colorScheme.primary)),
        ]),
      ),
      Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: Column(children: children.toList())),
    ]);
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({required this.icon, required this.title, required this.value, required this.onChanged});
  final IconData icon; final String title; final bool value; final ValueChanged<bool> onChanged;
  @override Widget build(BuildContext context) => SwitchListTile(
    secondary: Icon(icon, size: 20), title: Text(title), value: value, onChanged: onChanged, dense: true);
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.value});
  final IconData icon; final String title; final String value;
  @override Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, size: 20), title: Text(title), trailing: Text(value, style: Theme.of(context).textTheme.bodySmall), dense: true);
}

class _ThemeSelectorTile extends StatelessWidget {
  const _ThemeSelectorTile({required this.settings, required this.repo});
  final AppSettings settings; final SettingsRepository repo;

  @override Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.dark_mode_outlined, size: 20),
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
