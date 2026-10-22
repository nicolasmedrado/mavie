import 'movie_summary.dart';

class MovieDetails {
  final MovieSummary summary;
  final String? backdropPath;
  final int? runtimeMinutes;
  final List<String> genres;
  final String? originalTitle;

  const MovieDetails({
    required this.summary,
    this.backdropPath,
    this.runtimeMinutes,
    this.genres = const [],
    this.originalTitle,
  });

  int get id => summary.id;
  String get title => summary.title;
  String get overview => summary.overview;
  String? get posterPath => summary.posterPath;
  double get voteAverage => summary.voteAverage;
  String? get releaseDate => summary.releaseDate;

  MovieDetails copyWith({
    MovieSummary? summary,
    String? backdropPath,
    int? runtimeMinutes,
    List<String>? genres,
    String? originalTitle,
  }) {
    return MovieDetails(
      summary: summary ?? this.summary,
      backdropPath: backdropPath ?? this.backdropPath,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      genres: genres ?? this.genres,
      originalTitle: originalTitle ?? this.originalTitle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieDetails &&
          runtimeType == other.runtimeType &&
          summary == other.summary &&
          backdropPath == other.backdropPath &&
          runtimeMinutes == other.runtimeMinutes &&
          _listEquals(genres, other.genres) &&
          originalTitle == other.originalTitle;

  @override
  int get hashCode => Object.hash(
    summary,
    backdropPath,
    runtimeMinutes,
    Object.hashAll(genres),
    originalTitle,
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
