import '../../domain/entities/movie.dart';

class MovieModel {
  final int id;
  final String title;
  final String overview;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview
    });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      );
  }

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
    );
  }
}