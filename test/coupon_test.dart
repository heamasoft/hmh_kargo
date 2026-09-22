import 'package:flutter_test/flutter_test.dart';
import 'package:hmh_kargo/services/coupon_api.dart';

void main() {
  const tenPct = Coupon(id: 1, code: 'SUMMER10', percent: 10);

  test('dinars round to whole, like the server', () {
    expect(tenPct.discountOn(26500, 'IQD'), 2650);
    expect(tenPct.discountOn(7755, 'IQD'), 776); // 775.5 → 776
  });

  test('dollars keep cents', () {
    expect(tenPct.discountOn(35.5, 'USD'), 3.55);
    expect(const Coupon(id: 2, code: 'X', percent: 12.5).discountOn(9.99, 'USD'), 1.25);
  });

  test('labels', () {
    expect(tenPct.percentLabel, '10%');
    expect(const Coupon(id: 2, code: 'X', percent: 12.5).percentLabel, '12.5%');
  });
}
