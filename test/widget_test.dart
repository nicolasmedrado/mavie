import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/app/app.dart';
import 'package:mavie/core/l10n/locale_provider.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('app launches straight into the movie search screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // Pinned so the assertion doesn't depend on the test runner's
        // host locale.
        overrides: [localeProvider.overrideWithValue(const Locale('pt'))],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MovieSearchPage)),
    )!;
    expect(find.text(l10n.searchHint), findsOneWidget);
  });
}
