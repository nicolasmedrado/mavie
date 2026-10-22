import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:mavie/features/movies/data/repositories/movie_repository_impl.dart';

import '../../../../support/fakes/fake_http_adapter.dart';

void main() {
  test('searchMovies rethrows a connection error as NetworkFailure', () async {
    final dio = Dio()
      ..httpClientAdapter = FakeHttpAdapter(
        exception: (options) => DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
    final repository = MovieRepositoryImpl(MovieRemoteDataSource(dio));

    await expectLater(
      () => repository.searchMovies('matrix'),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('getMovieDetails rethrows a 404 response as NotFoundFailure', () async {
    final dio = Dio()
      ..httpClientAdapter = FakeHttpAdapter(
        exception: (options) => DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 404),
        ),
      );
    final repository = MovieRepositoryImpl(MovieRemoteDataSource(dio));

    await expectLater(
      () => repository.getMovieDetails(603),
      throwsA(isA<NotFoundFailure>()),
    );
  });
}
