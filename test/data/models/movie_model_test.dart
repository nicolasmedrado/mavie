import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/data/models/movie_model.dart';

void main() {
  test('fromJson parses the fields TMDB returns', () {
    final model = MovieModel.fromJson({
      'id': 603,
      'title': 'The Matrix',
      'overview': 'A computer hacker learns the truth about reality.',
    });

    expect(model.id, 603);
    expect(model.title, 'The Matrix');
    expect(model.overview, 'A computer hacker learns the truth about reality.');
  });

  test('toEntity maps the model fields onto a Movie entity', () {
    final model = MovieModel(id: 1, title: 'Title', overview: 'Overview');

    final entity = model.toEntity();

    expect(entity.id, 1);
    expect(entity.title, 'Title');
    expect(entity.overview, 'Overview');
  });
}
