import 'package:dio/dio.dart';

import '../config/api_config.dart';

/// Thin wrapper around Dio: sets the base URL, JSON headers, a bearer token,
/// and turns API validation errors into readable messages.
class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
        // Don't throw on 4xx — we handle those ourselves.
        validateStatus: (code) => code != null && code < 500,
      ),
    );
  }

  late final Dio _dio;
  String? _token;

  void setToken(String? token) {
    _token = token;
    if (token == null) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  String? get token => _token;

  Future<Map<String, dynamic>> get(String path) async {
    return _unwrap(await _safe(() => _dio.get(path)));
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    return _unwrap(await _safe(() => _dio.post(path, data: data)));
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async {
    return _unwrap(await _safe(() => _dio.patch(path, data: data)));
  }

  Future<Map<String, dynamic>> delete(String path, {Object? data}) async {
    return _unwrap(await _safe(() => _dio.delete(path, data: data)));
  }

  Future<Response> _safe(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      // Network / timeout / no response (incl. CORS failures on web).
      throw ApiException(_networkMessage(e));
    } catch (_) {
      // Any other unexpected failure — never let it crash the UI.
      throw ApiException('Network error. Please try again.');
    }
  }

  /// Validates the HTTP status and returns the JSON body as a map.
  Map<String, dynamic> _unwrap(Response response) {
    final status = response.statusCode ?? 0;
    final body = response.data;

    if (status >= 200 && status < 300) {
      if (body is Map<String, dynamic>) return body;
      if (body is List) return {'data': body};
      return {};
    }

    // Laravel validation (422) / auth (401) errors carry a message.
    String message = 'Something went wrong. Please try again.';
    if (status == 401) {
      throw ApiException('Please log in to continue.', statusCode: 401);
    }
    if (body is Map) {
      if (body['errors'] is Map) {
        final errors = body['errors'] as Map;
        final first = errors.values.first;
        message = first is List ? first.first.toString() : first.toString();
      } else if (body['message'] is String) {
        message = body['message'] as String;
      }
    }
    throw ApiException(message, statusCode: status);
  }

  String _networkMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The server took too long to respond. Check your connection.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Check your internet connection.';
      default:
        return 'Network error. Please try again.';
    }
  }
}

/// A user-friendly error surfaced from the API layer.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
