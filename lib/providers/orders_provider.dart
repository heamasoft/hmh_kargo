import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../services/api_client.dart';
import '../services/order_api.dart';

/// Loads the user's orders and places new ones.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider(ApiClient client) : _api = OrderApi(client);
  final OrderApi _api;

  List<Order> orders = [];
  bool loading = false;
  bool placing = false;
  String? error;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      orders = await _api.getOrders();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Order> loadOne(String code) => _api.getOrder(code);

  /// Cancels an order and swaps the updated copy into the list.
  /// Returns the new wallet balances (by currency). Throws ApiException.
  Future<Map<String, num>> cancelOrder(String code) async {
    final (order, balances) = await _api.cancelOrder(code);
    final i = orders.indexWhere((o) => o.code == code);
    if (i >= 0) {
      orders[i] = order;
    }
    notifyListeners();
    return balances;
  }

  /// Cancels ONE item of a still-'placed' order and swaps the updated order in.
  /// Returns (updated order, wallet balances). Throws ApiException.
  Future<(Order, Map<String, num>)> cancelItem(String code, int itemId) async {
    final (order, balances) = await _api.cancelOrderItem(code, itemId);
    final i = orders.indexWhere((o) => o.code == code);
    if (i >= 0) {
      orders[i] = order;
    }
    notifyListeners();
    return (order, balances);
  }

  /// Places order(s) from the cart (one per currency).
  /// Returns (orders, wallet balances by currency). Throws ApiException.
  Future<(List<Order>, Map<String, num>)> placeOrder(Map<String, dynamic> address,
      {String paymentMethod = 'wallet'}) async {
    placing = true;
    notifyListeners();
    try {
      final result = await _api.placeOrder(address: address, paymentMethod: paymentMethod);
      orders.insertAll(0, result.$1);
      error = null;
      return result;
    } finally {
      placing = false;
      notifyListeners();
    }
  }
}
