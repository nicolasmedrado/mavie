import 'package:flutter/material.dart';
import 'package:mavie/core/theme/app_theme.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mavie',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MovieSearchPage(),
    );
  }
}
