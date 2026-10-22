class MovieSummary {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;

  const MovieSummary({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.voteAverage = 0,
    this.releaseDate,
  });

  MovieSummary copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    double? voteAverage,
    String? releaseDate,
  }) {
    return MovieSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          overview == other.overview &&
          posterPath == other.posterPath &&
          voteAverage == other.voteAverage &&
          releaseDate == other.releaseDate;

  @override
  int get hashCode =>
      Object.hash(id, title, overview, posterPath, voteAverage, releaseDate);
}
