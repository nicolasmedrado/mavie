import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mavie/app/app.dart';

void main() {
  testWidgets('app launches straight into the movie search screen', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    expect(find.text('Buscar filmes...'), findsOneWidget);
  });
}
