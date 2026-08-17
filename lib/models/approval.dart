/// A shipping-fee approval request: the admin re-priced one order item's
/// shipping and the customer must accept before the item is bought.
/// All amounts are REAL amounts in [currency] (IQD dinars / USD dollars) —
/// never FX-converted. newTotal = itemPrice + newShipping.
class ShippingApproval {
  final int id;
  final int itemId;
  final String orderCode;
  final String title;
  final String imageUrl;
  final String? sku;
  final String currency;
  final num itemPrice;
  final num? oldShipping;
  final num newShipping;
  final num newTotal;
  final String status; // pending | accepted | rejected | superseded
  final String? note;

  const ShippingApproval({
    required this.id,
    required this.itemId,
    required this.orderCode,
    required this.title,
    required this.imageUrl,
    this.sku,
    this.currency = 'USD',
    required this.itemPrice,
    this.oldShipping,
    required this.newShipping,
    required this.newTotal,
    this.status = 'pending',
    this.note,
  });

  bool get isPending => status == 'pending';

  factory ShippingApproval.fromJson(Map<String, dynamic> json) => ShippingApproval(
        id: (json['id'] ?? 0) as int,
        itemId: (json['item_id'] ?? 0) as int,
        orderCode: (json['order_code'] ?? '') as String? ?? '',
        title: (json['title'] ?? '') as String? ?? '',
        imageUrl: (json['image_url'] ?? '') as String? ?? '',
        sku: json['sku'] as String?,
        currency: ((json['currency'] ?? 'USD') as String).toUpperCase(),
        itemPrice: (json['item_price'] ?? 0) as num,
        oldShipping: json['old_shipping'] as num?,
        newShipping: (json['new_shipping'] ?? 0) as num,
        newTotal: (json['new_total'] ?? 0) as num,
        status: (json['status'] ?? 'pending') as String,
        note: json['note'] as String?,
      );
}
