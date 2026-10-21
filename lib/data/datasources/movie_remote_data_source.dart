import 'package:dio/dio.dart';
import '../models/movie_model.dart';

class MovieRemoteDataSource {
  final Dio dio;

  MovieRemoteDataSource(this.dio);

  Future<MovieModel> getMovieDetails(int id) async {
    final response = await dio.get('/movie/$id');
    return MovieModel.fromJson(response.data);
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    final response = await dio.get(
      '/search/movie',
      queryParameters: {'query': query},
    );

    final List<dynamic> results = response.data['results'];
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }
}
