import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/app/app.dart';
import 'package:mavie/core/l10n/locale_provider.dart';
import 'package:mavie/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

import 'support/fakes/fake_auth_state.dart';

void main() {
  testWidgets('a signed-out cold start lands on sign-in, not search', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWithValue(const Locale('pt')),
          authStateProvider.overrideWith(
            (ref) => Stream.value(signedOutAuthState),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.byType(MovieSearchPage), findsNothing);
  });

  testWidgets('a signed-in cold start launches into the movie search screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // Pinned so the assertion doesn't depend on the test runner's
        // host locale.
        overrides: [
          localeProvider.overrideWithValue(const Locale('pt')),
          authStateProvider.overrideWith(
            (ref) => Stream.value(signedInAuthState()),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MovieSearchPage)),
    )!;
    expect(find.text(l10n.searchHint), findsOneWidget);
  });
}
