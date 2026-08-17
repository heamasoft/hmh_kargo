import 'package:flutter/material.dart';

/// One line item captured in an order (snapshot).
class OrderItem {
  /// order_items.id — used for per-item actions (cancel, shipping approvals).
  final int id;
  final String title;
  final String store;
  final String imageUrl;
  final String chargeCurrency;
  final num iqdPrice; // real amount in chargeCurrency

  /// This item's own shipping fee (real amount in [chargeCurrency]); the admin
  /// may re-price it per item, so it can differ from the $2 default.
  final num? shipping;
  final int qty;
  final String? color;
  final String? size;

  /// The customer-facing status of THIS item, derived from the admin's per-item
  /// step (placed / buying / bought / zakho_office / delivery / delivered).
  final String status;

  /// Whether the customer may still cancel THIS item (true only while it is
  /// pending — the admin hasn't started buying it yet).
  final bool canCancel;

  const OrderItem({
    this.id = 0,
    required this.title,
    required this.store,
    required this.imageUrl,
    this.chargeCurrency = 'IQD',
    required this.iqdPrice,
    this.shipping,
    required this.qty,
    this.color,
    this.size,
    this.status = 'placed',
    this.canCancel = false,
  });

  static const defaultGradient = [Color(0xFFC9B6E8), Color(0xFFE9C7D6)];

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: (json['id'] ?? 0) as int,
        title: (json['title'] ?? '') as String,
        store: (json['store'] ?? '') as String? ?? '',
        imageUrl: (json['image_url'] ?? '') as String? ?? '',
        chargeCurrency: (json['charge_currency'] ?? 'IQD') as String,
        iqdPrice: (json['iqd_price'] ?? 0) as num,
        shipping: json['shipping'] as num?,
        qty: (json['qty'] ?? 1) as int,
        color: json['color'] as String?,
        size: json['size'] as String?,
        status: (json['status'] ?? 'placed') as String? ?? 'placed',
        canCancel: (json['can_cancel'] ?? false) as bool? ?? false,
      );
}

/// A tracking event in an order's timeline.
class OrderEvent {
  final String status;
  final String? note;
  final DateTime? happenedAt;

  const OrderEvent({required this.status, this.note, this.happenedAt});

  factory OrderEvent.fromJson(Map<String, dynamic> json) => OrderEvent(
        status: (json['status'] ?? '') as String,
        note: json['note'] as String?,
        happenedAt: json['happened_at'] != null
            ? DateTime.tryParse(json['happened_at'].toString())
            : null,
      );
}

/// An order with its items, totals, and tracking timeline.
class Order {
  final String code;
  final String status;

  /// Order currency; the *Iqd amounts are real amounts in it (IQD dinars / USD dollars).
  final String currency;
  final num itemsTotalIqd;
  final num shippingIqd;
  final num serviceFeeIqd;
  final num totalIqd;
  final String paymentMethod;

  /// 'paid' (wallet), 'cod_due', 'cod_paid', 'refunded', 'cancelled'.
  final String paymentStatus;

  /// Whether the customer may still cancel (true only before we purchase it).
  final bool canCancel;
  final Map<String, dynamic>? address;
  final DateTime? placedAt;
  final int itemCount;
  final List<String> statusFlow;
  final List<OrderItem> items;
  final List<OrderEvent> events;

  const Order({
    required this.code,
    required this.status,
    this.currency = 'IQD',
    required this.itemsTotalIqd,
    required this.shippingIqd,
    required this.serviceFeeIqd,
    required this.totalIqd,
    required this.paymentMethod,
    this.paymentStatus = 'paid',
    this.canCancel = false,
    this.address,
    this.placedAt,
    this.itemCount = 0,
    this.statusFlow = const [],
    this.items = const [],
    this.events = const [],
  });

  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isCod => paymentMethod == 'cod';

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        code: (json['code'] ?? '') as String,
        status: (json['status'] ?? 'placed') as String,
        currency: (json['currency'] ?? 'IQD') as String,
        itemsTotalIqd: (json['items_total_iqd'] ?? 0) as num,
        shippingIqd: (json['shipping_iqd'] ?? 0) as num,
        serviceFeeIqd: (json['service_fee_iqd'] ?? 0) as num,
        totalIqd: (json['total_iqd'] ?? 0) as num,
        paymentMethod: (json['payment_method'] ?? 'wallet') as String,
        paymentStatus: (json['payment_status'] ?? 'paid') as String,
        canCancel: (json['can_cancel'] ?? false) as bool,
        address: json['address'] as Map<String, dynamic>?,
        placedAt: json['placed_at'] != null
            ? DateTime.tryParse(json['placed_at'].toString())
            : null,
        itemCount: (json['item_count'] ?? 0) as int,
        statusFlow: ((json['status_flow'] as List?)?.map((e) => e.toString()).toList()) ?? const [],
        items: ((json['items'] as List?) ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        events: ((json['events'] as List?) ?? [])
            .map((e) => OrderEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
