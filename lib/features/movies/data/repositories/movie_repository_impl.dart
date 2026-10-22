import '../../domain/entities/movie_details.dart';
import '../../domain/entities/movie_summary.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<MovieDetails> getMovieDetails(int id) async {
    final model = await remoteDataSource.getMovieDetails(id);
    return model.toEntity();
  }

  @override
  Future<List<MovieSummary>> searchMovies(String query) async {
    final models = await remoteDataSource.searchMovies(query);
    return models.map((model) => model.toEntity()).toList();
  }
}
