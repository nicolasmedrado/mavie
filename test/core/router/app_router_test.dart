import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/router/app_router.dart';
import 'package:mavie/core/widgets/splash_page.dart';
import 'package:mavie/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/fakes/fake_auth_state.dart';

/// Not pumpAndSettle(): SplashPage's CircularProgressIndicator animates
/// forever, so any scenario that can pass through it would time out
/// waiting to settle. A handful of ticks is enough for the stream to
/// deliver, `ref.listen` to notify, and go_router to re-run `redirect`.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump();
  }
}

Future<ProviderContainer> _pumpRouter(
  WidgetTester tester, {
  required Stream<AuthState> authStateStream,
}) async {
  final container = ProviderContainer(
    overrides: [authStateProvider.overrideWith((ref) => authStateStream)],
  );
  addTearDown(container.dispose);

  // A Consumer actively `ref.watch`es appRouterProvider, same as MyApp does
  // in app.dart — a one-off `container.read` leaves nothing holding it
  // alive, and its internal `ref.listen(authStateProvider, ...)` goes
  // inert: the stream override never resolves past AsyncLoading, no
  // matter how many frames are pumped.
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          routerConfig: ref.watch(appRouterProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    ),
  );
  await _settle(tester);
  return container;
}

void main() {
  testWidgets('a still-restoring session shows the splash screen', (
    tester,
  ) async {
    await _pumpRouter(tester, authStateStream: const Stream.empty());

    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('signed out, the initial protected route redirects to sign-in', (
    tester,
  ) async {
    await _pumpRouter(
      tester,
      authStateStream: Stream.value(signedOutAuthState),
    );

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.byType(MovieSearchPage), findsNothing);
  });

  testWidgets('signed in, navigating to sign-in bounces back to search', (
    tester,
  ) async {
    final container = await _pumpRouter(
      tester,
      authStateStream: Stream.value(signedInAuthState()),
    );

    container.read(appRouterProvider).go('/sign-in');
    await _settle(tester);

    expect(find.byType(MovieSearchPage), findsOneWidget);
    expect(find.byType(SignInPage), findsNothing);
  });

  testWidgets('reacts to a sign-in event without being told to navigate', (
    tester,
  ) async {
    final controller = StreamController<AuthState>.broadcast();
    addTearDown(controller.close);

    // A broadcast stream drops events added before anything is listening,
    // so the first event goes through `_pumpRouter` itself subscribing —
    // never add() before it.
    await _pumpRouter(tester, authStateStream: controller.stream);

    controller.add(signedOutAuthState);
    await _settle(tester);
    expect(find.byType(SignInPage), findsOneWidget);

    controller.add(signedInAuthState());
    await _settle(tester);

    expect(find.byType(MovieSearchPage), findsOneWidget);
    expect(find.byType(SignInPage), findsNothing);
  });

  testWidgets('reacts to a sign-out event by redirecting to sign-in', (
    tester,
  ) async {
    final controller = StreamController<AuthState>.broadcast();
    addTearDown(controller.close);

    await _pumpRouter(tester, authStateStream: controller.stream);

    controller.add(signedInAuthState());
    await _settle(tester);
    expect(find.byType(MovieSearchPage), findsOneWidget);

    controller.add(signedOutAuthState);
    await _settle(tester);

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.byType(MovieSearchPage), findsNothing);
  });
}
