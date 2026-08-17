import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/back_chip.dart';

/// Which kinds of ledger entries to show.
enum _LedgerFilter { all, topUps, payments, refunds }

/// The ledger for ONE wallet currency (IQD or USD): the balance, a type filter,
/// and every transaction in that currency. Opened by tapping a balance card.
class WalletLedgerScreen extends StatefulWidget {
  final String currency; // 'IQD' or 'USD'
  const WalletLedgerScreen({super.key, required this.currency});

  @override
  State<WalletLedgerScreen> createState() => _WalletLedgerScreenState();
}

class _WalletLedgerScreenState extends State<WalletLedgerScreen> {
  _LedgerFilter _filter = _LedgerFilter.all;

  @override
  void initState() {
    super.initState();
    // Refresh so the ledger is current when opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WalletProvider>().load();
    });
  }

  String get _cur => widget.currency.toUpperCase();

  bool _matches(WalletTransaction t) {
    final type = t.type.toLowerCase();
    switch (_filter) {
      case _LedgerFilter.all:
        return true;
      case _LedgerFilter.topUps:
        return type == 'topup';
      case _LedgerFilter.payments:
        return type == 'debit' || type == 'cod';
      case _LedgerFilter.refunds:
        return type == 'refund';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = context.watch<WalletProvider>();
    final balance = _cur == 'USD' ? w.balanceUsd : w.balanceIqd;

    // Only this currency's entries, newest first (as returned by the API), then
    // the selected type filter.
    final entries = w.data.transactions
        .where((t) => (t.currency.isEmpty ? 'IQD' : t.currency).toUpperCase() == _cur)
        .where(_matches)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: back + title + balance.
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Row(
                children: [
                  BackChip(onTap: () => Navigator.pop(context), size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.walletLedgerTitle(_cur),
                        style: AppFonts.display(fontSize: 18)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.midnight, AppColors.midnight700],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_cur == 'USD' ? 'USD' : l.iqd,
                        style: AppFonts.body(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onDarkMuted)),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(formatMoney(balance, _cur, iqdLabel: l.iqd),
                          style: AppFonts.display(fontSize: 28, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            // Filter chips.
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  _chip(l.filterAll, _LedgerFilter.all),
                  _chip(l.filterTopUps, _LedgerFilter.topUps),
                  _chip(l.filterPayments, _LedgerFilter.payments),
                  _chip(l.filterRefunds, _LedgerFilter.refunds),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text('—',
                          style: AppFonts.display(fontSize: 22, color: AppColors.muted)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (_, i) => _row(l, entries[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, _LedgerFilter value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : AppColors.cloud,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(label,
              style: AppFonts.body(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.muted)),
        ),
      ),
    );
  }

  Widget _row(AppLocalizations l, WalletTransaction t) {
    final positive = t.amountIqd >= 0;
    final sign = positive ? '+' : '−';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: AppColors.cloud, borderRadius: BorderRadius.circular(10)),
            child: Icon(positive ? Icons.south_west : Icons.north_east,
                size: 17, color: positive ? AppColors.green : AppColors.pomegranate),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.note ?? t.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w600)),
                if (t.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(_fmtDate(t.createdAt!),
                      style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          Text('$sign${formatMoney(t.amountIqd.abs(), t.currency, iqdLabel: l.iqd)}',
              style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: positive ? AppColors.green : AppColors.ink)),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
