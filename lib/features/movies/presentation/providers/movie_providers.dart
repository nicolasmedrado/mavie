import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/core/network/tmdb_dio.dart';
import 'package:mavie/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:mavie/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:mavie/features/movies/domain/entities/movie_details.dart';
import 'package:mavie/features/movies/domain/entities/movie_summary.dart';
import 'package:mavie/features/movies/domain/repositories/movie_repository.dart';

final tmdbDioProvider = Provider<Dio>((ref) {
  return createDioClient();
});

final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>((ref) {
  final client = ref.watch(tmdbDioProvider);
  return MovieRemoteDataSource(client);
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final dataSource = ref.watch(movieRemoteDataSourceProvider);
  return MovieRepositoryImpl(dataSource);
});

final movieDetailsProvider = FutureProvider.family<MovieDetails, int>((
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

final movieSearchResultsProvider = FutureProvider<List<MovieSummary>>((
  ref,
) async {
  final query = ref.watch(movieSearchQueryProvider);

  if (query.trim().isEmpty) {
    return [];
  }

  final repository = ref.watch(movieRepositoryProvider);
  return repository.searchMovies(query);
});
