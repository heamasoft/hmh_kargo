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
      'color': color,
      'size': size,
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
      'color': color,
      'size': size,
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

  /// Sets what one unit of a line costs to bring. Admins only, and per unit —
  /// each unit ships as its own order. A null amount puts the line back on the
  /// standard rate.
  Future<Cart> updateShipping(int itemId, num? amount) async {
    return Cart.fromJson(
        await _client.patch('/cart/items/$itemId', data: {'shipping_amount': amount}));
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
