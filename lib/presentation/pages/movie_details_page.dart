import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/presentation/providers/movie_providers.dart';

class MovieDetailsPage extends ConsumerWidget {
  const MovieDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do filme')),
      body: movieAsync.when(
        data: (movie) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(movie.title), Text(movie.overview)],
        ),
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
        loading: () => Center(child: const CircularProgressIndicator()),
      ),
    );
  }
}
