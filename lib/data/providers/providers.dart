import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mavie/data/datasources/movie_remote_data_source.dart';
import 'package:mavie/data/repositories/movie_repository_impl.dart';
import 'package:mavie/domain/repositories/movie_repository.dart';
import '../datasources/dio_client.dart';

final movieClientProvider = Provider<Dio>((ref) {
  return createDioClient();
});

final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>((ref) {
  final client = ref.watch(movieClientProvider);
  return MovieRemoteDataSource(client);
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final dataSource = ref.watch(movieRemoteDataSourceProvider);
  return MovieRepositoryImpl(dataSource);
});
