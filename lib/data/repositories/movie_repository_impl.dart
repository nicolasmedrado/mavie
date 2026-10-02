import '../../domain/entities/movie.dart';
import '../datasources/movie_remote_data_source.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<Movie> getMovieDetails(int id) async {
    final model = await remoteDataSource.getMovieDetails(id);
    return model.toEntity();
  }
}
