import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/movie_details.dart';
import '../../domain/entities/movie_summary.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<MovieDetails> getMovieDetails(int id) async {
    try {
      final model = await remoteDataSource.getMovieDetails(id);
      return model.toEntity();
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  @override
  Future<List<MovieSummary>> searchMovies(String query) async {
    try {
      final models = await remoteDataSource.searchMovies(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }
}
