import '../models/product.dart';
import '../models/store.dart';
import 'api_client.dart';

/// Read-only catalog: stores + products.
class CatalogApi {
  CatalogApi(this._client);
  final ApiClient _client;

  static List<Store> _stores(Map<String, dynamic> json) => ((json['data'] as List?) ?? [])
      .map((e) => Store.fromJson(e as Map<String, dynamic>))
      .toList();

  static List<Product> _products(Map<String, dynamic> json) => ((json['data'] as List?) ?? [])
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<List<Store>> getStores() async => _stores(await _client.getAndCache('/stores'));

  /// The stores as last loaded, kept on the phone — null the first time.
  Future<List<Store>?> cachedStores() async {
    final json = await _client.cached('/stores');
    return json == null ? null : _stores(json);
  }

  /// Most-ordered products (real popularity from the orders in the database).
  Future<List<Product>> getTrending() async => _products(await _client.getAndCache('/trending'));

  Future<List<Product>?> cachedTrending() async {
    final json = await _client.cached('/trending');
    return json == null ? null : _products(json);
  }

  Future<List<Product>> getProducts({bool? trending, String? store, String? category}) async {
    final params = <String>[];
    if (trending == true) params.add('trending=1');
    if (store != null) params.add('store=$store');
    if (category != null && category != 'all') params.add('category=$category');
    final qs = params.isEmpty ? '' : '?${params.join('&')}';

    return _products(await _client.get('/products$qs'));
  }
}
