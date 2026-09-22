import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/charge_math.dart';
import '../../utils/format.dart';

/// The two currencies the shop buys in, and what each converts to.
enum RateKind {
  /// Shein: dollar prices, charged in dinars — priced by the cart's own rule.
  usd,

  /// Trendyol: lira prices, shown in dollars at the admin's lira rate
  /// (settings `fx_usd_tl_turkish`, e.g. $1 = 48 TL).
  tryl;

  String get flags => this == usd ? '🇺🇸  →  🇮🇶' : '🇹🇷  →  🇺🇸';
  String get symbol => this == usd ? '\$' : '₺';
  String get unit => this == usd ? '\$' : 'TL';

  bool known(ChargeMath m) => this == usd ? m.hasUsd : m.hasTlUsd;
}

/// The converted amount, large: dinars for dollars, dollars for lira.
Widget _amountText(BuildContext context, RateKind kind, ChargeMath m, num amount,
    {required double size, Color color = AppColors.ink, Color unitColor = AppColors.muted}) {
  final l = AppLocalizations.of(context);
  if (kind == RateKind.tryl) {
    return Text(formatMoney(m.tlToUsd(amount), 'USD'),
        style: AppFonts.display(fontSize: size, color: color));
  }
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Text(formatIqd(m.usdToIqd(amount)), style: AppFonts.display(fontSize: size, color: color)),
      const SizedBox(width: 4),
      Text(l.iqd,
          style: AppFonts.body(
              fontSize: size * 0.5, fontWeight: FontWeight.w700, color: unitColor)),
    ],
  );
}

/// The Me page's rate cards: 100 dollars in dinars, priced by the cart's own
/// rule ([ChargeMath]), and 100 lira in dollars at the admin's lira rate.
/// Tapping a card opens a calculator.
class RateCards extends StatelessWidget {
  const RateCards({super.key});

  @override
  Widget build(BuildContext context) {
    final math = context.watch<WalletProvider>().chargeMath;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      // Equal heights side by side without the unbounded-height crash that
      // CrossAxisAlignment.stretch causes inside the page's ListView.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _RateCard(kind: RateKind.usd, math: math)),
            const SizedBox(width: 10),
            Expanded(child: _RateCard(kind: RateKind.tryl, math: math)),
          ],
        ),
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.kind, required this.math});

  final RateKind kind;
  final ChargeMath math;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final known = kind.known(math);

    return GestureDetector(
      onTap: known ? () => showRateCalculator(context, kind: kind, math: math) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        // The same shell as the balance cards above, so the page reads as one.
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(color: Color(0x14211B3E), blurRadius: 22, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cloud,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(kind.flags, style: const TextStyle(fontSize: 12)),
                ),
                const Spacer(),
                if (known)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColors.saffron, AppColors.pomegranate]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calculate_outlined, size: 15, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('100 ${kind.unit}',
                style: AppFonts.body(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
            const SizedBox(height: 2),
            if (known)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: _amountText(context, kind, math, 100, size: 21),
              )
            else
              Text(l.rateNotSet,
                  style: AppFonts.body(
                      fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
            // The whole chain at a glance: "48 TL = $1 = 1,550 IQD".
            if (known && kind == RateKind.tryl) ...[
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(_tlChain(math, l),
                    style: AppFonts.body(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
              ),
            ],
            const Spacer(),
            const SizedBox(height: 10),
            if (known)
              Text(l.tapToCalculate,
                  style: AppFonts.body(
                      fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
          ],
        ),
      ),
    );
  }
}

/// A converter for one currency: type an amount and see, as you go, exactly
/// what the cart would charge for it.
Future<void> showRateCalculator(
  BuildContext context, {
  required RateKind kind,
  required ChargeMath math,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RateCalculator(kind: kind, math: math),
  );
}

class _RateCalculator extends StatefulWidget {
  const _RateCalculator({required this.kind, required this.math});

  final RateKind kind;
  final ChargeMath math;

  @override
  State<_RateCalculator> createState() => _RateCalculatorState();
}

class _RateCalculatorState extends State<_RateCalculator> {
  // Owned here and disposed with the sheet — disposing one from the caller
  // right after a sheet closes trips the framework's `_dependents` assertion.
  late final TextEditingController _amount = TextEditingController(text: '100');

  static const _quick = [10, 50, 100, 500, 1000];

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// Accepts a comma or a dot as the decimal mark.
  num get _value => num.tryParse(_amount.text.trim().replaceAll(',', '.')) ?? 0;

  void _setQuick(int v) {
    _amount.text = '$v';
    _amount.selection = TextSelection.collapsed(offset: _amount.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final kind = widget.kind;
    final m = widget.math;
    final isLira = kind == RateKind.tryl;
    final title = isLira ? l.liraToDollar : l.dollarToDinar;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.line, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cloud,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(kind.flags, style: const TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(title, style: AppFonts.display(fontSize: 18))),
                ],
              ),
              const SizedBox(height: 18),
              Text(l.amountLabel,
                  style: AppFonts.body(
                      fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
              const SizedBox(height: 6),
              TextField(
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                onChanged: (_) => setState(() {}),
                style: AppFonts.display(fontSize: 24),
                decoration: InputDecoration(
                  isDense: true,
                  prefixText: '${kind.symbol} ',
                  prefixStyle: AppFonts.display(fontSize: 24, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 12),
              // Common amounts, one tap each.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in _quick)
                    GestureDetector(
                      onTap: () => _setQuick(v),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                          color: _value == v ? AppColors.midnight : AppColors.cloud,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _value == v ? AppColors.midnight : AppColors.line),
                        ),
                        child: Text('${kind.symbol}$v',
                            style: AppFonts.body(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _value == v ? Colors.white : AppColors.ink)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // The answer, in the page header's own midnight gradient.
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                    Text(isLira ? l.inDollars : l.inDinars,
                        style: AppFonts.body(
                            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onDarkMuted)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: _amountText(context, kind, m, _value,
                          size: 28, color: Colors.white, unitColor: AppColors.saffron),
                    ),
                    // Lira: the same amount in dinars too, at the Turkish rates.
                    if (kind == RateKind.tryl) ...[
                      const SizedBox(height: 4),
                      Text('≈ ${formatIqd(m.tlToIqd(_value))} ${l.iqd}  ·  ${_tlChain(m, l)}',
                          style: AppFonts.body(fontSize: 12, color: AppColors.onDarkMuted)),
                    ],
                  ],
                ),
              ),
              // Dollars follow the cart's own rule, so say so. The lira figure is
              // the plain settings rate, not a cart charge — no such claim.
              if (!isLira) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.verified_outlined, size: 14, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(l.sameAsCart,
                          style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "48 TL = $1 = 1,550 IQD" — the lira rate and the Turkish dinar rate together.
String _tlChain(ChargeMath m, AppLocalizations l) {
  final tl = m.tlPerUsd;
  final tlText = tl == tl.roundToDouble() ? '${tl.round()}' : tl.toStringAsFixed(2);
  return '$tlText TL = \$1 = ${formatIqd(m.iqdPerUsdTurkish)} ${l.iqd}';
}
