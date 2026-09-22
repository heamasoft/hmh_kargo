import 'dart:io' show Platform;

import 'package:webview_flutter/webview_flutter.dart';

/// Android stores get the Chrome-on-Android identity they have always had —
/// the Android WebView IS Chrome, so it's truthful and proven on Shein.
const _androidUa = 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36';

/// Sets a user agent that matches the WebView's real engine AND version.
///
/// Bot checks (Shein's "confirm you're human" puzzle, Akamai) compare what the
/// browser claims to be with how it actually behaves. On iPhone the claim used
/// to be wrong — the import screen said "Android", the store screen a fixed
/// iOS 17.5 — so the puzzle failed however it was solved. Here the iPhone's
/// own WebKit agent is kept and only completed to match real Safari (WKWebView
/// leaves out "Version/… Safari/…", which Shein treats as a non-browser),
/// with the version taken from the phone's actual iOS.
Future<void> applyStoreUserAgent(WebViewController controller) async {
  if (!Platform.isIOS) {
    await controller.setUserAgent(_androidUa);
    return;
  }
  String? real;
  try {
    real = await controller.getUserAgent();
  } catch (_) {
    real = null;
  }
  final ua = iosSafariUa(real);
  if (ua != null) await controller.setUserAgent(ua);
}

/// The phone's WKWebView agent, completed to what Safari itself sends:
///   …(iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15
///   (KHTML, like Gecko) Mobile/15E148
/// → … (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1
/// Null keeps the WebView's own agent (unreadable, or already Safari-shaped).
String? iosSafariUa(String? real) {
  if (real == null || real.isEmpty) return null;
  if (real.contains('Safari/')) return real; // already complete
  final m = RegExp(r'OS (\d+)_(\d+)').firstMatch(real);
  if (m == null) return null;
  final version = 'Version/${m.group(1)}.${m.group(2)}';
  final mobile = RegExp(r'Mobile/\S+').firstMatch(real)?.group(0) ?? 'Mobile/15E148';
  final base = real.replaceAll(RegExp(r'\s*Mobile/\S+'), '').trim();
  return '$base $version $mobile Safari/604.1';
}
