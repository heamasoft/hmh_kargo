import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter's bundled Material/Cupertino localizations don't include Kurdish
/// (`ku`), so on that locale any widget that needs [MaterialLocalizations] (a
/// dialog, date picker, tooltip, text-selection menu…) throws
/// "No MaterialLocalizations found". Arabic and English ship with Flutter, which
/// is why only Kurdish breaks.
///
/// These delegates supply Kurdish by loading the ARABIC built-in data (both are
/// RTL). Only the handful of framework strings (Cancel/OK/Paste…) use it — the
/// app's own text stays Kurdish via [AppLocalizations]. Register them BEFORE the
/// Global* delegates so they win for `ku` and defer for every other locale.

class KuMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const KuMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

class KuCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const KuCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}
