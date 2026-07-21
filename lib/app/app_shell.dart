import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AppShell provides the permanent scaffold and responsive navigation.
///
/// Mobile: BottomNavigationBar
/// Tablet/Desktop: NavigationRail
final class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _routes = <String>[
    '/home',       // 0 — Dashboard
    '/accounts',   // 1 — Accounts
    '/people',     // 2 — People
    '/transactions', // 3 — Transactions
    '/reports',    // 4 — Reports
    '/settings',   // 5 — Settings
  ];

  int _indexOfLocation(String location) {
    final idx = _routes.indexWhere((r) => location.startsWith(r));
    return idx < 0 ? 0 : idx;
  }

  void _navigate(BuildContext context, int idx) {
    GoRouter.of(context).go(_routes[idx]);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexOfLocation(location);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    // Navigation items shared across both layouts
    final navItems = <NavigationItem>[
      NavigationItem(Icons.dashboard_outlined, Icons.dashboard, 'Home'),
      NavigationItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Accounts'),
      NavigationItem(Icons.people_outlined, Icons.people, 'People'),
      NavigationItem(Icons.swap_horiz_outlined, Icons.swap_horiz, 'Transactions'),
      NavigationItem(Icons.pie_chart_outline_outlined, Icons.pie_chart_outline, 'Reports'),
      NavigationItem(Icons.settings_outlined, Icons.settings, 'Settings'),
    ];

    if (isWide) {
      // Tablet / Desktop layout with NavigationRail
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: (idx) => _navigate(context, idx),
                labelType: NavigationRailLabelType.all,
                minExtendedWidth: 180,
                destinations: navItems.map((item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: Text(item.label),
                )).toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    // Mobile layout with BottomNavigationBar
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Semantics(
        container: true,
        label: 'Main navigation',
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (idx) => _navigate(context, idx),
          items: navItems.map((item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon),
            label: item.label,
          )).toList(),
        ),
      ),
    );
  }
}

/// Lightweight data holder for navigation items.
final class NavigationItem {
  const NavigationItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
