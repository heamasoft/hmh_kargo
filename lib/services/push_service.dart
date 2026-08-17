import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// FCM push notifications. The phone's device token is registered with the API
/// after login; the admin console sends a push through FCM when something needs
/// the customer's attention (e.g. a shipping re-price to approve).
///
/// Only Android/iOS have FCM — on other platforms every call is a no-op, and
/// any Firebase failure degrades silently (the app still works, the in-app
/// polling remains the fallback).
class PushService {
  PushService(this._client);
  final ApiClient _client;

  bool _ready = false;
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _openSub;

  static bool get _supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Registers this device for pushes. Call once the user is logged in.
  Future<void> register() async {
    if (!_supported) return;
    try {
      if (!_ready) {
        await Firebase.initializeApp();
        _ready = true;
      }
      final fm = FirebaseMessaging.instance;
      // Android 13+ / iOS ask the user; declined → we simply get no pushes.
      await fm.requestPermission();
      final token = await fm.getToken();
      if (token != null) await _saveToken(token);
      _tokenSub ??= fm.onTokenRefresh.listen(_saveToken);
    } catch (_) {
      // Missing google-services.json, no Play services, … — polling covers it.
    }
  }

  /// Wires the foreground behaviour:
  ///  - [onMessage]  : a push arrived while the app is OPEN (no system banner
  ///    on Android) — refresh the badge and show an in-app notice.
  ///  - [onOpened]   : the user TAPPED a system notification — navigate.
  /// Also covers the tap that launched the app from a terminated state.
  void attachHandlers({
    required void Function(RemoteMessage message) onMessage,
    required void Function(RemoteMessage message) onOpened,
  }) {
    if (!_supported || !_ready) return;
    _messageSub?.cancel();
    _openSub?.cancel();
    _messageSub = FirebaseMessaging.onMessage.listen(onMessage);
    _openSub = FirebaseMessaging.onMessageOpenedApp.listen(onOpened);
    FirebaseMessaging.instance.getInitialMessage().then((m) {
      if (m != null) onOpened(m);
    });
  }

  /// Stops pushes for this phone (logout): the token is removed on the server
  /// and invalidated locally.
  Future<void> unregister() async {
    if (!_supported || !_ready) return;
    _messageSub?.cancel();
    _openSub?.cancel();
    _messageSub = null;
    _openSub = null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _client.delete('/device-tokens', data: {'token': token});
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  Future<void> _saveToken(String token) async {
    try {
      await _client.post('/device-tokens', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (_) {
      // Not logged in yet or offline — register() runs again on next login.
    }
  }

  void dispose() {
    _tokenSub?.cancel();
    _messageSub?.cancel();
    _openSub?.cancel();
  }
}
