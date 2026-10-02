import 'package:dio/dio.dart';
import '../models/movie_model.dart';

class MovieRemoteDataSource {
  final Dio dio;

  MovieRemoteDataSource(this.dio);

  Future<MovieModel> getMovieDetails(int id) async {
    final response = await dio.get('/movie/$id');
    return MovieModel.fromJson(response.data);
  }
}
