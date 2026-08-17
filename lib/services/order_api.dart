import '../models/order.dart';
import 'api_client.dart';

/// Order placement + history.
class OrderApi {
  OrderApi(this._client);
  final ApiClient _client;

  /// Places an order from the cart. A mixed-currency cart yields one order per
  /// currency. Returns (orders, wallet balances by currency in minor units).
  Future<(List<Order>, Map<String, num>)> placeOrder({
    required Map<String, dynamic> address,
    String paymentMethod = 'wallet',
  }) async {
    final json = await _client.post('/orders', data: {
      'payment_method': paymentMethod,
      'address': address,
    });
    final orders = ((json['data'] as List?) ?? [])
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
    return (orders, _balances(json['wallet']));
  }

  static Map<String, num> _balances(dynamic w) {
    final m = (w as Map?) ?? const {};
    return {
      'IQD': (m['IQD'] ?? 0) as num,
      'USD': (m['USD'] ?? 0) as num,
    };
  }

  Future<List<Order>> getOrders() async {
    final json = await _client.get('/orders');
    final list = (json['data'] as List?) ?? [];
    return list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrder(String code) async {
    final json = await _client.get('/orders/$code');
    return Order.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Cancels an order (allowed only before it's purchased).
  /// Returns (updated order, wallet balances by currency).
  Future<(Order, Map<String, num>)> cancelOrder(String code) async {
    final json = await _client.post('/orders/$code/cancel');
    return (
      Order.fromJson(json['data'] as Map<String, dynamic>),
      _balances(json['wallet']),
    );
  }

  /// Cancels ONE item of a still-'placed' order — its price + shipping are
  /// refunded to the wallet and the order totals recomputed.
  /// Returns (updated order, wallet balances by currency).
  Future<(Order, Map<String, num>)> cancelOrderItem(String code, int itemId) async {
    final json = await _client.post('/orders/$code/items/$itemId/cancel');
    return (
      Order.fromJson(json['data'] as Map<String, dynamic>),
      _balances(json['wallet']),
    );
  }
}
