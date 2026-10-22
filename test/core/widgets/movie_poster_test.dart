import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/widgets/movie_poster.dart';

class _ThrowingHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    throw const SocketException('network disabled in tests');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a null posterPath shows the styled placeholder', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MoviePoster(posterPath: null))),
    );
    await tester.pump();

    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
  });

  testWidgets(
    'a poster that fails to load falls back to the same placeholder',
    (tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: MoviePoster(posterPath: '/unreachable.jpg')),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
      }, _FailingHttpOverrides());
    },
  );
}

class _FailingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _ThrowingHttpClient();
  }
}
