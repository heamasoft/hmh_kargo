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

  Future<void> loadStores() async {
    if (stores.isNotEmpty) return;
    loadingStores = true;
    notifyListeners();
    try {
      stores = await _catalog.getStores();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loadingStores = false;
      notifyListeners();
    }
  }

  Future<void> loadTrending() async {
    loadingTrending = true;
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
