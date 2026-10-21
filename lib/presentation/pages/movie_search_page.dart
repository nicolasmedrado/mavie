import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/presentation/pages/movie_details_page.dart';
import 'package:mavie/presentation/providers/movie_providers.dart';

class MovieSearchPage extends ConsumerStatefulWidget {
  const MovieSearchPage({super.key});

  @override
  ConsumerState<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends ConsumerState<MovieSearchPage> {
  Timer? _debounce;

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(movieSearchQueryProvider.notifier).setQuery(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(movieSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar filmes...',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
        ),
      ),
      body: resultsAsync.when(
        data: (movies) {
          if (movies.isEmpty) {
            return const Center(child: Text('Digite algo para buscar'));
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                title: Text(movie.title),
                subtitle: Text(
                  movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MovieDetailsPage(movieId: movie.id),
                    ),
                  );
                },
              );
            },
          );
        },
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
