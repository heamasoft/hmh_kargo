import '../utils/charge_math.dart';

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

  /// IQD per 1 USD, from the system FX rate — shown on the Me page's rate card.
  final num usdRate;

  /// IQD per 1 TL, from the system FX rate. 0 until the server provides one —
  /// the rate card then says so rather than showing a made-up figure.
  final num tryRate;

  /// Lira per 1 USD from the admin's settings (`fx_usd_tl_turkish`) — the Me
  /// page's lira card converts TL to dollars with it. 0 until the server sends it.
  final num usdTlRate;

  /// Dinars per dollar for Turkish orders (settings `fx_usd_iqd_turkish`).
  final num usdIqdTurkish;

  /// The rest of the server's pricing rule (see [ChargeMath]) — with the rates
  /// above, enough to reproduce exactly what the cart charges.
  final num markupPercent;
  final num roundingStepIqd;
  final num roundingStepUsd;

  ChargeMath get chargeMath => ChargeMath(
        usdRate: usdRate,
        tryRate: tryRate,
        markupPercent: markupPercent,
        roundingStepIqd: roundingStepIqd,
        roundingStepUsd: roundingStepUsd,
        usdTlRate: usdTlRate,
        usdIqdTurkish: usdIqdTurkish,
      );

  /// Total of cash-on-delivery orders still to pay on arrival, per currency.
  /// Kept separate from the balances — COD never draws down the prepaid wallet.
  final num outstandingCodIqd;
  final num outstandingCodUsd; // dollars
  final List<WalletTransaction> transactions;

  const WalletData({
    this.balanceIqd = 0,
    this.balanceUsd = 0,
    this.usdRate = 1500,
    this.tryRate = 0,
    this.usdTlRate = 0,
    this.usdIqdTurkish = 0,
    this.markupPercent = 0,
    this.roundingStepIqd = 250,
    this.roundingStepUsd = 0.25,
    this.outstandingCodIqd = 0,
    this.outstandingCodUsd = 0,
    this.transactions = const [],
  });

  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
        balanceIqd: (json['balance_iqd'] ?? 0) as num,
        balanceUsd: (json['balance_usd'] ?? 0) as num,
        usdRate: (json['usd_rate'] ?? 1500) as num,
        tryRate: (json['try_rate'] ?? 0) as num,
        usdTlRate: (json['usd_tl_rate'] ?? 0) as num,
        usdIqdTurkish: (json['usd_iqd_turkish'] ?? 0) as num,
        markupPercent: (json['markup_percent'] ?? 0) as num,
        roundingStepIqd: (json['rounding_step_iqd'] ?? 250) as num,
        roundingStepUsd: (json['rounding_step_usd'] ?? 0.25) as num,
        outstandingCodIqd: (json['outstanding_cod_iqd'] ?? 0) as num,
        outstandingCodUsd: (json['outstanding_cod_usd'] ?? 0) as num,
        transactions: ((json['transactions'] as List?) ?? [])
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
