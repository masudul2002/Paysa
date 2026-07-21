import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/design_tokens.dart';

/// Multi-step onboarding for first-time users.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top right)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: _currentPage < _pages.length - 1
                      ? () => _finish(context)
                      : null,
                  child: Text(_currentPage < _pages.length - 1 ? 'Skip' : ''),
                ),
              ]),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages.map((page) => _OnboardingPage(
                  icon: page.icon,
                  title: page.title,
                  subtitle: page.subtitle,
                )).toList(),
              ),
            ),

            // Bottom bar
            Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) => AnimatedContainer(
                    duration: DesignTokens.durationFast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? t.colorScheme.primary
                          : t.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 20),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: DesignTokens.minTouchSize,
                  child: FilledButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageCtrl.nextPage(
                          duration: DesignTokens.durationNormal,
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finish(context);
                      }
                    },
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Continue' : 'Get Started',
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _finish(BuildContext context) {
    GoRouter.of(context).go('/home');
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.icon, required this.title, required this.subtitle});
  final IconData icon; final String title; final String subtitle;

  @override Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: t.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(icon, size: 60, color: t.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 32),
          Text(title, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(subtitle, style: t.textTheme.bodyLarge?.copyWith(
            color: t.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

final _pages = [
  _PageData(Icons.account_balance_wallet_rounded, 'Welcome to Paysa',
      'Your all-in-one finance & ledger platform. Track money, manage budgets, and achieve financial goals — all offline.'),
  _PageData(Icons.swap_vert_rounded, 'Track Everything',
      'Income, expenses, transfers, lending, borrowing, and customer/supplier ledgers. One app for personal and business finance.'),
  _PageData(Icons.security_rounded, 'Your Data Stays Yours',
      'Offline-first means your financial data lives on your device. No cloud required. Back up when you choose.'),
];

final class _PageData {
  const _PageData(this.icon, this.title, this.subtitle);
  final IconData icon; final String title; final String subtitle;
}
