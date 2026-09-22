import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../utils/debug_log.dart';

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
    // Every call, its answer and any failure, in the [HEAMA][api] trace.
    // Debug builds only; bodies go through dlogJson, which masks secrets.
    if (kDebugMode) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (o, h) {
          dlogJson('api', '→ ${o.method} ${o.path}', o.data);
          h.next(o);
        },
        onResponse: (r, h) {
          dlogJson('api', '← ${r.statusCode} ${r.requestOptions.path}', r.data);
          h.next(r);
        },
        onError: (e, h) {
          dlog('api', '✗ ${e.requestOptions.method} ${e.requestOptions.path} '
              '${e.type.name}: ${e.message}');
          // The server's own words on a failure — with debug on, a 500 names
          // the exception, file and line.
          final body = e.response?.data;
          if (body != null) {
            dlogJson('api', '✗ ${e.response?.statusCode} ${e.requestOptions.path} body', body);
          }
          h.next(e);
        },
      ));
    }
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

  /// GETs already on the wire, by path. Several screens load the same thing as
  /// the app opens (the log showed /approvals asked 3×, /wallet and /stores
  /// 2× at once) — they now share the one request instead of repeating it.
  final Map<String, Future<Map<String, dynamic>>> _inflight = {};

  Future<Map<String, dynamic>> get(String path) {
    final key = '${_token ?? ''}|$path'; // never share across accounts
    final running = _inflight[key];
    if (running != null) return running;
    final f = _safe(() => _dio.get(path)).then(_unwrap);
    _inflight[key] = f;
    f.whenComplete(() => _inflight.remove(key)).ignore();
    return f;
  }

  static const _cachePrefix = 'api_cache:';

  /// Like [get], and keeps the reply on the phone for [cached] — for data that
  /// changes slowly (stores, trending, stock), so screens can show the last
  /// copy instantly on the next launch while this fresh one loads.
  Future<Map<String, dynamic>> getAndCache(String path) async {
    final json = await get(path);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$path', jsonEncode(json));
    } catch (_) {
      // caching is best-effort
    }
    return json;
  }

  /// The last reply [getAndCache] kept for [path], or null.
  Future<Map<String, dynamic>?> cached(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_cachePrefix$path');
      if (raw == null) return null;
      final v = jsonDecode(raw);
      return v is Map<String, dynamic> ? v : null;
    } catch (_) {
      return null;
    }
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
    // A deactivated account: the server has already revoked the token, so treat
    // it like a signed-out session (the app signs out) but keep its message.
    if (status == 403 && body is Map && body['blocked'] == true) {
      throw ApiException(
          (body['message'] as String?) ?? 'This account has been deactivated.',
          statusCode: 401);
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
