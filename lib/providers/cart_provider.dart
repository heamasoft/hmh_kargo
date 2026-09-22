import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/captured_product.dart';
import '../models/product.dart';
import '../services/api_client.dart';
import '../services/cart_api.dart';
import '../services/coupon_api.dart';

/// Server-backed cart. Every mutation returns the fresh cart from the API.
class CartProvider extends ChangeNotifier {
  CartProvider(ApiClient client)
      : _api = CartApi(client),
        _coupons = CouponApi(client);
  final CartApi _api;
  final CouponApi _coupons;

  /// The discount code the shopper applied, shown off the cart's total and
  /// sent with the order (the server checks it again and spends its one use).
  Coupon? coupon;

  /// Checks [code] and keeps it on the cart. Returns null, or why it can't
  /// be used (unknown, expired, already used…).
  Future<String?> applyCoupon(String code, {int? customerId}) async {
    try {
      coupon = await _coupons.check(code, customerId: customerId);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  void removeCoupon() {
    coupon = null;
    notifyListeners();
  }

  /// The coupon's saving on one currency's items (0 without a coupon).
  num discountFor(CartTotals t) => coupon?.discountOn(t.itemsTotalIqd, t.currency) ?? 0;

  /// What that currency's order will cost after the coupon.
  num payableFor(CartTotals t) => t.totalIqd - discountFor(t);

  Cart _cart = const Cart();
  bool loading = false;
  bool busy = false;
  String? error;

  Cart get cart => _cart;
  List<CartLine> get items => _cart.items;
  List<CartTotals> get totals => _cart.totals;
  int get count => _cart.count;
  bool get isEmpty => _cart.isEmpty;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      _cart = await _api.getCart();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Adds a product; returns true on success (so the UI can toast/navigate).
  Future<bool> addProduct(Product product, {String? color, String? size, int qty = 1}) async {
    return _mutate(() => _api.addProduct(product, color: color, size: size, qty: qty));
  }

  /// Adds a captured (scraped + priced) product to the cart.
  Future<bool> addCaptured(CapturedProduct c,
      {String? color, String? size, String? note, String? sku, int qty = 1}) async {
    return _mutate(() => _api.addCaptured(c, color: color, size: size, note: note, sku: sku, qty: qty));
  }

  Future<bool> updateQty(int itemId, int qty) async {
    if (qty < 1) return true;
    return _mutate(() => _api.updateQty(itemId, qty));
  }

  Future<bool> remove(int itemId) async {
    return _mutate(() => _api.remove(itemId));
  }

  /// Clears local state after a successful order (server already emptied it).
  void clearLocal() {
    _cart = const Cart();
    coupon = null; // spent with the order
    notifyListeners();
  }

  Future<bool> _mutate(Future<Cart> Function() action) async {
    busy = true;
    notifyListeners();
    try {
      _cart = await action();
      error = null;
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
