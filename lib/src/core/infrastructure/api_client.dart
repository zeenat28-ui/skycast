import 'dart:async';

import 'package:dio/dio.dart';

import 'logger_service.dart';

class AppApiClient {
  AppApiClient({Dio? dio, AppLogger? logger})
      : _dio = dio ?? Dio(_defaultOptions()),
        _logger = logger ?? AppLogger() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.info('HTTP ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.info('HTTP ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (err, handler) async {
        _logger.warning('HTTP error ${err.response?.statusCode} ${err.requestOptions.uri}');
        // simple retry logic for network errors and 429
        final opts = err.requestOptions;
        final shouldRetry = _shouldRetry(err);
        if (shouldRetry) {
          final retryCount = (opts.extra['__retry_count'] as int?) ?? 0;
          if (retryCount < 3) {
            final wait = Duration(milliseconds: 200 * (1 << retryCount));
            await Future.delayed(wait);
            opts.extra['__retry_count'] = retryCount + 1;
            try {
              final cloneReq = await _dio.fetch(opts);
              return handler.resolve(cloneReq);
            } catch (e) {
              return handler.next(err);
            }
          }
        }
        return handler.next(err);
      },
    ));
  }

  final Dio _dio;
  final AppLogger _logger;

  static BaseOptions _defaultOptions() {
    return BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    );
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }
    final status = err.response?.statusCode ?? 0;
    if (status == 429 || status >= 500) return true;
    return false;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }
}
