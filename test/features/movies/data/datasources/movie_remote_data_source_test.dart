import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/movies/data/datasources/movie_remote_data_source.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responseBody);

  final Map<String, dynamic> responseBody;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(responseBody),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('searchMovies sends the query and unwraps the results array', () async {
    final adapter = _FakeAdapter({
      'results': [
        {'id': 603, 'title': 'The Matrix', 'overview': 'overview text'},
      ],
    });
    final dio = Dio()..httpClientAdapter = adapter;
    final dataSource = MovieRemoteDataSource(dio);

    final movies = await dataSource.searchMovies('matrix');

    expect(movies, hasLength(1));
    expect(movies.first.title, 'The Matrix');
    expect(adapter.lastRequest?.path, '/search/movie');
    expect(adapter.lastRequest?.queryParameters['query'], 'matrix');
  });
}
