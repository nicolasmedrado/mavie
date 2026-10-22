import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mavie/core/network/tmdb_dio.dart';
import 'package:mavie/core/theme/app_colors.dart';
import 'package:mavie/core/theme/app_spacing.dart';

enum MoviePosterSize { thumbnail, card, hero }

/// Takes a `posterPath`, not a `Movie` — used with summaries, details and
/// cache rows, so coupling it to one entity would force conversions at
/// call sites.
class MoviePoster extends StatelessWidget {
  final String? posterPath;
  final MoviePosterSize size;

  const MoviePoster({
    super.key,
    required this.posterPath,
    this.size = MoviePosterSize.card,
  });

  @override
  Widget build(BuildContext context) {
    final (width, height) = _dimensions;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        width: width,
        height: height,
        child: posterPath == null
            ? const _PosterPlaceholder()
            : CachedNetworkImage(
                imageUrl: '$tmdbImageBaseUrl$posterPath',
                fit: BoxFit.cover,
                placeholder: (context, url) => const _PosterPlaceholder(),
                errorWidget: (context, url, error) =>
                    const _PosterPlaceholder(),
              ),
      ),
    );
  }

  (double, double) get _dimensions => switch (size) {
    MoviePosterSize.thumbnail => (
      AppSpacing.posterThumbnailWidth,
      AppSpacing.posterThumbnailHeight,
    ),
    MoviePosterSize.card => (
      AppSpacing.posterCardWidth,
      AppSpacing.posterCardHeight,
    ),
    MoviePosterSize.hero => (
      AppSpacing.posterHeroWidth,
      AppSpacing.posterHeroHeight,
    ),
  };
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.posterPlaceholder,
      child: Icon(Icons.movie_outlined),
    );
  }
}
