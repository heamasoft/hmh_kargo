import 'package:flutter/services.dart';

/// Arabic (٠١٢…) and Persian/Kurdish (۰۱۲…) keyboards type their own digits.
/// Phone numbers and codes must reach the server as 0–9 — `\D` checks and
/// digits-only filters otherwise drop them, so typing in Arabic or Kurdish
/// looked like typing nothing.
String toAsciiDigits(String s) {
  final out = StringBuffer();
  for (final r in s.runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      out.writeCharCode(0x30 + r - 0x0660); // Arabic-Indic
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      out.writeCharCode(0x30 + r - 0x06F0); // Eastern Arabic-Indic (Kurdish/Persian)
    } else {
      out.writeCharCode(r);
    }
  }
  return out.toString();
}

/// Keeps only digits — any script's, converted to 0–9 — up to [maxLength].
class AsciiDigitsFormatter extends TextInputFormatter {
  const AsciiDigitsFormatter({this.maxLength});
  final int? maxLength;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = toAsciiDigits(newValue.text).replaceAll(RegExp(r'[^0-9]'), '');
    if (maxLength != null && digits.length > maxLength!) {
      digits = digits.substring(0, maxLength);
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
