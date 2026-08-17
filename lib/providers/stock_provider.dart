import 'package:flutter/foundation.dart';

import '../models/stock_item.dart';
import '../services/api_client.dart';
import '../services/stock_api.dart';

/// The in-stock storefront: products already in the company, split into Shein
/// and other stores. Loaded on the home page; items can be added to the cart.
class StockProvider extends ChangeNotifier {
  StockProvider(ApiClient client) : _api = StockApi(client);
  final StockApi _api;

  List<StockItem> shein = [];
  List<StockItem> other = [];
  bool loading = false;
  String? error;

  bool get hasAny => shein.isNotEmpty || other.isNotEmpty;
  int get count => shein.length + other.length;

  /// The language the current lists were loaded in (so we can reload on change).
  String loadedLang = '';

  Future<void> load({String lang = 'en'}) async {
    loading = true;
    loadedLang = lang;
    notifyListeners();
    try {
      final res = await _api.list(lang: lang);
      shein = res.shein;
      other = res.other;
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Adds a stock item to the cart. Returns null on success, or an error message.
  /// On success the item is removed from the local lists (it's a single unit).
  Future<String?> addToCart(StockItem item) async {
    try {
      await _api.addToCart(item.itemId);
      shein.removeWhere((s) => s.itemId == item.itemId);
      other.removeWhere((s) => s.itemId == item.itemId);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
