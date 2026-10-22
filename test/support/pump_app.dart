import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

final _appKey = GlobalKey();

/// Wraps [child] in a `ProviderScope` and a localized `MaterialApp`, so
/// widget tests can assert against `l10n.*` instead of a hardcoded
/// language literal.
///
/// Riverpod's own automatic retry is disabled by default — it masks a
/// failed provider behind `AsyncLoading` for up to ~38s before `error`
/// ever fires (see `architecture/overview.md`). Pass a real [retry] to
/// opt back in for a test that specifically exercises it.
///
/// Pass [routes] when the test needs real `go_router` navigation (e.g.
/// asserting `context.push` lands on the right screen) — [child] becomes
/// the `/` route, pumped under a real `GoRouter` alongside [routes]
/// instead of a plain `MaterialApp`'s `home`.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('pt'),
  Duration? Function(int retryCount, Object error)? retry = _noAutoRetry,
  List<RouteBase>? routes,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: retry,
      overrides: overrides,
      child: routes == null
          ? MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(key: _appKey, builder: (context) => child),
            )
          : MaterialApp.router(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: GoRouter(
                initialLocation: '/',
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) =>
                        Builder(key: _appKey, builder: (context) => child),
                  ),
                  ...routes,
                ],
              ),
            ),
    ),
  );
}

/// Resolves `AppLocalizations` from the tree [pumpApp] just built.
AppLocalizations l10nOf(WidgetTester tester) {
  return AppLocalizations.of(tester.element(find.byKey(_appKey)))!;
}

Duration? _noAutoRetry(int retryCount, Object error) => null;
