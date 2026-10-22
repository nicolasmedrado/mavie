import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/movies/data/models/movie_summary_model.dart';

void main() {
  late Map<String, dynamic> searchResultFixture;

  setUpAll(() {
    final raw = File(
      'test/support/fixtures/tmdb_search_result.json',
    ).readAsStringSync();
    searchResultFixture =
        (jsonDecode(raw)['results'] as List).first as Map<String, dynamic>;
  });

  test('fromJson parses the fields TMDB returns', () {
    final model = MovieSummaryModel.fromJson(searchResultFixture);

    expect(model.id, 603);
    expect(model.title, 'The Matrix');
    expect(
      model.overview,
      'Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.',
    );
    expect(model.posterPath, '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg');
    expect(model.voteAverage, 8.2);
    expect(model.releaseDate, '1999-03-30');
  });

  test(
    'fromJson defaults poster, rating and release date when TMDB omits them',
    () {
      final model = MovieSummaryModel.fromJson({
        'id': 603,
        'title': 'The Matrix',
        'overview': 'overview',
      });

      expect(model.posterPath, isNull);
      expect(model.voteAverage, 0);
      expect(model.releaseDate, isNull);
    },
  );

  test('fromJson treats an empty release date as absent', () {
    final model = MovieSummaryModel.fromJson({
      'id': 603,
      'title': 'The Matrix',
      'overview': 'overview',
      'release_date': '',
    });

    expect(model.releaseDate, isNull);
  });

  test('toEntity maps the model fields onto a MovieSummary entity', () {
    final model = MovieSummaryModel(
      id: 1,
      title: 'Title',
      overview: 'Overview',
      posterPath: '/poster.jpg',
      voteAverage: 7.2,
      releaseDate: '2020-01-01',
    );

    final entity = model.toEntity();

    expect(entity.id, 1);
    expect(entity.title, 'Title');
    expect(entity.overview, 'Overview');
    expect(entity.posterPath, '/poster.jpg');
    expect(entity.voteAverage, 7.2);
    expect(entity.releaseDate, '2020-01-01');
  });

  test(
    'toJson produces a movies_cache-shaped payload mirroring the fixture',
    () {
      final model = MovieSummaryModel.fromJson(searchResultFixture);
      final json = model.toJson();

      expect(json['tmdb_id'], searchResultFixture['id']);
      expect(json['title'], searchResultFixture['title']);
      expect(json['overview'], searchResultFixture['overview']);
      expect(json['poster_path'], searchResultFixture['poster_path']);
      expect(json['release_date'], searchResultFixture['release_date']);
      expect(json['tmdb_vote_average'], searchResultFixture['vote_average']);
    },
  );
}
