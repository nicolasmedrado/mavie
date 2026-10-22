import 'package:dio/dio.dart';
import '../models/movie_details_model.dart';
import '../models/movie_summary_model.dart';

class MovieRemoteDataSource {
  final Dio dio;

  MovieRemoteDataSource(this.dio);

  Future<MovieDetailsModel> getMovieDetails(int id) async {
    final response = await dio.get('/movie/$id');
    return MovieDetailsModel.fromJson(response.data);
  }

  Future<List<MovieSummaryModel>> searchMovies(String query) async {
    final response = await dio.get(
      '/search/movie',
      queryParameters: {'query': query},
    );

    final List<dynamic> results = response.data['results'];
    return results.map((json) => MovieSummaryModel.fromJson(json)).toList();
  }
}
