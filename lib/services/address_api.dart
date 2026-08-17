import '../models/address.dart';
import 'api_client.dart';

/// CRUD for the user's saved delivery addresses.
class AddressApi {
  AddressApi(this._client);
  final ApiClient _client;

  List<Address> _parse(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? [];
    return list.map((e) => Address.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Address>> list() async => _parse(await _client.get('/addresses'));

  Future<Address> create(Map<String, dynamic> body) async {
    final json = await _client.post('/addresses', data: body);
    return Address.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<Address> update(int id, Map<String, dynamic> body) async {
    final json = await _client.patch('/addresses/$id', data: body);
    return Address.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<List<Address>> remove(int id) async =>
      _parse(await _client.delete('/addresses/$id'));
}
