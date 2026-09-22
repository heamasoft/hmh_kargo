import 'package:flutter_test/flutter_test.dart';
import 'package:hmh_kargo/utils/format.dart';

void main() {
  test('lira is labelled as lira, never as dinars', () {
    // A Trendyol collection item: this used to read "350 IQD".
    expect(formatMoney(350, 'TRY'), '350.00 TL');
    expect(formatMoney(1570.5, 'TRY'), '1,570.50 TL');
  });

  test('dinars and dollars read as before', () {
    expect(formatMoney(7750, 'IQD'), '7,750 IQD');
    expect(formatMoney(7750, 'IQD', iqdLabel: 'د.ع'), '7,750 د.ع');
    expect(formatMoney(5.7, 'USD'), '\$5.70');
  });

  test('older data with no currency still means dinars', () {
    expect(formatMoney(1000, ''), '1,000 IQD');
  });

  test('an unknown currency is named, not passed off as dinars', () {
    expect(formatMoney(12.5, 'sar'), '12.50 SAR');
  });
}
