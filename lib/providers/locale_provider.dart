import 'package:flutter/material.dart';

/// Holds the active locale and toggles between EN / AR / KU.
/// AR + KU are right-to-left; MaterialApp derives direction from the locale.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const supported = [Locale('en'), Locale('ar'), Locale('ku')];

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  /// Cycles EN -> AR -> KU -> EN, used by the quick language chip.
  void cycle() {
    final i = supported.indexWhere((l) => l.languageCode == _locale.languageCode);
    setLocale(supported[(i + 1) % supported.length]);
  }
}
