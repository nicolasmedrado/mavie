import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/core/network/tmdb_dio.dart';
import 'package:mavie/core/theme/app_colors.dart';
import 'package:mavie/core/theme/app_spacing.dart';
import 'package:mavie/features/movies/presentation/providers/movie_providers.dart';

class MovieDetailsPage extends ConsumerWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailsProvider(movieId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do filme')),
      body: movieAsync.when(
        data: (movie) {
          final year =
              movie.releaseDate != null && movie.releaseDate!.length >= 4
              ? movie.releaseDate!.substring(0, 4)
              : null;
          final metadataParts = [
            ?year,
            if (movie.runtimeMinutes != null) '${movie.runtimeMinutes} min',
            if (movie.genres.isNotEmpty) movie.genres.join(', '),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movie.posterPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Image.network(
                      '$tmdbImageBaseUrl${movie.posterPath}',
                    ),
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
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.rating, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Text(movie.voteAverage.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(movie.overview),
              ],
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
