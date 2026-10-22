import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/app/app.dart';
import 'package:mavie/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const ProviderScope(retry: _noRetry, child: MyApp()));
}

// Riverpod retries a failed provider up to 10 times with exponential
// backoff by default (capped at 6.4s, ~38s total), rendering AsyncLoading
// the whole time. AppErrorView (FND-07) already gives the user an explicit,
// immediate retry action, so the automatic one is disabled app-wide.
Duration? _noRetry(int retryCount, Object error) => null;
