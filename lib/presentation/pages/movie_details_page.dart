import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/presentation/providers/movie_providers.dart';

class MovieDetailsPage extends ConsumerWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailsProvider(movieId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do filme')),
      body: movieAsync.when(
        data: (movie) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(movie.overview),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
