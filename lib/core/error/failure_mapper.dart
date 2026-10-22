import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_failure.dart';

AppFailure mapExceptionToFailure(Object error, StackTrace stackTrace) {
  if (error is DioException) {
    return _mapDioException(error, stackTrace);
  }
  if (error is PostgrestException) {
    return _mapPostgrestException(error, stackTrace);
  }
  if (error is AuthException) {
    return _mapAuthException(error, stackTrace);
  }
  return UnknownFailure(error, stackTrace);
}

AppFailure _mapDioException(DioException error, StackTrace stackTrace) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      return _mapStatusCode(error.response?.statusCode, error, stackTrace);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.unknown:
      return UnknownFailure(error, stackTrace);
  }
}

AppFailure _mapStatusCode(
  int? statusCode,
  Object error,
  StackTrace stackTrace,
) {
  switch (statusCode) {
    case 400:
      return const ValidationFailure();
    case 401:
      return const UnauthorizedFailure();
    case 403:
      return const ForbiddenFailure();
    case 404:
      return const NotFoundFailure();
    default:
      return UnknownFailure(error, stackTrace);
  }
}

AppFailure _mapPostgrestException(
  PostgrestException error,
  StackTrace stackTrace,
) {
  switch (error.code) {
    case '42501': // RLS denial — the `raise` in get_list_items
      return const ForbiddenFailure();
    case '23514': // check constraint, e.g. an invalid rating
    case '23503': // foreign key — a write bypassed an RPC
      return const ValidationFailure();
    default:
      return UnknownFailure(error, stackTrace);
  }
}

AppFailure _mapAuthException(AuthException error, StackTrace stackTrace) {
  if (error.statusCode == '401') {
    return const UnauthorizedFailure();
  }
  return UnknownFailure(error, stackTrace);
}
