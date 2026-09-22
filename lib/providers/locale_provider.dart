import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the active locale and toggles between EN / AR / KU.
/// AR + KU are right-to-left; MaterialApp derives direction from the locale.
///
/// The choice is persisted, and [chosen] tells the welcome screen whether the
/// user has ever picked a language — so we can prompt them on first launch.
class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale_code';

  Locale _locale = const Locale('en');
  bool _chosen = false;
  Future<void>? _ready;

  Locale get locale => _locale;

  /// True once the user has explicitly picked a language (this run or a past one).
  bool get chosen => _chosen;

  /// Completes once the saved language (if any) has been restored — await this
  /// before deciding whether to prompt the user, to avoid a startup race.
  Future<void> get ready => _ready ?? Future.value();

  static const supported = [Locale('en'), Locale('ar'), Locale('ku')];

  /// Restores the saved language on app start. Call once at startup.
  Future<void> load() {
    return _ready ??= _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null &&
          supported.any((l) => l.languageCode == code)) {
        _locale = Locale(code);
        _chosen = true;
        notifyListeners();
      }
    } catch (_) {
      // best-effort — fall back to the default English locale
    }
  }

  void setLocale(Locale locale) {
    _chosen = true;
    if (_locale != locale) _locale = locale;
    _persist(locale.languageCode);
    notifyListeners();
  }

  Future<void> _persist(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, code);
    } catch (_) {
      // ignore — the in-memory choice still applies for this session
    }
  }

  /// Cycles EN -> AR -> KU -> EN, used by the quick language chip.
  void cycle() {
    final i = supported.indexWhere((l) => l.languageCode == _locale.languageCode);
    setLocale(supported[(i + 1) % supported.length]);
  }
}
