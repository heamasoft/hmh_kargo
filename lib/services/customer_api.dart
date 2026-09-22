import '../models/address.dart';
import 'api_client.dart';

/// A customer an admin can check out for, with their saved addresses.
class AdminCustomer {
  const AdminCustomer({
    required this.id,
    required this.name,
    this.phone = '',
    this.city = '',
    this.addresses = const [],
  });

  final int id;
  final String name;
  final String phone;
  final String city;

  /// Default address first.
  final List<Address> addresses;

  factory AdminCustomer.fromJson(Map<String, dynamic> j) => AdminCustomer(
        id: j['id'] as int,
        name: (j['name'] ?? '') as String,
        phone: (j['phone'] ?? '') as String? ?? '',
        city: (j['city'] ?? '') as String? ?? '',
        addresses: ((j['addresses'] as List?) ?? const [])
            .map((e) => Address.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Admin-only customer lookup (the server refuses anyone else).
class CustomerApi {
  CustomerApi(this._client);
  final ApiClient _client;

  /// Customers whose name or phone contains [query] (all when empty).
  Future<List<AdminCustomer>> search(String query) async {
    final q = Uri.encodeQueryComponent(query.trim());
    final json = await _client.get('/admin/customers?q=$q');
    return ((json['data'] as List?) ?? const [])
        .map((e) => AdminCustomer.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
