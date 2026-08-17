/// The authenticated user as returned by the Heama API.
class ApiUser {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? city;
  final bool isAdmin;
  final int walletBalanceIqd;

  const ApiUser({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.city,
    this.isAdmin = false,
    this.walletBalanceIqd = 0,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String?,
      isAdmin: (json['is_admin'] ?? false) as bool,
      walletBalanceIqd: (json['wallet_balance_iqd'] ?? 0) as int,
    );
  }
}
