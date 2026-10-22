import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/movies/data/models/movie_details_model.dart';

void main() {
  late Map<String, dynamic> detailsFixture;
  late Map<String, dynamic> minimalFixture;

  setUpAll(() {
    detailsFixture = jsonDecode(
      File('test/support/fixtures/movie_details.json').readAsStringSync(),
    );
    minimalFixture = jsonDecode(
      File(
        'test/support/fixtures/movie_details_minimal.json',
      ).readAsStringSync(),
    );
  });

  test('fromJson parses every field TMDB returns', () {
    final model = MovieDetailsModel.fromJson(detailsFixture);

    expect(model.summary.id, 603);
    expect(model.summary.title, 'The Matrix');
    expect(model.summary.releaseDate, '1999-03-30');
    expect(model.summary.voteAverage, 8.2);
    expect(model.originalTitle, 'The Matrix');
    expect(model.backdropPath, '/fNG7i7RqMErkcqhohV2a6cV1Ehy.jpg');
    expect(model.runtimeMinutes, 136);
    expect(model.genres, ['Action', 'Science Fiction']);
  });

  test('fromJson omits runtime and genres when TMDB has neither, no crash', () {
    final model = MovieDetailsModel.fromJson(minimalFixture);

    expect(model.runtimeMinutes, isNull);
    expect(model.genres, isEmpty);
    expect(model.summary.releaseDate, isNull);
    expect(model.backdropPath, isNull);
  });

  test(
    'toJson produces a movies_cache-shaped payload mirroring the fixture',
    () {
      final model = MovieDetailsModel.fromJson(detailsFixture);
      final json = model.toJson();

      expect(json['tmdb_id'], detailsFixture['id']);
      expect(json['title'], detailsFixture['title']);
      expect(json['original_title'], detailsFixture['original_title']);
      expect(json['backdrop_path'], detailsFixture['backdrop_path']);
      expect(json['runtime_minutes'], detailsFixture['runtime']);
      expect(json['genres'], ['Action', 'Science Fiction']);
    },
  );

  test('toEntity maps the model fields onto a MovieDetails entity', () {
    final model = MovieDetailsModel.fromJson(detailsFixture);
    final entity = model.toEntity();

    expect(entity.id, 603);
    expect(entity.title, 'The Matrix');
    expect(entity.originalTitle, 'The Matrix');
    expect(entity.backdropPath, '/fNG7i7RqMErkcqhohV2a6cV1Ehy.jpg');
    expect(entity.runtimeMinutes, 136);
    expect(entity.genres, ['Action', 'Science Fiction']);
  });
}
