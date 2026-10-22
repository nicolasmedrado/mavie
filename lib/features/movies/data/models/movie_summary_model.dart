import '../../domain/entities/movie_summary.dart';

class MovieSummaryModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;

  MovieSummaryModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.voteAverage = 0,
    this.releaseDate,
  });

  factory MovieSummaryModel.fromJson(Map<String, dynamic> json) {
    return MovieSummaryModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: _nonEmpty(json['release_date'] as String?),
    );
  }

  /// Snake_case, matching the `movies_cache` columns so this can upsert
  /// directly through `set_library_entry` / `add_to_list` (BE-07).
  Map<String, dynamic> toJson() {
    return {
      'tmdb_id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'tmdb_vote_average': voteAverage,
    };
  }

  MovieSummary toEntity() {
    return MovieSummary(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
    );
  }
}

String? _nonEmpty(String? value) =>
    (value == null || value.isEmpty) ? null : value;
