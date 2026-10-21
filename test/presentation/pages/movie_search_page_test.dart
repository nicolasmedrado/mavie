import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/data/providers/providers.dart';
import 'package:mavie/domain/entities/movie.dart';
import 'package:mavie/domain/repositories/movie_repository.dart';
import 'package:mavie/presentation/pages/movie_details_page.dart';
import 'package:mavie/presentation/pages/movie_search_page.dart';

class _FakeMovieRepository implements MovieRepository {
  _FakeMovieRepository(this.movies);

  final List<Movie> movies;
  int searchCallCount = 0;

  @override
  Future<Movie> getMovieDetails(int id) async {
    return movies.firstWhere((movie) => movie.id == id);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    searchCallCount++;
    return movies;
  }
}

void main() {
  final fakeMovies = [
    Movie(
      id: 603,
      title: 'The Matrix',
      overview: 'A hacker discovers reality is a simulation.',
    ),
    Movie(
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
  });
}
