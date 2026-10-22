import '../entities/movie_details.dart';
import '../entities/movie_summary.dart';

abstract class MovieRepository {
  Future<MovieDetails> getMovieDetails(int id);

  Future<List<MovieSummary>> searchMovies(String query);
}
