import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/features/movies/domain/entities/movie_details.dart';
import 'package:mavie/features/movies/domain/entities/movie_summary.dart';
import 'package:mavie/features/movies/presentation/pages/movie_details_page.dart';
import 'package:mavie/features/movies/presentation/providers/movie_providers.dart';

import '../../../../support/fakes/fake_movie_repository.dart';
import '../../../../support/pump_app.dart';

void main() {
  testWidgets('renders year, runtime and genres when TMDB has them', (
    tester,
  ) async {
    const details = MovieDetails(
      summary: MovieSummary(
        id: 603,
        title: 'The Matrix',
        overview: 'overview',
        voteAverage: 8.2,
        releaseDate: '1999-03-30',
      ),
      runtimeMinutes: 136,
      genres: ['Action', 'Science Fiction'],
    );

    await pumpApp(
      tester,
      const MovieDetailsPage(movieId: 603),
      overrides: [
        movieRepositoryProvider.overrideWithValue(
          FakeMovieRepository(details: details),
        ),
      ],
    );
    await tester.pump();

    expect(find.textContaining('1999'), findsOneWidget);
    expect(
      find.textContaining(l10nOf(tester).detailsRuntimeMinutes(136)),
      findsOneWidget,
    );
    expect(find.textContaining('Action, Science Fiction'), findsOneWidget);
  });

  testWidgets('omits the metadata row when TMDB has no runtime or genres', (
    tester,
  ) async {
    const details = MovieDetails(
      summary: MovieSummary(
        id: 999999,
        title: 'Obscure Short Film',
        overview: 'overview',
      ),
    );

    await pumpApp(
      tester,
      const MovieDetailsPage(movieId: 999999),
      overrides: [
        movieRepositoryProvider.overrideWithValue(
          FakeMovieRepository(details: details),
        ),
      ],
    );
    await tester.pump();

    expect(find.text('Obscure Short Film'), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
  });

  testWidgets('shows AppErrorView with a working retry button on failure', (
    tester,
  ) async {
    final repository = FakeMovieRepository(
      detailsFailure: const NotFoundFailure(),
    );
    await pumpApp(
      tester,
      const MovieDetailsPage(movieId: 603),
      overrides: [movieRepositoryProvider.overrideWithValue(repository)],
    );
    final l10n = l10nOf(tester);
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.errorNotFound), findsOneWidget);
    expect(repository.getMovieDetailsCallCount, 1);

    await tester.tap(find.widgetWithText(FilledButton, l10n.retryButton));
    await tester.pump();
    await tester.pump();

    expect(repository.getMovieDetailsCallCount, 2);
  });
}
