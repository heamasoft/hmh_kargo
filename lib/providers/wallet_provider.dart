import 'package:flutter/foundation.dart';

import '../models/wallet.dart';
import '../services/api_client.dart';
import '../services/wallet_api.dart';

/// Loads the wallet balance + transaction ledger.
class WalletProvider extends ChangeNotifier {
  WalletProvider(ApiClient client) : _api = WalletApi(client);
  final WalletApi _api;

  WalletData data = const WalletData();
  bool loading = false;
  String? error;

  num get balanceIqd => data.balanceIqd;
  num get balanceUsd => data.balanceUsd;
  num get usdRate => data.usdRate;
  num get outstandingCodIqd => data.outstandingCodIqd;
  num get outstandingCodUsd => data.outstandingCodUsd;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      data = await _api.getWallet();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Optimistically set both balances (e.g., right after placing an order).
  /// Preserves the outstanding-COD figures; call [load] to refresh from the API.
  void setBalances({num? iqd, num? usd}) {
    data = WalletData(
      balanceIqd: iqd ?? data.balanceIqd,
      balanceUsd: usd ?? data.balanceUsd,
      usdRate: data.usdRate,
      outstandingCodIqd: data.outstandingCodIqd,
      outstandingCodUsd: data.outstandingCodUsd,
      transactions: data.transactions,
    );
    notifyListeners();
  }

  /// Exchanges [amount] of [from] into [to] at the system rate. Returns true on
  /// success (balances updated + ledger refreshed). Sets [error] on failure.
  Future<bool> exchange({required String from, required String to, required num amount}) async {
    try {
      final balances = await _api.exchange(from: from, to: to, amount: amount);
      setBalances(iqd: balances['IQD'], usd: balances['USD']);
      error = null;
      await load(); // refresh ledger so the exchange entries show
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    }
  }
}
