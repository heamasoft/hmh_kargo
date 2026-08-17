/// A product the company already holds in stock (ready now, no shipping wait).
/// Backed by an admin order item at step 'stock'.
class StockItem {
  final int itemId;
  final String title;
  final String imageUrl;
  final String sourceUrl;
  final String store;
  final String currency;

  /// All-in price the customer pays, in [currency] (item + its shipping).
  final num price;
  final String? color;
  final String? size;
  final String? sku;
  final bool isShein;

  const StockItem({
    required this.itemId,
    required this.title,
    required this.imageUrl,
    required this.sourceUrl,
    required this.store,
    required this.currency,
    required this.price,
    this.color,
    this.size,
    this.sku,
    this.isShein = false,
  });

  /// A clean store name for display: Shein items read "Shein" (not "ar"),
  /// others are title-cased ("trendyol" → "Trendyol").
  String get storeLabel {
    if (isShein) return 'Shein';
    if (store.trim().isEmpty) return '';
    final s = store.trim();
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        itemId: (json['item_id'] ?? 0) as int,
        title: (json['title'] ?? '') as String,
        imageUrl: (json['image_url'] ?? '') as String? ?? '',
        sourceUrl: (json['source_url'] ?? '') as String? ?? '',
        store: (json['store'] ?? '') as String? ?? '',
        currency: (json['currency'] ?? 'IQD') as String,
        price: (json['price'] ?? 0) as num,
        color: json['color'] as String?,
        size: json['size'] as String?,
        sku: json['sku'] as String?,
        isShein: (json['is_shein'] ?? false) as bool? ?? false,
      );
}
