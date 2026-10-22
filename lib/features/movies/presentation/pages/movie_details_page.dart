import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/theme/app_spacing.dart';
import 'package:mavie/core/widgets/app_error_view.dart';
import 'package:mavie/core/widgets/app_loading_indicator.dart';
import 'package:mavie/core/widgets/movie_poster.dart';
import 'package:mavie/core/widgets/rating_display.dart';
import 'package:mavie/features/movies/presentation/providers/movie_providers.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

class MovieDetailsPage extends ConsumerWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailsProvider(movieId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.detailsTitle)),
      body: movieAsync.when(
        data: (movie) {
          final year =
              movie.releaseDate != null && movie.releaseDate!.length >= 4
              ? movie.releaseDate!.substring(0, 4)
              : null;
          final metadataParts = [
            ?year,
            if (movie.runtimeMinutes != null)
              l10n.detailsRuntimeMinutes(movie.runtimeMinutes!),
            if (movie.genres.isNotEmpty) movie.genres.join(', '),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoviePoster(
                  posterPath: movie.posterPath,
                  size: MoviePosterSize.hero,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (metadataParts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    metadataParts.join(' · '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                RatingDisplay(rating: movie.voteAverage),
                const SizedBox(height: AppSpacing.md),
                Text(movie.overview),
              ],
            ),
          );
        },
        error: (error, stackTrace) => AppErrorView(
          failure: error is AppFailure
              ? error
              : UnknownFailure(error, stackTrace),
          onRetry: () => ref.invalidate(movieDetailsProvider(movieId)),
        ),
        loading: () => const AppLoadingIndicator(),
      ),
    );
  }
}
