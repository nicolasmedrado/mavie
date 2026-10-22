import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/features/movies/domain/entities/movie_details.dart';
import 'package:mavie/features/movies/domain/entities/movie_summary.dart';
import 'package:mavie/features/movies/domain/repositories/movie_repository.dart';
import 'package:mavie/features/movies/presentation/pages/movie_details_page.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';
import 'package:mavie/features/movies/presentation/providers/movie_providers.dart';

class _FakeMovieRepository implements MovieRepository {
  _FakeMovieRepository(this.movies);

  final List<MovieSummary> movies;
  int searchCallCount = 0;

  @override
  Future<MovieDetails> getMovieDetails(int id) async {
    return MovieDetails(summary: movies.firstWhere((movie) => movie.id == id));
  }

  @override
  Future<List<MovieSummary>> searchMovies(String query) async {
    searchCallCount++;
    return movies;
  }
}

class _ThrowingMovieRepository implements MovieRepository {
  int searchCallCount = 0;

  @override
  Future<MovieDetails> getMovieDetails(int id) async {
    throw const NetworkFailure();
  }

  @override
  Future<List<MovieSummary>> searchMovies(String query) async {
    searchCallCount++;
    throw const NetworkFailure();
  }
}

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

  Widget buildTestApp(MovieRepository repository) {
    return ProviderScope(
      overrides: [movieRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: MovieSearchPage()),
    );
  }

  testWidgets('shows a prompt before the user searches for anything', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(_FakeMovieRepository(fakeMovies)));
    await tester.pump();

    expect(find.text('Digite algo para buscar'), findsOneWidget);
  });

  testWidgets('debounces typing and only searches once input settles', (
    tester,
  ) async {
    final repository = _FakeMovieRepository(fakeMovies);
    await tester.pumpWidget(buildTestApp(repository));

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
    final repository = _FakeMovieRepository(fakeMovies);
    await tester.pumpWidget(buildTestApp(repository));

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
    final repository = _ThrowingMovieRepository();
    await tester.pumpWidget(
      ProviderScope(
        // Riverpod's own automatic retry (up to 10 attempts) would
        // otherwise mask the error behind AsyncLoading — disabled here to
        // isolate the explicit retry button this issue adds.
        retry: (retryCount, error) => null,
        overrides: [movieRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: MovieSearchPage()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(
      find.text('Sem conexão. Verifique sua internet e tente novamente.'),
      findsOneWidget,
    );
    expect(repository.searchCallCount, 1);

    await tester.tap(find.widgetWithText(FilledButton, 'Tentar novamente'));
    await tester.pump();

    expect(repository.searchCallCount, 2);
  });
}
