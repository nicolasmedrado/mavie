import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/router/app_routes.dart';
import 'package:mavie/features/movies/domain/entities/movie_summary.dart';
import 'package:mavie/features/movies/presentation/pages/movie_details_page.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';
import 'package:mavie/features/movies/presentation/providers/movie_providers.dart';

import '../../../../support/fakes/fake_movie_repository.dart';
import '../../../../support/pump_app.dart';

void main() {
  final fakeMovies = [
    MovieSummary(
      id: 603,
      title: 'The Matrix',
      overview: 'A hacker discovers reality is a simulation.',
      voteAverage: 8.7,
    ),
    MovieSummary(
      id: 604,
      title: 'The Matrix Reloaded',
      overview: 'Neo fights more agents.',
    ),
  ];

  testWidgets('shows a prompt before the user searches for anything', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const MovieSearchPage(),
      overrides: [
        movieRepositoryProvider.overrideWithValue(
          FakeMovieRepository(searchResults: fakeMovies),
        ),
      ],
    );
    await tester.pump();

    expect(find.text(l10nOf(tester).searchEmptyPrompt), findsOneWidget);
  });

  testWidgets('renders in English and in Portuguese, from the same keys', (
    tester,
  ) async {
    for (final locale in [const Locale('en'), const Locale('pt')]) {
      await pumpApp(
        tester,
        const MovieSearchPage(),
        overrides: [
          movieRepositoryProvider.overrideWithValue(
            FakeMovieRepository(searchResults: fakeMovies),
          ),
        ],
        locale: locale,
      );
      await tester.pump();

      expect(find.text(l10nOf(tester).searchEmptyPrompt), findsOneWidget);
    }
  });

  testWidgets('debounces typing and only searches once input settles', (
    tester,
  ) async {
    final repository = FakeMovieRepository(searchResults: fakeMovies);
    await pumpApp(
      tester,
      const MovieSearchPage(),
      overrides: [movieRepositoryProvider.overrideWithValue(repository)],
    );

    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.pump(const Duration(milliseconds: 100));
    expect(repository.searchCallCount, 0);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(repository.searchCallCount, 1);
    expect(find.text('The Matrix'), findsOneWidget);
    expect(find.text('The Matrix Reloaded'), findsOneWidget);
  });

  testWidgets('tapping a result opens its details screen', (tester) async {
    final repository = FakeMovieRepository(searchResults: fakeMovies);
    await pumpApp(
      tester,
      const MovieSearchPage(),
      overrides: [movieRepositoryProvider.overrideWithValue(repository)],
      routes: [
        GoRoute(
          path: AppRoutes.movieDetailsPattern,
          builder: (context, state) =>
              MovieDetailsPage(movieId: int.parse(state.pathParameters['id']!)),
        ),
      ],
    );

    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    await tester.tap(find.text('The Matrix'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieDetailsPage), findsOneWidget);
    expect(
      find.text('A hacker discovers reality is a simulation.'),
      findsOneWidget,
    );
    expect(find.text('8.7'), findsOneWidget);
  });

  testWidgets('shows AppErrorView with a working retry button on failure', (
    tester,
  ) async {
    final repository = FakeMovieRepository(
      searchFailure: const NetworkFailure(),
    );
    await pumpApp(
      tester,
      const MovieSearchPage(),
      overrides: [movieRepositoryProvider.overrideWithValue(repository)],
    );
    final l10n = l10nOf(tester);

    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text(l10n.errorNetwork), findsOneWidget);
    expect(repository.searchCallCount, 1);

    await tester.tap(find.widgetWithText(FilledButton, l10n.retryButton));
    await tester.pump();

    expect(repository.searchCallCount, 2);
  });
}
