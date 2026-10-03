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
class AdminPriceField extends StatefulWidget {
  const AdminPriceField({super.key, required this.item});

  final CartLine item;

  @override
  State<AdminPriceField> createState() => _AdminPriceFieldState();
}

class _AdminPriceFieldState extends State<AdminPriceField> {
  late final TextEditingController _price = TextEditingController(text: _shown(widget.item.iqdPrice));
  final _focus = FocusNode();
  bool _saving = false;

  /// Dinars are whole; dollars and lira keep their cents.
  String _shown(num amount) => widget.item.chargeCurrency.toUpperCase() == 'IQD'
      ? amount.round().toString()
      : amount.toStringAsFixed(2);

  @override
  void didUpdateWidget(covariant AdminPriceField old) {
    super.didUpdateWidget(old);
    // The cart came back from the server — follow it, unless it is being typed in.
    if (!_focus.hasFocus && widget.item.iqdPrice != old.item.iqdPrice) {
      _price.text = _shown(widget.item.iqdPrice);
    }
  }

  @override
  void dispose() {
    _price.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final typed = double.tryParse(_price.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (typed == null || typed < 0) {
      _price.text = _shown(widget.item.iqdPrice); // not a price — put it back
      return;
    }
    if ((typed - widget.item.iqdPrice).abs() < 0.001) return;

    final cart = context.read<CartProvider>();
    setState(() => _saving = true);
    final ok = await cart.updatePrice(widget.item.id, typed);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      _price.text = _shown(widget.item.iqdPrice);
      showHeamaToast(context, cart.error ?? 'Could not save the price.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;

    if (!isAdmin) {
      return Text(
        formatMoney(widget.item.iqdPrice, widget.item.chargeCurrency, iqdLabel: l.iqd),
        style: AppFonts.display(fontSize: 15),
      );
    }

    final currency = widget.item.chargeCurrency.toUpperCase();
    if (_saving) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 128),
      child: IntrinsicWidth(
        child: TextField(
          controller: _price,
          focusNode: _focus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          style: AppFonts.display(fontSize: 15),
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
