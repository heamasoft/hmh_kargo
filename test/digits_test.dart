import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmh_kargo/utils/digits.dart';

void main() {
  test('Arabic and Kurdish digits become 0-9', () {
    expect(toAsciiDigits('٠٧٥٠١٢٣٤٥٦٧'), '07501234567'); // Arabic-Indic
    expect(toAsciiDigits('۰۷۵۰۱۲۳۴۵۶۷'), '07501234567'); // Kurdish / Persian
    expect(toAsciiDigits('750 123'), '750 123');
  });

  test('the formatter keeps only digits, any script, up to the limit', () {
    const f = AsciiDigitsFormatter(maxLength: 4);
    TextEditingValue run(String s) =>
        f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: s));
    expect(run('١٢٣٤').text, '1234');
    expect(run('۱2-3 ٤5').text, '1234'); // mixed, cut to 4
    expect(run('abc').text, '');
  });
}
