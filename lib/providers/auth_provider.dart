import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_user.dart';
import '../services/api_client.dart';
import '../services/auth_api.dart';

/// Owns the authenticated session: current user, token, and the OTP calls.
/// The token is persisted so the user stays signed in across app launches.
class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiClient? client}) : _client = client ?? ApiClient() {
    _auth = AuthApi(_client);
  }

  final ApiClient _client;
  late final AuthApi _auth;

  static const _tokenKey = 'heama_token';

  ApiUser? _user;
  bool _busy = false;
  bool _restoring = true;

  ApiUser? get user => _user;
  bool get isBusy => _busy;
  bool get isAuthenticated => _client.token != null;

  /// True until the startup session check finishes (used by the splash gate).
  bool get restoring => _restoring;

  /// Restores a saved token on startup. Keeps the user signed in across launches
  /// and only signs them out if the server actually rejects the token (401).
  Future<void> restore() async {
    // Keep the branded splash on screen long enough for its entrance animation
    // to land, even when the session check returns instantly (signed-out user).
    final minSplash = Future<void>.delayed(const Duration(milliseconds: 1300));
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        _client.setToken(token);
        try {
          _user = await _auth.me();
        } on ApiException catch (e) {
          // Only drop the session on a real rejection, not a network hiccup.
          if (e.statusCode == 401) {
            await _clearToken();
          }
        }
      }
    } catch (_) {
      // no platform storage (tests) — stay as-is
    } finally {
      await minSplash;
      _restoring = false;
      notifyListeners();
    }
  }

  Future<void> requestOtp({
    required String identifier,
    required String channel,
    String purpose = 'login',
  }) async {
    await _run(() => _auth.requestOtp(
          identifier: identifier,
          channel: channel,
          purpose: purpose,
        ));
  }

  Future<void> verifyOtp({
    required String identifier,
    required String channel,
    required String code,
    String? name,
    String? city,
  }) async {
    await _run(() async {
      final result = await _auth.verifyOtp(
        identifier: identifier,
        channel: channel,
        code: code,
        name: name,
        city: city,
      );
      _client.setToken(result.token);
      _user = result.user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.token);
    });
  }

  /// Password login (backup to OTP). Stores the token on success.
  Future<void> login({required String phone, required String password}) async {
    await _run(() async {
      final result = await _auth.login(phone: phone, password: password);
      _client.setToken(result.token);
      _user = result.user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.token);
    });
  }

  /// Sets a password for the currently signed-in user.
  Future<void> setPassword(String password) async {
    await _run(() => _auth.setPassword(password));
  }

  /// Updates the signed-in user's profile (name / city / email).
  Future<void> updateProfile({String? name, String? city, String? email}) async {
    await _run(() async {
      _user = await _auth.updateProfile(name: name, city: city, email: email);
    });
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
    } catch (_) {
      // ignore network errors on logout
    }
    await _clearToken();
    _user = null;
    notifyListeners();
  }

  /// Permanently deletes the account, then clears the local session. Rethrows
  /// on failure so the UI can show the error (nothing is cleared in that case).
  Future<void> deleteAccount() async {
    await _auth.deleteAccount();
    await _clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> _clearToken() async {
    _client.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Runs [action] with the busy flag set, rethrowing any error for the UI.
  Future<void> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
