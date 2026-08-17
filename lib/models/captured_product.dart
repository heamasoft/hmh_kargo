/// A product scraped from a store website and priced in IQD by the API.
class CapturedProduct {
  final int? storeId;
  final String? storeName;
  final String sourceUrl;
  final String title;
  final String imageUrl;
  final double sourcePrice;
  final String sourceCurrency;

  /// Currency the customer is charged in (IQD for Shein/manual, USD otherwise).
  final String chargeCurrency;

  /// All-in unit price — real amount in [chargeCurrency] (IQD dinars / USD dollars).
  final num chargeAmount;

  /// IQD-equivalent all-in price (reference only).
  final num iqdPrice;

  /// Whether the server found a price automatically (false → ask the user).
  final bool auto;

  const CapturedProduct({
    this.storeId,
    this.storeName,
    required this.sourceUrl,
    required this.title,
    required this.imageUrl,
    required this.sourcePrice,
    required this.sourceCurrency,
    this.chargeCurrency = 'IQD',
    this.chargeAmount = 0,
    required this.iqdPrice,
    this.auto = true,
  });

  factory CapturedProduct.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;
    final iqd = (json['iqd_price'] ?? 0) as num;
    return CapturedProduct(
      storeId: store?['id'] as int?,
      storeName: store?['name'] as String?,
      sourceUrl: (json['source_url'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      imageUrl: (json['image_url'] ?? '') as String? ?? '',
      sourcePrice: ((json['source_price'] ?? 0) as num).toDouble(),
      sourceCurrency: (json['source_currency'] ?? 'USD') as String,
      chargeCurrency: (json['charge_currency'] ?? 'IQD') as String,
      chargeAmount: (json['charge_amount'] ?? iqd) as num,
      iqdPrice: iqd,
      auto: (json['auto'] ?? true) as bool,
    );
  }
}

/// Raw data scraped from the web page before pricing.
class ScrapeResult {
  final String url;
  final String title;
  final String image;
  final double? price;
  final String? currency;
  final String? color;
  final String? size;

  /// The product's SKU / id (for the admin to find the exact item to order).
  final String? sku;

  /// Whether the scraped color / size is a value we're confident is the one the
  /// user actually selected (from the store's own "Color: X" / "Size: X" readout),
  /// vs. a shaky class-based guess. Drives whether the AI is asked to verify.
  final bool colorSure;
  final bool sizeSure;

  /// Whether the product page offers color / size options (drives validation).
  final bool hasColor;
  final bool hasSize;

  /// Option labels scraped from the page, so the sheet can show chips.
  final List<String> colorOptions;
  final List<String> sizeOptions;

  /// Compact variant context for the AI fallback (empty if none).
  final String aiBlob;

  const ScrapeResult({
    required this.url,
    required this.title,
    required this.image,
    this.price,
    this.currency,
    this.color,
    this.size,
    this.sku,
    this.colorSure = true,
    this.sizeSure = true,
    this.hasColor = true,
    this.hasSize = true,
    this.colorOptions = const [],
    this.sizeOptions = const [],
    this.aiBlob = '',
  });

  bool get hasPrice => price != null && price! > 0;

  /// A copy with AI-refined variant fields applied.
  ScrapeResult mergeAi({
    String? size,
    String? color,
    List<String>? sizeOptions,
    List<String>? colorOptions,
  }) =>
      ScrapeResult(
        url: url,
        title: title,
        image: image,
        price: price,
        currency: currency,
        color: (color != null && color.isNotEmpty) ? color : this.color,
        size: (size != null && size.isNotEmpty) ? size : this.size,
        sku: sku,
        // The AI resolved these deliberately, so trust them.
        colorSure: (color != null && color.isNotEmpty) ? true : colorSure,
        sizeSure: (size != null && size.isNotEmpty) ? true : sizeSure,
        hasColor: hasColor || (colorOptions?.isNotEmpty ?? false),
        hasSize: hasSize ||
            (sizeOptions?.isNotEmpty ?? false) ||
            (size != null && size.isNotEmpty),
        colorOptions:
            (colorOptions != null && colorOptions.isNotEmpty) ? colorOptions : this.colorOptions,
        sizeOptions:
            (sizeOptions != null && sizeOptions.isNotEmpty) ? sizeOptions : this.sizeOptions,
        aiBlob: aiBlob,
      );

  factory ScrapeResult.fromJson(Map<String, dynamic> json) {
    double? parsePrice(dynamic v) {
      if (v == null) return null;
      final cleaned = v.toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned);
    }

    String? nonEmpty(dynamic v) {
      final s = (v as String?)?.trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    List<String> parseList(dynamic v) {
      if (v is! List) return const [];
      final seen = <String>[];
      for (final e in v) {
        final s = e?.toString().trim() ?? '';
        if (s.isNotEmpty && s.length <= 24 && !seen.contains(s)) seen.add(s);
      }
      return seen;
    }

    return ScrapeResult(
      url: (json['url'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      price: parsePrice(json['price']),
      currency: nonEmpty(json['currency'])?.toUpperCase(),
      color: nonEmpty(json['color']),
      size: nonEmpty(json['size']),
      sku: nonEmpty(json['sku']),
      colorSure: (json['colorSure'] ?? true) as bool,
      sizeSure: (json['sizeSure'] ?? true) as bool,
      hasColor: (json['hasColor'] ?? true) as bool,
      hasSize: (json['hasSize'] ?? true) as bool,
      colorOptions: parseList(json['colorOptions']),
      sizeOptions: parseList(json['sizeOptions']),
      aiBlob: (json['ai'] ?? '') as String? ?? '',
    );
  }
}
