import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/app/app.dart';
import 'package:mavie/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const ProviderScope(child: MyApp()));
}
