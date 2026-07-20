import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../splash_screen.dart';
import '../app_shell.dart';
import '../dashboard_page.dart';
import '../accounts_page.dart';
import '../people_page.dart';
import '../transactions_page.dart';
import '../reports_page.dart';
import '../settings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.dashboard.path,
            name: AppRoute.dashboard.name,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoute.accounts.path,
            name: AppRoute.accounts.name,
            builder: (context, state) => const AccountsPage(),
          ),
          GoRoute(
            path: AppRoute.people.path,
            name: AppRoute.people.name,
            builder: (context, state) => const PeoplePage(),
          ),
          GoRoute(
            path: AppRoute.transactions.path,
            name: AppRoute.transactions.name,
            builder: (context, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: AppRoute.reports.path,
            name: AppRoute.reports.name,
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            name: AppRoute.settings.name,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});

enum AppRoute {
  splash('/splash'),
  dashboard('/home'),
  accounts('/accounts'),
  people('/people'),
  transactions('/transactions'),
  reports('/reports'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
