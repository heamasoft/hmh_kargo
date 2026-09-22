import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/store.dart';
import '../services/api_client.dart';
import '../services/catalog_api.dart';

/// Loads stores + products from the API for the browse screens.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(ApiClient client) : _catalog = CatalogApi(client);
  final CatalogApi _catalog;

  List<Store> stores = [];
  List<Product> trending = [];
  List<Product> products = []; // storefront grid (filtered)
  List<Product> allProducts = []; // full catalog, for resolving saved items

  bool loadingStores = false;
  bool loadingTrending = false;
  bool loadingProducts = false;
  String? error;

  List<Store> get internationalStores =>
      stores.where((s) => s.region != 'turkiye').toList();
  List<Store> get turkiyeStores =>
      stores.where((s) => s.region == 'turkiye').toList();

  bool _storesFresh = false;

  /// Shows the stores kept from last time at once, then refreshes them from
  /// the server (once per session) — so Home never waits on the network.
  Future<void> loadStores() async {
    if (_storesFresh) return;
    if (stores.isEmpty) {
      final saved = await _catalog.cachedStores();
      if (saved != null && saved.isNotEmpty && stores.isEmpty) {
        stores = saved;
        notifyListeners();
      }
    }
    loadingStores = stores.isEmpty; // no spinner over the saved copy
    notifyListeners();
    try {
      stores = await _catalog.getStores();
      _storesFresh = true;
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loadingStores = false;
      notifyListeners();
    }
  }

  /// Same as [loadStores]: last launch's trending first, then the fresh list.
  Future<void> loadTrending() async {
    if (trending.isEmpty) {
      final saved = await _catalog.cachedTrending();
      if (saved != null && saved.isNotEmpty && trending.isEmpty) {
        trending = saved;
        notifyListeners();
      }
    }
    loadingTrending = trending.isEmpty;
    notifyListeners();
    try {
      trending = await _catalog.getTrending();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loadingTrending = false;
      notifyListeners();
    }
  }

  /// Loads the full catalog once (used to resolve saved/favorite items).
  Future<void> loadAllProducts() async {
    if (allProducts.isNotEmpty) return;
    try {
      allProducts = await _catalog.getProducts();
      notifyListeners();
    } on ApiException {
      // ignore — saved screen will just show empty
    }
  }

  Future<void> loadProducts({String? store, String? category}) async {
    loadingProducts = true;
    notifyListeners();
    try {
      products = await _catalog.getProducts(store: store, category: category);
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loadingProducts = false;
      notifyListeners();
    }
  }
}
