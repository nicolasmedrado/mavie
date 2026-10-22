import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Either returns [responseBody] as a 200 JSON response, or throws
/// whatever [exception] builds — covers both the data-source "happy
/// path" test and the repository "maps a thrown exception" test.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter({this.responseBody, this.exception})
    : assert(
        (responseBody == null) != (exception == null),
        'Provide exactly one of responseBody or exception',
      );

  final Map<String, dynamic>? responseBody;
  final DioException Function(RequestOptions options)? exception;

  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;

    if (exception != null) {
      throw exception!(options);
    }

    return ResponseBody.fromString(
      jsonEncode(responseBody),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
