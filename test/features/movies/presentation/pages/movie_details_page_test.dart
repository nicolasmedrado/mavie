import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/movies/domain/entities/movie_details.dart';
import 'package:mavie/features/movies/domain/entities/movie_summary.dart';
import 'package:mavie/features/movies/domain/repositories/movie_repository.dart';
import 'package:mavie/features/movies/presentation/pages/movie_details_page.dart';
import 'package:mavie/features/movies/presentation/providers/movie_providers.dart';

class _FakeMovieRepository implements MovieRepository {
  _FakeMovieRepository(this.details);

  final MovieDetails details;

  @override
  Future<MovieDetails> getMovieDetails(int id) async => details;

  @override
  Future<List<MovieSummary>> searchMovies(String query) async => [];
}

void main() {
  Widget buildTestApp(MovieRepository repository) {
    return ProviderScope(
      overrides: [movieRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: MovieDetailsPage(movieId: 603)),
    );
  }

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

    await tester.pumpWidget(buildTestApp(_FakeMovieRepository(details)));
    await tester.pump();

    expect(find.textContaining('1999'), findsOneWidget);
    expect(find.textContaining('136 min'), findsOneWidget);
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

    await tester.pumpWidget(buildTestApp(_FakeMovieRepository(details)));
    await tester.pump();

    expect(find.text('Obscure Short Film'), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
  });
}
