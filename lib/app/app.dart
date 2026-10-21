import 'package:flutter/material.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mavie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MovieSearchPage(),
    );
  }
}
