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
