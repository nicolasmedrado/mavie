import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/data/providers/providers.dart';
import 'package:mavie/domain/entities/movie.dart';

final movieDetailsProvider = FutureProvider<Movie>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getMovieDetails(550);
});
