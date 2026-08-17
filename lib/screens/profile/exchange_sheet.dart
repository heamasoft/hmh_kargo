import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/heama_toast.dart';

/// Bottom sheet to move money between the customer's IQD and USD balances at the
/// system FX rate.
Future<void> showExchangeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ExchangeSheet(),
  );
}

class _ExchangeSheet extends StatefulWidget {
  const _ExchangeSheet();

  @override
  State<_ExchangeSheet> createState() => _ExchangeSheetState();
}

class _ExchangeSheetState extends State<_ExchangeSheet> {
  bool _iqdToUsd = true; // direction
  final _amount = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  String get _from => _iqdToUsd ? 'IQD' : 'USD';
  String get _to => _iqdToUsd ? 'USD' : 'IQD';

  double get _amountValue => double.tryParse(_amount.text.trim()) ?? 0;

  /// Converts the entered amount into the target currency at [rate] (IQD/USD).
  num _converted(num rate) {
    final a = _amountValue;
    if (a <= 0 || rate <= 0) return 0;
    return _iqdToUsd ? a / rate : a * rate;
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_amountValue <= 0) {
      showHeamaToast(context, l.exchangeEnterAmount);
      return;
    }
    setState(() => _busy = true);
    final wallet = context.read<WalletProvider>();
    final ok = await wallet.exchange(from: _from, to: _to, amount: _amountValue);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showHeamaToast(context, l.exchangeDone);
      Navigator.pop(context);
    } else {
      showHeamaToast(context, wallet.error ?? 'Could not exchange.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = context.watch<WalletProvider>();
    final rate = w.usdRate;
    final receive = _converted(rate);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          18, 12, 18, MediaQuery.of(context).viewInsets.bottom + 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.line, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Text(l.exchange, style: AppFonts.display(fontSize: 18)),
          const SizedBox(height: 4),
          Text(l.exchangeRateLine(formatIqd(rate)),
              style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 16),

          // Direction: [FROM]  ⇄  [TO]
          Row(
            children: [
              Expanded(child: _currencyChip(_from)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _iqdToUsd = !_iqdToUsd),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: AppColors.pomegranate, shape: BoxShape.circle),
                    child: const Icon(Icons.swap_horiz, color: Colors.white, size: 21),
                  ),
                ),
              ),
              Expanded(child: _currencyChip(_to)),
            ],
          ),
          const SizedBox(height: 16),

          // Amount to exchange (in the FROM currency).
          Text('${l.exchangeAmount} · $_from',
              style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
          const SizedBox(height: 7),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: AppFonts.display(fontSize: 20),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              filled: true,
              fillColor: AppColors.cloud,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // Live "you'll receive".
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.cloud, borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.exchangeReceive,
                    style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
                Text(formatMoney(receive, _to, iqdLabel: l.iqd),
                    style: AppFonts.display(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _busy ? null : _submit,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: _busy ? AppColors.muted : AppColors.pomegranate,
                    borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(_busy ? '…' : l.exchangeCta,
                    style: AppFonts.body(
                        fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyChip(String code) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(code,
          style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w700)),
    );
  }
}
