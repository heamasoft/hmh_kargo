/// Tagged debug tracing for the store WebViews, captures and API calls.
///
/// Every line starts with `[HEAMA][area]`, so the whole flow can be followed
/// in one filtered stream:
///
///     flutter run            → lines appear in the terminal
///     adb logcat -s flutter  → the same lines from a connected phone
///
/// Silent in release builds: [kDebugMode] is a compile-time constant, so the
/// calls cost nothing there and nothing reaches a customer's device log.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Keys whose values must never be printed — auth material and personal data.
const _secretKeys = {
  'password',
  'password_confirmation',
  'otp',
  'code',
  'token',
  'access_token',
  'authorization',
  'phone',
  'email',
};

/// Longest single value printed before it's cut — keeps page dumps readable.
const _maxLen = 600;


/// The last few hundred traced lines, kept in memory so they can be read on
/// the phone itself.
///
/// [dlog] prints to the console, which only exists while the app is run from a
/// computer — so a problem that happens on a tester's iPhone, over TestFlight,
/// leaves no trace anywhere. The same lines are kept here in every build,
/// where a screen can show them and the tester can copy them to us.
///
/// Nothing is written to disk and nothing is sent anywhere by itself: the
/// trail lives as long as the app is open, and the values in it have already
/// been through the same masking as the printed lines.
class DebugTrail {
  DebugTrail._();

  /// Oldest first. Capped, so a long session cannot grow without bound.
  static final List<String> _lines = <String>[];
  static const _max = 300;

  static void add(String area, String message) {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp = '${two(now.hour)}:${two(now.minute)}:${two(now.second)}'
        '.${now.millisecond.toString().padLeft(3, '0')}';
    _lines.add('$stamp  [$area] $message');
    if (_lines.length > _max) _lines.removeRange(0, _lines.length - _max);
  }

  /// A copy, newest last — safe to hold while more lines arrive.
  static List<String> get lines => List.unmodifiable(_lines);

  static bool get isEmpty => _lines.isEmpty;

  /// The whole trail as one block, for copying into a message.
  static String get text => _lines.join('\n');

  static void clear() => _lines.clear();
}

/// Traces one tagged line: kept in [DebugTrail] in every build, and printed
/// to the console in debug ones.
void dlog(String area, String message) {
  DebugTrail.add(area, message);
  if (!kDebugMode) return;
  debugPrint('[HEAMA][$area] $message');
}

/// Prints [value] as compact JSON with secrets masked and long strings cut.
void dlogJson(String area, String label, Object? value) {
  String text;
  try {
    text = jsonEncode(_redact(value));
  } catch (_) {
    text = value.toString();
  }
  dlog(area, '$label ${_cut(text)}');
}

/// Cuts [text] to a readable length, noting how much was dropped.
String dcut(String text) => _cut(text);

String _cut(String text) => text.length <= _maxLen
    ? text
    : '${text.substring(0, _maxLen)}… (+${text.length - _maxLen} chars)';

Object? _redact(Object? value) {
  if (value is Map) {
    return {
      for (final e in value.entries)
        e.key.toString(): _secretKeys.contains(e.key.toString().toLowerCase())
            ? '***'
            : _redact(e.value),
    };
  }
  if (value is List) return value.map(_redact).toList();
  if (value is String) return _cut(value);
  return value;
}

/// Runs inside a store page and reports what Shein thinks it is doing — the
/// storefront, pricing currency, ship-to country and the header's country chip.
/// Posts one JSON object on the `HeamaDebug` channel; harmless on other sites.
const pageDiagnosticsJs = r'''
(function(){
  try{
    var out={url:location.href};
    try{ if(typeof gbCommonInfo!=='undefined'){ out.site=gbCommonInfo.SiteUID; out.currency=gbCommonInfo.currency; out.lang=gbCommonInfo.lang; } }catch(e){}
    function ls(k){ try{ var v=localStorage.getItem(k); if(!v) return null; var o=JSON.parse(v); return o&&o.value!==undefined&&typeof o.value!=='object'? o.value : (o&&o.value&&o.value.countryAbbr) || v.slice(0,80); }catch(e){ return null; } }
    out.addressCookie=ls('addressCookie');
    out.locationCurrent=ls('LOCATION_CURRENT');
    out.ipCountry=ls('ipCountry');
    out.lsCurrency=ls('currency');
    var body=(document.body&&document.body.innerText||'').replace(/\s+/g,' ');
    var chip=body.match(/\b(United Arab Emirates|Azerbaijan|Iraq|Saudi Arabia|Kuwait|Qatar|Bahrain|Oman|Jordan|Algeria|Turkey|United States)\b/);
    out.countryShown=chip?chip[1]:null;
    out.challenge=/risk\/challenge|captcha/i.test(location.href);
    out.cookieNames=document.cookie.split(';').map(function(c){return c.split('=')[0].trim();}).filter(Boolean);
    if(window.HeamaDebug) HeamaDebug.postMessage(JSON.stringify(out));
  }catch(e){ if(window.HeamaDebug) HeamaDebug.postMessage(JSON.stringify({error:String(e)})); }
})();
''';
