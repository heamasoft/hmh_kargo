import '../models/captured_product.dart';
import 'api_client.dart';

/// Sends a scraped product to the API, which prices it in IQD.
class CaptureApi {
  CaptureApi(this._client);
  final ApiClient _client;

  /// Server-side scrape of a product URL → priced in IQD (if a price was found).
  Future<CapturedProduct> scrape(String url) async {
    final json = await _client.post('/scrape', data: {'url': url});
    return CapturedProduct.fromJson(json);
  }

  /// Turns a link shared from a store's app (Shein "onelink") into the real
  /// product URL, which the WebView can load and scrape in full. Returns [url]
  /// unchanged when it isn't a share link or couldn't be resolved — the caller
  /// then just loads what the user pasted.
  Future<ResolvedLink> resolve(String url) async {
    try {
      final json = await _client.post('/resolve', data: {'url': url});
      return ResolvedLink(
        url: (json['url'] as String?)?.trim().isNotEmpty == true
            ? json['url'] as String
            : url,
        isShare: json['share'] == true,
        isCart: (json['kind'] as String?) == 'cart',
        isCollection: (json['kind'] as String?) == 'collection',
        readOnDevice: json['read_on_device'] == true,
        storeKey: (json['store_key'] as String?)?.trim(),
        items: (json['items'] is List)
            ? (json['items'] as List).whereType<Map<String, dynamic>>().toList()
            : const [],
        sku: (json['sku'] as String?)?.trim(),
      );
    } on ApiException {
      // Never block the paste on this — fall back to the pasted link.
      return ResolvedLink(url: url, isShare: false);
    }
  }

  Future<CapturedProduct> price({
    String? storeKey,
    required String sourceUrl,
    required String title,
    String? imageUrl,
    required double sourcePrice,
    String? sourceCurrency,
    String? color,
    String? size,
  }) async {
    final json = await _client.post('/capture', data: {
      if (storeKey != null) 'store_key': storeKey,
      'source_url': sourceUrl,
      'title': title,
      if (imageUrl != null) 'image_url': imageUrl,
      'source_price': sourcePrice,
      if (sourceCurrency != null) 'source_currency': sourceCurrency,
      if (color != null) 'color': color,
      if (size != null) 'size': size,
    });
    return CapturedProduct.fromJson(json);
  }
}

/// Outcome of [CaptureApi.resolve]: the URL to actually load, and whether it
/// came from an app share link (in which case [sku] is the store's goods id).
class ResolvedLink {
  const ResolvedLink({
    required this.url,
    required this.isShare,
    this.isCart = false,
    this.isCollection = false,
    this.readOnDevice = false,
    this.storeKey,
    this.items = const [],
    this.sku,
  });

  final String url;
  final bool isShare;

  /// True when the link shared a whole CART rather than a single product —
  /// [url] then points at the store's shared-cart landing page.
  final bool isCart;

  /// True for a shared list the server has already read (Trendyol shares
  /// collections, not carts) — [items] holds the rows, so no page is loaded.
  final bool isCollection;

  /// The store refused the server (Trendyol blocks data-centre IPs), so [url]
  /// is the page for the app to read itself — [items] is empty.
  final bool readOnDevice;

  /// The store the link belongs to, when the server knows it (e.g. trendyol).
  final String? storeKey;

  /// The rows of a collection, as the server read them.
  final List<Map<String, dynamic>> items;
  final String? sku;
}
