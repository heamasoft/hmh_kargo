import 'package:flutter/material.dart';

/// Pricing breakdown for one currency. Amounts are REAL amounts in [currency]
/// (IQD = dinars, USD = dollars).
class CartTotals {
  final String currency;
  final num itemsTotalIqd;
  final num shippingIqd;
  final num serviceFeeIqd;
  final num totalIqd;

  const CartTotals({
    this.currency = 'IQD',
    this.itemsTotalIqd = 0,
    this.shippingIqd = 0,
    this.serviceFeeIqd = 0,
    this.totalIqd = 0,
  });

  factory CartTotals.fromJson(Map<String, dynamic> json) => CartTotals(
        currency: (json['currency'] ?? 'IQD') as String,
        itemsTotalIqd: (json['items_total'] ?? json['items_total_iqd'] ?? 0) as num,
        shippingIqd: (json['shipping'] ?? json['shipping_iqd'] ?? 0) as num,
        serviceFeeIqd: (json['service_fee'] ?? json['service_fee_iqd'] ?? 0) as num,
        totalIqd: (json['total'] ?? json['total_iqd'] ?? 0) as num,
      );
}

/// A single line in the cart. [iqdPrice]/[lineTotalIqd] are real amounts in
/// [chargeCurrency] (IQD dinars / USD dollars).
class CartLine {
  final int id;
  final String title;
  final String store;
  final int? storeId;
  final String? storeKey;
  final String? sourceUrl;
  final String imageUrl;
  final String chargeCurrency;
  final num iqdPrice;

  /// This line's shipping fee ($2/unit × qty for non-Shein, 0 for Shein), in
  /// [chargeCurrency].
  final num shipping;
  final int qty;
  final num lineTotalIqd;
  final String? color;
  final String? size;
  final String? note;

  /// True when this line is an in-stock item (already in the company).
  final bool isStock;

  const CartLine({
    required this.id,
    required this.title,
    required this.store,
    this.storeId,
    this.storeKey,
    this.sourceUrl,
    required this.imageUrl,
    this.chargeCurrency = 'IQD',
    required this.iqdPrice,
    this.shipping = 0,
    required this.qty,
    required this.lineTotalIqd,
    this.color,
    this.size,
    this.note,
    this.isStock = false,
  });

  static const defaultGradient = [Color(0xFFC9B6E8), Color(0xFFE9C7D6)];

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        store: (json['store'] ?? '') as String? ?? '',
        storeId: json['store_id'] as int?,
        storeKey: json['store_key'] as String?,
        sourceUrl: json['source_url'] as String?,
        imageUrl: (json['image_url'] ?? '') as String? ?? '',
        chargeCurrency: (json['charge_currency'] ?? 'IQD') as String,
        iqdPrice: (json['iqd_price'] ?? 0) as num,
        shipping: (json['shipping'] ?? 0) as num,
        qty: (json['qty'] ?? 1) as int,
        lineTotalIqd: (json['line_total_iqd'] ?? 0) as num,
        color: json['color'] as String?,
        size: json['size'] as String?,
        note: json['note'] as String?,
        isStock: (json['is_stock'] ?? false) as bool? ?? false,
      );
}

/// The full cart: items + count + one pricing breakdown per currency.
class Cart {
  final List<CartLine> items;
  final int count;
  final List<CartTotals> totals;

  const Cart({this.items = const [], this.count = 0, this.totals = const []});

  bool get isEmpty => items.isEmpty;
  bool get isMultiCurrency => totals.length > 1;

  factory Cart.fromJson(Map<String, dynamic> json) {
    // `totals` is an array of per-currency breakdowns; tolerate the old single
    // object shape too, just in case.
    final rawTotals = json['totals'];
    final totals = <CartTotals>[];
    if (rawTotals is List) {
      for (final t in rawTotals) {
        totals.add(CartTotals.fromJson(t as Map<String, dynamic>));
      }
    } else if (rawTotals is Map<String, dynamic>) {
      totals.add(CartTotals.fromJson(rawTotals));
    }
    return Cart(
      items: ((json['items'] as List?) ?? [])
          .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] ?? 0) as int,
      totals: totals,
    );
  }
}
