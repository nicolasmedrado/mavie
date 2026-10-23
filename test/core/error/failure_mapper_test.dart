import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/error/failure_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final options = RequestOptions(path: '/test');

  AppFailure mapDioError(DioExceptionType type, {int? statusCode}) {
    final error = DioException(
      requestOptions: options,
      type: type,
      response: statusCode == null
          ? null
          : Response(requestOptions: options, statusCode: statusCode),
    );
    return mapExceptionToFailure(error, StackTrace.current);
  }

  group('DioException', () {
    test('connectionTimeout maps to NetworkFailure', () {
      expect(
        mapDioError(DioExceptionType.connectionTimeout),
        isA<NetworkFailure>(),
      );
    });

    test('connectionError maps to NetworkFailure', () {
      expect(
        mapDioError(DioExceptionType.connectionError),
        isA<NetworkFailure>(),
      );
    });

    test('a 400 response maps to ValidationFailure', () {
      expect(
        mapDioError(DioExceptionType.badResponse, statusCode: 400),
        isA<ValidationFailure>(),
      );
    });

    test('a 401 response maps to UnauthorizedFailure', () {
      expect(
        mapDioError(DioExceptionType.badResponse, statusCode: 401),
        isA<UnauthorizedFailure>(),
      );
    });

    test('a 403 response maps to ForbiddenFailure', () {
      expect(
        mapDioError(DioExceptionType.badResponse, statusCode: 403),
        isA<ForbiddenFailure>(),
      );
    });

    test('a 404 response maps to NotFoundFailure', () {
      expect(
        mapDioError(DioExceptionType.badResponse, statusCode: 404),
        isA<NotFoundFailure>(),
      );
    });

    test('an unrecognised status code maps to UnknownFailure', () {
      expect(
        mapDioError(DioExceptionType.badResponse, statusCode: 500),
        isA<UnknownFailure>(),
      );
    });
  });

  group('PostgrestException', () {
    test('42501 (RLS denial) maps to ForbiddenFailure', () {
      final failure = mapExceptionToFailure(
        const PostgrestException(message: 'permission denied', code: '42501'),
        StackTrace.current,
      );
      expect(failure, isA<ForbiddenFailure>());
    });

    test('23514 (check constraint) maps to ValidationFailure', () {
      final failure = mapExceptionToFailure(
        const PostgrestException(message: 'check violation', code: '23514'),
        StackTrace.current,
      );
      expect(failure, isA<ValidationFailure>());
    });

    test('23503 (foreign key) maps to ValidationFailure', () {
      final failure = mapExceptionToFailure(
        const PostgrestException(message: 'fk violation', code: '23503'),
        StackTrace.current,
      );
      expect(failure, isA<ValidationFailure>());
    });

    test('an unrecognised code maps to UnknownFailure', () {
      final failure = mapExceptionToFailure(
        const PostgrestException(message: 'something else', code: '99999'),
        StackTrace.current,
      );
      expect(failure, isA<UnknownFailure>());
    });
  });

  group('AuthException', () {
    test('a 401 status maps to UnauthorizedFailure', () {
      final failure = mapExceptionToFailure(
        const AuthException('session expired', statusCode: '401'),
        StackTrace.current,
      );
      expect(failure, isA<UnauthorizedFailure>());
    });

    test(
      'a 400 status (e.g. invalid credentials) maps to ValidationFailure',
      () {
        final failure = mapExceptionToFailure(
          const AuthException('Invalid login credentials', statusCode: '400'),
          StackTrace.current,
        );
        expect(failure, isA<ValidationFailure>());
      },
    );

    test('any other status maps to UnknownFailure', () {
      final failure = mapExceptionToFailure(
        const AuthException('something else', statusCode: '500'),
        StackTrace.current,
      );
      expect(failure, isA<UnknownFailure>());
    });
  });

  test(
    'an unrecognised error maps to UnknownFailure, keeping the original error and stack trace',
    () {
      final stackTrace = StackTrace.current;
      final original = StateError('boom');

      final failure =
          mapExceptionToFailure(original, stackTrace) as UnknownFailure;

      expect(failure.error, same(original));
      expect(failure.stackTrace, same(stackTrace));
    },
  );
}
