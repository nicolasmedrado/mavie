import 'package:flutter/material.dart';

/// Overrides merged onto the `ColorScheme`-generated `TextTheme` — never
/// a parallel API. Call sites keep using `Theme.of(context).textTheme.*`.
class AppTypography {
  AppTypography._();

  static const TextTheme overrides = TextTheme(
    headlineSmall: TextStyle(fontWeight: FontWeight.w600),
  );
}
