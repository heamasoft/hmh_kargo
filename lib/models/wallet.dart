/// A single wallet ledger entry. [amountIqd]/[balanceAfter] are real amounts in
/// [currency] (IQD dinars / USD dollars).
class WalletTransaction {
  final int id;
  final String type; // topup | debit | refund | adjustment
  final String currency;
  final num amountIqd;
  final num balanceAfter;
  final String? note;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    this.currency = 'IQD',
    required this.amountIqd,
    required this.balanceAfter,
    this.note,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
        id: json['id'] as int,
        type: (json['type'] ?? '') as String,
        currency: (json['currency'] ?? 'IQD') as String,
        amountIqd: (json['amount_iqd'] ?? 0) as num,
        balanceAfter: (json['balance_after'] ?? 0) as num,
        note: json['note'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );
}

/// Wallet balances (IQD + USD) + outstanding cash-on-delivery per currency +
/// recent transactions. Amounts are real (IQD dinars / USD dollars).
class WalletData {
  final num balanceIqd;
  final num balanceUsd; // dollars

  /// IQD per 1 USD, from the system FX rate — used to preview an exchange.
  final num usdRate;

  /// Total of cash-on-delivery orders still to pay on arrival, per currency.
  /// Kept separate from the balances — COD never draws down the prepaid wallet.
  final num outstandingCodIqd;
  final num outstandingCodUsd; // dollars
  final List<WalletTransaction> transactions;

  const WalletData({
    this.balanceIqd = 0,
    this.balanceUsd = 0,
    this.usdRate = 1500,
    this.outstandingCodIqd = 0,
    this.outstandingCodUsd = 0,
    this.transactions = const [],
  });

  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
        balanceIqd: (json['balance_iqd'] ?? 0) as num,
        balanceUsd: (json['balance_usd'] ?? 0) as num,
        usdRate: (json['usd_rate'] ?? 1500) as num,
        outstandingCodIqd: (json['outstanding_cod_iqd'] ?? 0) as num,
        outstandingCodUsd: (json['outstanding_cod_usd'] ?? 0) as num,
        transactions: ((json['transactions'] as List?) ?? [])
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
