import 'api_client.dart';

/// A discount code as the server describes it.
class Coupon {
  const Coupon({
    required this.id,
    required this.code,
    required this.percent,
    this.expiresAt,
    this.isActive = true,
    this.expired = false,
    this.timesUsed = 0,
  });

  final int id;
  final String code;

  /// Percentage off the items total, e.g. 10 = 10%.
  final double percent;
  final DateTime? expiresAt;

  // Admin view only.
  final bool isActive;
  final bool expired;
  final int timesUsed;

  factory Coupon.fromJson(Map<String, dynamic> j) => Coupon(
        id: (j['id'] ?? 0) as int,
        code: (j['code'] ?? '') as String,
        percent: ((j['percent'] ?? 0) as num).toDouble(),
        expiresAt: j['expires_at'] == null ? null : DateTime.tryParse(j['expires_at'] as String),
        isActive: (j['is_active'] ?? true) as bool,
        expired: (j['expired'] ?? false) as bool,
        timesUsed: (j['times_used'] ?? 0) as int,
      );

  /// This coupon's saving on [itemsTotal] in [currency] — the server's own
  /// rounding: whole dinars, or cents for dollars.
  num discountOn(num itemsTotal, String currency) {
    final d = itemsTotal * percent / 100;
    return currency.toUpperCase() == 'USD' ? (d * 100).round() / 100 : d.round();
  }

  /// "10%" / "12.5%".
  String get percentLabel =>
      '${percent == percent.roundToDouble() ? percent.toInt() : percent}%';
}

class CouponApi {
  CouponApi(this._client);
  final ApiClient _client;

  /// May the signed-in customer (or, for an admin, [customerId]) use [code]?
  /// Throws [ApiException] with the reason when not.
  Future<Coupon> check(String code, {int? customerId}) async {
    final json = await _client.post('/coupons/check', data: {
      'code': code.trim(),
      if (customerId != null) 'customer_id': customerId,
    });
    return Coupon.fromJson(json['data'] as Map<String, dynamic>);
  }

  // ---- Admin ----

  Future<List<Coupon>> list() async {
    final json = await _client.get('/admin/coupons');
    return ((json['data'] as List?) ?? const [])
        .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Coupon> create({required String code, required double percent, DateTime? expiresAt}) async {
    final json = await _client.post('/admin/coupons', data: {
      'code': code.trim(),
      'percent': percent,
      if (expiresAt != null)
        'expires_at':
            '${expiresAt.year.toString().padLeft(4, '0')}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')}',
    });
    return Coupon.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<Coupon> setActive(int id, bool active) async {
    final json = await _client.patch('/admin/coupons/$id', data: {'is_active': active});
    return Coupon.fromJson(json['data'] as Map<String, dynamic>);
  }
}
