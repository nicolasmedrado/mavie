import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/features/movies/domain/entities/movie_details.dart';
import 'package:mavie/features/movies/domain/entities/movie_summary.dart';
import 'package:mavie/features/movies/domain/repositories/movie_repository.dart';

/// A fake drifting from [MovieRepository] is a compile error, which is
/// the point of hand-writing fakes instead of mocking.
class FakeMovieRepository implements MovieRepository {
  FakeMovieRepository({
    this.searchResults = const [],
    this.details,
    this.searchFailure,
    this.detailsFailure,
  });

  final List<MovieSummary> searchResults;
  final MovieDetails? details;
  final AppFailure? searchFailure;
  final AppFailure? detailsFailure;

  int searchCallCount = 0;
  int getMovieDetailsCallCount = 0;

  @override
  Future<List<MovieSummary>> searchMovies(String query) async {
    searchCallCount++;
    if (searchFailure != null) throw searchFailure!;
    return searchResults;
  }

  @override
  Future<MovieDetails> getMovieDetails(int id) async {
    getMovieDetailsCallCount++;
    if (detailsFailure != null) throw detailsFailure!;
    return details ??
        MovieDetails(
          summary: searchResults.firstWhere((movie) => movie.id == id),
        );
  }
}
