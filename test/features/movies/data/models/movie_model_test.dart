import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/movies/data/models/movie_model.dart';

void main() {
  test('fromJson parses the fields TMDB returns', () {
    final model = MovieModel.fromJson({
      'id': 603,
      'title': 'The Matrix',
      'overview': 'A computer hacker learns the truth about reality.',
      'poster_path': '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
      'vote_average': 8.7,
    });

    expect(model.id, 603);
    expect(model.title, 'The Matrix');
    expect(model.overview, 'A computer hacker learns the truth about reality.');
    expect(model.posterPath, '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg');
    expect(model.voteAverage, 8.7);
  });

  test('fromJson defaults poster and rating when TMDB omits them', () {
    final model = MovieModel.fromJson({
      'id': 603,
      'title': 'The Matrix',
      'overview': 'overview',
    });

    expect(model.posterPath, isNull);
    expect(model.voteAverage, 0);
  });

  test('toEntity maps the model fields onto a Movie entity', () {
    final model = MovieModel(
      id: 1,
      title: 'Title',
      overview: 'Overview',
      posterPath: '/poster.jpg',
      voteAverage: 7.2,
    );

    final entity = model.toEntity();

    expect(entity.id, 1);
    expect(entity.title, 'Title');
    expect(entity.overview, 'Overview');
    expect(entity.posterPath, '/poster.jpg');
    expect(entity.voteAverage, 7.2);
  });
}
