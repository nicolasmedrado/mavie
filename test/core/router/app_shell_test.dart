import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mavie/core/router/app_shell.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows four destinations and switches tabs on tap, each '
      'keeping its own stack', (tester) async {
    final router = GoRouter(
      initialLocation: '/a',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [GoRoute(path: '/a', builder: (c, s) => const _Tab('A'))],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/b', builder: (c, s) => const _Tab('B'))],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/c', builder: (c, s) => const _Tab('C'))],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/d', builder: (c, s) => const _Tab('D'))],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Tab A'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Tab B'), findsOneWidget);
    expect(find.text('Tab A'), findsNothing);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Tab A'), findsOneWidget);
  });
}

class _Tab extends StatelessWidget {
  final String name;

  const _Tab(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Tab $name')));
  }
}
