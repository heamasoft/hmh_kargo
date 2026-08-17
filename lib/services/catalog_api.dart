import '../models/product.dart';
import '../models/store.dart';
import 'api_client.dart';

/// Read-only catalog: stores + products.
class CatalogApi {
  CatalogApi(this._client);
  final ApiClient _client;

  Future<List<Store>> getStores() async {
    final json = await _client.get('/stores');
    final list = (json['data'] as List?) ?? [];
    return list.map((e) => Store.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Most-ordered products (real popularity from the orders in the database).
  Future<List<Product>> getTrending() async {
    final json = await _client.get('/trending');
    final list = (json['data'] as List?) ?? [];
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Product>> getProducts({bool? trending, String? store, String? category}) async {
    final params = <String>[];
    if (trending == true) params.add('trending=1');
    if (store != null) params.add('store=$store');
    if (category != null && category != 'all') params.add('category=$category');
    final qs = params.isEmpty ? '' : '?${params.join('&')}';

    final json = await _client.get('/products$qs');
    final list = (json['data'] as List?) ?? [];
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }
}
