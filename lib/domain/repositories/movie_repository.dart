import '../entities/movie.dart';

abstract class MovieRepository {
  Future<Movie> getMovieDetails(int id);
}