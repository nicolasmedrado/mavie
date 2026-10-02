import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

Dio createDioClient() {
  final tmdbApiKey = dotenv.env['TMDB_API_KEY'];

  final client = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {'api_key': tmdbApiKey},
      connectTimeout: const Duration(seconds: 8),
    ),
  );

  return client;
}
