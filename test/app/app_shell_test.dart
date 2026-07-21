import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:paysa/app/app_shell.dart';

void main() {
  testWidgets('BottomNavigationBar shows on mobile', (tester) async {
    tester.view.physicalSize = const Size(375, 812); // iPhone-like
    addTearDown(() => tester.view.resetPhysicalSize());
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          ShellRoute(
            builder: (_, __, child) => AppShell(child: child),
            routes: [
              GoRoute(path: '/', builder: (_, __) => const SizedBox()),
            ],
          ),
        ],
      ),
    ));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  test('NavigationItem holds correct data', () {
    final item = NavigationItem(Icons.home, Icons.home_outlined, 'Test');
    expect(item.label, 'Test');
    expect(item.icon, Icons.home);
  });
}
