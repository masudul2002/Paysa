import 'package:flutter/material.dart';
import 'theme/design_tokens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: textTheme.headlineSmall),
              const SizedBox(height: DesignTokens.spacingMd),
              ListTile(
                title: const Text('Appearance'),
                subtitle: const Text('System theme, light, dark (coming soon)'),
                onTap: null,
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              ListTile(
                title: const Text('About'),
                subtitle: const Text('App info (coming soon)'),
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
