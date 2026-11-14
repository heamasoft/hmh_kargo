import '../models/cart.dart';
import '../models/captured_product.dart';
import '../models/product.dart';
import 'api_client.dart';

/// Cart operations against the API. Every call returns the updated cart.
class CartApi {
  CartApi(this._client);
  final ApiClient _client;

  Future<Cart> getCart() async {
    return Cart.fromJson(await _client.get('/cart'));
  }

  /// Adds a captured product (with chosen variant) to the cart.
  Future<Cart> addProduct(Product product, {String? color, String? size, int qty = 1}) async {
    final json = await _client.post('/cart/items', data: {
      'store_id': product.storeId,
      'source_url': product.sourceUrl ?? 'https://www.shein.com/${product.id}',
      'title': product.name,
      'image_url': product.imageUrl,
      'source_price': _usdToNumber(product.usd),
      'source_currency': 'USD',
      // Catalogue products (Shein) are charged in IQD.
      'charge_currency': 'IQD',
      'charge_amount': product.priceIqd,
      'iqd_price': product.priceIqd,
      'color': fitVariant(color),
      'size': fitVariant(size),
      'qty': qty,
    });
    return Cart.fromJson(json);
  }

  /// Adds a captured (scraped + priced) product to the cart.
  Future<Cart> addCaptured(CapturedProduct c,
      {String? color,
      String? size,
      String? note,
      String? sku,
      int qty = 1,
      String? storeName}) async {
    final json = await _client.post('/cart/items', data: {
      'store_id': c.storeId,
      // Which shop this came from, in words. One of ours is named by its own
      // row; an item added by hand carries the name read off its link, so the
      // order does not reach the admin with a URL and nothing else.
      'store_name': (storeName != null && storeName.isNotEmpty) ? storeName : c.storeName,
      'source_url': c.sourceUrl,
      'title': c.title,
      'image_url': c.imageUrl,
      'source_price': c.sourcePrice,
      'source_currency': c.sourceCurrency,
      'charge_currency': c.chargeCurrency,
      'charge_amount': c.chargeAmount,
      'iqd_price': c.iqdPrice,
      'color': fitVariant(color),
      'size': fitVariant(size),
      'note': note,
      'sku': sku,
      'qty': qty,
    });
    return Cart.fromJson(json);
  }

  /// Sets what one unit of a line costs. Admins only — the server ignores it
  /// from anyone else — and the cart comes back with its totals redone.
  Future<Cart> updatePrice(int itemId, num amount) async {
    return Cart.fromJson(
        await _client.patch('/cart/items/$itemId', data: {'charge_amount': amount}));
  }

  Future<Cart> updateQty(int itemId, int qty) async {
    return Cart.fromJson(await _client.patch('/cart/items/$itemId', data: {'qty': qty}));
  }

  Future<Cart> remove(int itemId) async {
    return Cart.fromJson(await _client.delete('/cart/items/$itemId'));
  }

  double _usdToNumber(String usd) {
    final cleaned = usd.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}

/// A colour or size as the server takes it: at most 60 characters.
///
/// A store's bundle can name its option at length ("D / Eyelash Book *1 +
/// Bond & Seal *1 + Tweezers *1 + Brush *1"), and a server that still checks
/// for 60 refuses the whole item over it. The first 60 characters say which
/// option it is; the link and the admin's own look at it say the rest.
String? fitVariant(String? v) {
  if (v == null) return null;
  final t = v.trim();
  return t.length <= 60 ? t : t.substring(0, 60).trimRight();
}
