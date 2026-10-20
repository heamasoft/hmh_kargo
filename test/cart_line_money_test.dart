import 'package:flutter_test/flutter_test.dart';

import 'package:hmh_kargo/models/cart.dart';

/// A cart line as the server sends it, with only the money fields that matter
/// here spelled out.
Map<String, dynamic> _line({
  num price = 3,
  String chargeCurrency = 'USD',
  num sourcePrice = 96,
  String sourceCurrency = 'TRY',
  num shipping = 2,
  num? shippingUnit = 2,
  bool shippingSet = false,
  int qty = 1,
}) =>
    {
      'id': 1,
      'title': 'Kırmızı Düz Saten Fular',
      'image_url': '',
      'charge_currency': chargeCurrency,
      'iqd_price': price,
      'source_price': sourcePrice,
      'source_currency': sourceCurrency,
      'shipping': shipping,
      if (shippingUnit != null) 'shipping_unit': shippingUnit,
      'shipping_set': shippingSet,
      'qty': qty,
      'line_total_iqd': price * qty,
    };

void main() {
  group('what a cart line costs in all', () {
    test('adds the carriage to the goods', () {
      final line = CartLine.fromJson(_line());
      expect(line.allIn, 5); // $3.00 + $2.00
    });

    test('counts the carriage for every unit, as the order will', () {
      // Two of the coat ship as two orders of one, so two lots of carriage —
      // the server sends the line's whole shipping, and the editor the unit's.
      final line = CartLine.fromJson(_line(price: 61, shipping: 4, qty: 2));
      expect(line.shipping, 4);
      expect(line.shippingUnit, 2);
      expect(line.allIn, 126); // 61 × 2 + 4
    });
  });

  group("the shop's own price", () {
    test('is shown beside ours when the shop prices in other money', () {
      expect(CartLine.fromJson(_line()).showsSourcePrice, isTrue);
    });

    test('is left out when the shop already prices in what we charge', () {
      // A stock item bought and sold in dollars has nothing to compare.
      final line = _line(sourceCurrency: 'USD', sourcePrice: 3);
      expect(CartLine.fromJson(line).showsSourcePrice, isFalse);
    });

    test('is left out when the shop price never came through', () {
      final line = _line(sourcePrice: 0);
      expect(CartLine.fromJson(line).showsSourcePrice, isFalse);
    });

    test('still shows for the international side, in dollars against dinars', () {
      final line = _line(
        price: 114000,
        chargeCurrency: 'IQD',
        sourcePrice: 67.62,
        sourceCurrency: 'USD',
        shipping: 0,
        shippingUnit: 0,
      );
      expect(CartLine.fromJson(line).showsSourcePrice, isTrue);
    });
  });

  group('a server that does not send the unit figure yet', () {
    test('falls back to the line figure rather than showing nothing', () {
      final line = CartLine.fromJson(_line(shippingUnit: null));
      expect(line.shippingUnit, 2);
      expect(line.shippingSet, isFalse);
    });
  });
}
