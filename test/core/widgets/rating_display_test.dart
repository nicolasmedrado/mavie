import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/widgets/rating_display.dart';

void main() {
  testWidgets('rating: 0 renders a real score, distinct from unrated', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RatingDisplay(rating: 0))),
    );

    expect(find.text('0.0'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('Sem nota'), findsNothing);
  });

  testWidgets('rating: null renders "unrated", not a star or a score', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RatingDisplay(rating: null))),
    );

    expect(find.text('Sem nota'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.text('0.0'), findsNothing);
  });

  testWidgets('a non-zero rating renders with one decimal place', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RatingDisplay(rating: 8.2))),
    );

    expect(find.text('8.2'), findsOneWidget);
  });
}
