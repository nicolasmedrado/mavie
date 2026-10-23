import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/router/app_routes.dart';
import 'package:mavie/core/widgets/app_error_view.dart';
import 'package:mavie/core/widgets/app_loading_indicator.dart';
import 'package:mavie/core/widgets/movie_poster.dart';
import 'package:mavie/features/movies/presentation/providers/movie_providers.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
        ),
        // Temporary entry point to /settings (AUTH-06) — the only tab with
        // a real app bar today. Moves to a permanent home once one exists
        // (likely Home's app bar, HOME-01).
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTooltip,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: resultsAsync.when(
        data: (movies) {
          if (movies.isEmpty) {
            return Center(child: Text(l10n.searchEmptyPrompt));
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
                onTap: () => context.push(AppRoutes.movieDetails(movie.id)),
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
