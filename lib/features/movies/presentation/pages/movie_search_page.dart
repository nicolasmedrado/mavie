import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/widgets/app_error_view.dart';
import 'package:mavie/core/widgets/app_loading_indicator.dart';
import 'package:mavie/core/widgets/movie_poster.dart';
import 'package:mavie/features/movies/presentation/pages/movie_details_page.dart';
import 'package:mavie/features/movies/presentation/providers/movie_providers.dart';

class MovieSearchPage extends ConsumerStatefulWidget {
  const MovieSearchPage({super.key});

  @override
  ConsumerState<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends ConsumerState<MovieSearchPage> {
  Timer? _debounce;

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(movieSearchQueryProvider.notifier).setQuery(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(movieSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar filmes...',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
        ),
      ),
      body: resultsAsync.when(
        data: (movies) {
          if (movies.isEmpty) {
            return const Center(child: Text('Digite algo para buscar'));
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: MoviePoster(
                  posterPath: movie.posterPath,
                  size: MoviePosterSize.thumbnail,
                ),
                title: Text(movie.title),
                subtitle: Text(
                  movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MovieDetailsPage(movieId: movie.id),
                    ),
                  );
                },
              );
            },
          );
        },
        error: (error, stackTrace) => AppErrorView(
          failure: error is AppFailure
              ? error
              : UnknownFailure(error, stackTrace),
          onRetry: () => ref.invalidate(movieSearchResultsProvider),
        ),
        loading: () => const AppLoadingIndicator(),
      ),
    );
  }
}
