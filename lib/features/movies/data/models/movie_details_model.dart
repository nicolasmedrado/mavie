import '../../domain/entities/movie_details.dart';
import 'movie_summary_model.dart';

class MovieDetailsModel {
  final MovieSummaryModel summary;
  final String? backdropPath;
  final int? runtimeMinutes;
  final List<String> genres;
  final String? originalTitle;

  MovieDetailsModel({
    required this.summary,
    this.backdropPath,
    this.runtimeMinutes,
    this.genres = const [],
    this.originalTitle,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    final genresJson = json['genres'] as List<dynamic>?;
    final runtime = (json['runtime'] as num?)?.toInt();

    return MovieDetailsModel(
      summary: MovieSummaryModel.fromJson(json),
      backdropPath: json['backdrop_path'] as String?,
      runtimeMinutes: (runtime == null || runtime == 0) ? null : runtime,
      genres: genresJson == null
          ? const []
          : genresJson.map((genre) => genre['name'] as String).toList(),
      originalTitle: json['original_title'] as String?,
    );
  }

  /// Snake_case, matching the `movies_cache` columns so this can upsert
  /// directly through `set_library_entry` / `add_to_list` (BE-07).
  Map<String, dynamic> toJson() {
    return {
      ...summary.toJson(),
      'original_title': originalTitle,
      'backdrop_path': backdropPath,
      'runtime_minutes': runtimeMinutes,
      'genres': genres,
    };
  }

  MovieDetails toEntity() {
    return MovieDetails(
      summary: summary.toEntity(),
      backdropPath: backdropPath,
      runtimeMinutes: runtimeMinutes,
      genres: genres,
      originalTitle: originalTitle,
    );
  }
}
