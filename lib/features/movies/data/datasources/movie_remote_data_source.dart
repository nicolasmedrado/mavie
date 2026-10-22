import 'package:dio/dio.dart';
import '../models/movie_details_model.dart';
import '../models/movie_summary_model.dart';

class MovieRemoteDataSource {
  final Dio dio;

  MovieRemoteDataSource(this.dio);

  Future<MovieDetailsModel> getMovieDetails(int id) async {
    final response = await dio.get<Map<String, dynamic>>('/movie/$id');
    return MovieDetailsModel.fromJson(response.data!);
  }

  Future<List<MovieSummaryModel>> searchMovies(String query) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/search/movie',
      queryParameters: {'query': query},
    );

    final results = response.data!['results'] as List<dynamic>;
    return results
        .map((json) => MovieSummaryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
