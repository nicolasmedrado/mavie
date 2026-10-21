import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/data/providers/providers.dart';
import 'package:mavie/domain/entities/movie.dart';

final movieDetailsProvider = FutureProvider.family<Movie, int>((
  ref,
  movieId,
) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getMovieDetails(movieId);
});

class MovieSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final movieSearchQueryProvider =
    NotifierProvider<MovieSearchQueryNotifier, String>(
      MovieSearchQueryNotifier.new,
    );

final movieSearchResultsProvider = FutureProvider<List<Movie>>((ref) async {
  final query = ref.watch(movieSearchQueryProvider);

  if (query.trim().isEmpty) {
    return [];
  }

  final repository = ref.watch(movieRepositoryProvider);
  return repository.searchMovies(query);
});
