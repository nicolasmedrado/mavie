import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/movies/data/datasources/movie_remote_data_source.dart';

import '../../../../support/fakes/fake_http_adapter.dart';

void main() {
  test('searchMovies sends the query and unwraps the results array', () async {
    final adapter = FakeHttpAdapter(
      responseBody: {
        'results': [
          {'id': 603, 'title': 'The Matrix', 'overview': 'overview text'},
        ],
      },
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final dataSource = MovieRemoteDataSource(dio);

    final movies = await dataSource.searchMovies('matrix');

    expect(movies, hasLength(1));
    expect(movies.first.title, 'The Matrix');
    expect(adapter.lastRequest?.path, '/search/movie');
    expect(adapter.lastRequest?.queryParameters['query'], 'matrix');
  });
}
