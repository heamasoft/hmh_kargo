import '../models/approval.dart';
import 'api_client.dart';

/// Shipping-fee approval requests (admin re-priced an item's shipping; the
/// customer must accept or reject before the item is bought).
class ApprovalApi {
  ApprovalApi(this._client);
  final ApiClient _client;

  Future<List<ShippingApproval>> list({String status = 'pending'}) async {
    final json = await _client.get('/approvals?status=$status');
    final list = (json['data'] as List?) ?? [];
    return list
        .map((e) => ShippingApproval.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> accept(int id) async {
    await _client.post('/approvals/$id/accept');
  }

  Future<void> reject(int id) async {
    await _client.post('/approvals/$id/reject');
  }
}
