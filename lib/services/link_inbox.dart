import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/link_text.dart';

/// Product links that reach the app from outside it, so the shopper never has
/// to paste one by hand:
///  - a link they copied in the Shein app, Safari or Chrome, offered when they
///    come back to the app ("Found a link — Add to cart");
///  - on Android, "Share → HMH Kargo" from any app.
class LinkInbox {
  static const _clip = MethodChannel('hmh/clipboard');
  static const _share = MethodChannel('hmh/share');
  static const _seenKey = 'link_inbox_seen_v1';

  /// Ticks each time a new copied link is found; the shell shows "Add to cart".
  static final copied = ValueNotifier<int>(0);
  static bool _checking = false;
  static Timer? _watch;
  static DateTime _watchUntil = DateTime(0);

  /// Looks at the clipboard now and rings [copied] when there is a new link.
  static Future<void> check() async {
    if (_checking) return;
    _checking = true;
    try {
      if (await hasNewCopiedLink()) copied.value++;
    } finally {
      _checking = false;
    }
  }

  /// Keeps checking for a while after a store opens. Closing Safari's sheet
  /// over the app doesn't bring the app back from the background, so this is
  /// how a link copied there is noticed. iOS only peeks (no paste prompt).
  static void watchForCopies({Duration forHowLong = const Duration(minutes: 15)}) {
    if (!_ios) return;
    _watchUntil = DateTime.now().add(forHowLong);
    _watch ??= Timer.periodic(const Duration(seconds: 2), (t) {
      if (DateTime.now().isAfter(_watchUntil)) {
        t.cancel();
        _watch = null;
        return;
      }
      check();
    });
  }

  static bool get _ios => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Whether the clipboard holds a link not offered before. Each copy is
  /// offered once, so a dismissed one doesn't keep coming back.
  ///
  /// iOS only checks that a link is there (no "Allow Paste" prompt); the
  /// clipboard is read when the shopper taps Add. Android reads it now.
  static Future<bool> hasNewCopiedLink() async {
    try {
      String token;
      if (_ios) {
        final probe = await _clip.invokeMapMethod<String, dynamic>('probe');
        if (probe == null || probe['link'] != true) return false;
        token = 'ios:${probe['count']}';
      } else if (_android) {
        // Android lets an app read the clipboard only once it has focus.
        await Future<void>.delayed(const Duration(milliseconds: 600));
        final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
        final url = firstUrlIn(text);
        if (url == null) return false;
        token = url;
      } else {
        return false;
      }
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_seenKey) == token) return false;
      await prefs.setString(_seenKey, token);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// The link on the clipboard (on iOS this is when "Allow Paste" is asked).
  static Future<String?> copiedLink() async {
    try {
      final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
      return firstUrlIn(text);
    } catch (_) {
      return null;
    }
  }

  /// Android "Share → HMH Kargo": [onShared] gets each shared text — the one
  /// that launched the app, and any shared while it runs.
  static Future<void> listenForShares(void Function(String text) onShared) async {
    if (!_android) return;
    _share.setMethodCallHandler((call) async {
      if (call.method == 'shared' && call.arguments is String) onShared(call.arguments as String);
    });
    try {
      final first = await _share.invokeMethod<String>('initial');
      if (first != null && first.isNotEmpty) onShared(first);
    } catch (_) {}
  }
}
