import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/cart.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/format.dart';
import 'heama_toast.dart';

/// A cart line's price: read by a shopper, set by an admin.
///
/// What a line costs is settled with the customer, and that happens after the
/// item was captured as often as before — so the price is open to an admin
/// where the whole cart is in front of them, rather than only at the moment of
/// adding. Every total is worked out by the server from the cart, so a change
/// here moves the cart's totals and everything downstream with it.
class AdminPriceField extends StatelessWidget {
  const AdminPriceField({super.key, required this.item});

  final CartLine item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;

    if (!isAdmin) {
      return Text(
        formatMoney(item.iqdPrice, item.chargeCurrency, iqdLabel: l.iqd),
        style: AppFonts.display(fontSize: 15),
      );
    }

    return _MoneyEditor(
      value: item.iqdPrice,
      currency: item.chargeCurrency,
      style: AppFonts.display(fontSize: 15),
      maxWidth: 128,
      onSave: (amount) =>
          context.read<CartProvider>().updatePrice(item.id, amount ?? item.iqdPrice),
    );
  }
}

/// What this line costs to bring, under its price.
///
/// The flat rate is a guess made before anyone has weighed the parcel — a
/// scarf and a winter coat both came out at $2 — so an admin can put the real
/// figure on the line here, and clearing the field puts it back on the rate.
/// The figure is per unit, because each unit ships as its own order; where the
/// line holds more than one, the quantity is shown beside it.
class AdminShippingField extends StatelessWidget {
  const AdminShippingField({super.key, required this.item});

  final CartLine item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;

    final label = Text(
      '+ ${l.itemShipping}:',
      style: AppFonts.body(
          fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.transitText),
    );

    if (!isAdmin) {
      // Nothing to say when nothing is charged — the international side ships
      // free, and a stock item's price already covers it.
      if (item.shipping <= 0) return const SizedBox.shrink();
      return Row(
        children: [
          label,
          const SizedBox(width: 4),
          Text(
            formatMoney(item.shipping, item.chargeCurrency, iqdLabel: l.iqd),
            style: AppFonts.body(
                fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.transitText),
          ),
        ],
      );
    }

    return Row(
      children: [
        label,
        const SizedBox(width: 4),
        Flexible(
          child: _MoneyEditor(
            value: item.shippingUnit,
            currency: item.chargeCurrency,
            style: AppFonts.body(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.transitText),
            maxWidth: 104,
            // An empty field means "whatever the standard rate is", which is
            // how an admin undoes a figure they no longer want.
            clearable: true,
            onSave: (amount) => context.read<CartProvider>().updateShipping(item.id, amount),
          ),
        ),
        // Per unit — so the line's own total is this times its quantity.
        if (item.qty > 1)
          Text(' × ${item.qty}', style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
      ],
    );
  }
}

/// An amount in one currency, typed in place and saved when the field is left.
///
/// Saving hands the cart to the server and takes back what it says the cart
/// now is, so a refused edit shows the old figure again rather than a number
/// that is only true on this phone.
class _MoneyEditor extends StatefulWidget {
  const _MoneyEditor({
    required this.value,
    required this.currency,
    required this.style,
    required this.onSave,
    required this.maxWidth,
    this.clearable = false,
  });

  final num value;
  final String currency;
  final TextStyle style;
  final double maxWidth;

  /// Whether an empty field is a value in itself — null, meaning "use the
  /// standard rate" — rather than a typo to be put back.
  final bool clearable;

  /// Returns false when the server would not have it.
  final Future<bool> Function(num? amount) onSave;

  @override
  State<_MoneyEditor> createState() => _MoneyEditorState();
}

class _MoneyEditorState extends State<_MoneyEditor> {
  late final TextEditingController _field = TextEditingController(text: _shown(widget.value));
  final _focus = FocusNode();
  bool _saving = false;

  /// Dinars are whole; dollars and lira keep their cents.
  String _shown(num amount) => widget.currency.toUpperCase() == 'IQD'
      ? amount.round().toString()
      : amount.toStringAsFixed(2);

  @override
  void didUpdateWidget(covariant _MoneyEditor old) {
    super.didUpdateWidget(old);
    // The cart came back from the server — follow it, unless it is being typed in.
    if (!_focus.hasFocus && widget.value != old.value) {
      _field.text = _shown(widget.value);
    }
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _field.text.trim();
    final typed = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));

    // Emptied on purpose, where that is allowed: hand back nothing.
    if (raw.isEmpty && widget.clearable) {
      await _send(null);
      return;
    }
    if (typed == null || typed < 0) {
      _field.text = _shown(widget.value); // not an amount — put it back
      return;
    }
    if ((typed - widget.value).abs() < 0.001) return;
    await _send(typed);
  }

  Future<void> _send(num? amount) async {
    final cart = context.read<CartProvider>();
    setState(() => _saving = true);
    final ok = await widget.onSave(amount);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      _field.text = _shown(widget.value);
      showHeamaToast(context, cart.error ?? 'Could not save that amount.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = widget.currency.toUpperCase();

    if (_saving) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: IntrinsicWidth(
        child: TextField(
          controller: _field,
          focusNode: _focus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          style: widget.style,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            suffixText: currency == 'IQD' ? l.iqd : currency,
            suffixStyle:
                AppFonts.body(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted),
          ),
          onSubmitted: (_) => _save(),
          onTapOutside: (_) {
            _focus.unfocus();
            _save();
          },
        ),
      ),
    );
  }
}
