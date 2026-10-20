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
      // Two of the coat ship as two orders of one, so two lots of carriage.
      final line = CartLine.fromJson(_line(price: 61, shipping: 4, qty: 2));
      expect(line.allIn, 126); // 61 × 2 + 4
    });

    test('shares the line carriage out over its units, as the order will', () {
      // Two of the coat ship as two orders of one, so the order each carries
      // is half the line's figure — that is what the admin edits at checkout.
      final line = CartLine.fromJson(_line(price: 61, shipping: 4, qty: 2));
      expect(line.shippingUnit, 2);
    });

    test('is nothing per unit when nothing is charged to bring the line', () {
      expect(CartLine.fromJson(_line(shipping: 0)).shippingUnit, 0);
    });

    test('is just the goods where nothing is charged to bring them', () {
      // The international side ships free, and a stock item's price is all-in.
      final line = CartLine.fromJson(_line(price: 114000, chargeCurrency: 'IQD', shipping: 0));
      expect(line.allIn, 114000);
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
      expect(CartLine.fromJson(_line(sourcePrice: 0)).showsSourcePrice, isFalse);
    });

    test('still shows for the international side, in dollars against dinars', () {
      final line = _line(
        price: 114000,
        chargeCurrency: 'IQD',
        sourcePrice: 67.62,
        sourceCurrency: 'USD',
        shipping: 0,
      );
      expect(CartLine.fromJson(line).showsSourcePrice, isTrue);
    });
  });
}
