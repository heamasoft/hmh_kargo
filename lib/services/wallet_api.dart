import '../models/wallet.dart';
import 'api_client.dart';

class WalletApi {
  WalletApi(this._client);
  final ApiClient _client;

  Future<WalletData> getWallet() async {
    return WalletData.fromJson(await _client.get('/wallet'));
  }

  /// Exchanges [amount] of [from] currency into [to] at the system rate.
  /// Returns the updated balances (by currency). Throws ApiException on failure
  /// (e.g. insufficient balance).
  Future<Map<String, num>> exchange({
    required String from,
    required String to,
    required num amount,
  }) async {
    final json = await _client.post('/wallet/exchange', data: {
      'from': from,
      'to': to,
      'amount': amount,
    });
    return {
      'IQD': (json['balance_iqd'] ?? 0) as num,
      'USD': (json['balance_usd'] ?? 0) as num,
    };
  }
}
