import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/heama_toast.dart';
import '../addresses/address_form_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _pay = 0; // 0 = wallet (only active option)
  bool _placing = false;
  Address? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().load();
      context.read<AddressProvider>().load();
    });
  }

  Address? _current(AddressProvider p) => _selected ?? p.defaultAddress;

  void _pickAddress() {
    final p = context.read<AddressProvider>();
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.line, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 14),
            Text(l.deliverTo, style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...p.addresses.map((a) {
                      final sel = _current(p)?.id == a.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selected = a);
                          Navigator.pop(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.pomTintBg : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: sel ? AppColors.pomegranate : AppColors.line,
                                width: sel ? 1.4 : 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.recipientName,
                                        style: AppFonts.body(
                                            fontSize: 13.5, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 3),
                                    Text('${a.shortLine} · ${a.phone}',
                                        style: AppFonts.body(
                                            fontSize: 11.5, color: AppColors.muted)),
                                    Text(a.street,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.body(
                                            fontSize: 11.5, color: AppColors.muted)),
                                  ],
                                ),
                              ),
                              Icon(
                                  sel
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: sel ? AppColors.pomegranate : AppColors.line,
                                  size: 22),
                            ],
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showAddressForm(context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, size: 18, color: AppColors.pomegranate),
                            const SizedBox(width: 6),
                            Text(l.addAddress,
                                style: AppFonts.body(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.pomegranate)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_placing) return;
    final l = AppLocalizations.of(context);
    final sel = _current(context.read<AddressProvider>());
    if (sel == null) {
      // No saved address — send the user to add one.
      showHeamaToast(context, l.noAddressesTitle);
      _pickAddress();
      return;
    }
    final address = {
      'recipient_name': sel.recipientName,
      'governorate': sel.governorate,
      'city': sel.city,
      'street': sel.street,
      'phone': sel.phone,
    };

    final method = _pay == 2 ? 'cod' : 'wallet';
    setState(() => _placing = true);
    try {
      final (_, balances) = await context
          .read<OrdersProvider>()
          .placeOrder(address, paymentMethod: method);
      if (!mounted) return;
      context.read<CartProvider>().clearLocal();
      context.read<WalletProvider>().setBalances(iqd: balances['IQD'], usd: balances['USD']);
      // Refresh so a COD order's "to pay on delivery" total updates too.
      context.read<WalletProvider>().load();
      showHeamaToast(context, '${l.orderPlaced} ✓');
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (r) => false, arguments: 3);
      });
    } on ApiException catch (e) {
      if (mounted) showHeamaToast(context, e.message);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cart = context.watch<CartProvider>();
    final wallet = context.watch<WalletProvider>();
    final addresses = context.watch<AddressProvider>();
    final selected = _current(addresses);
    // A mixed cart is checked out as one order per currency; show each total.
    final total = cart.totals.isEmpty
        ? '—'
        : cart.totals
            .map((t) => formatMoney(t.totalIqd, t.currency, iqdLabel: l.iqd))
            .join('  +  ');
    final walletLine =
        '${formatMoney(wallet.balanceIqd, 'IQD', iqdLabel: l.iqd)} · ${formatMoney(wallet.balanceUsd, 'USD')}';

    final methods = [
      (Icons.account_balance_wallet, l.heamaWallet, l.walletBalanceLine(walletLine), true),
      (Icons.smartphone, l.fastpay, l.fastpaySub, false),
      (Icons.payments_outlined, l.cashOnDelivery, l.cashOnDeliverySub, true),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 18, 4),
              child: Row(
                children: [
                  BackChip(onTap: () => Navigator.pop(context), size: 32),
                  const SizedBox(width: 10),
                  Text(l.checkout, style: AppFonts.display(fontSize: 21)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
              child: Text(l.totalToPay(total),
                  style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
            ),
            _sectionLabel(l.deliverTo),
            Container(
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: AppColors.pinBg, borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.location_on, size: 18, color: AppColors.midnight),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: selected == null
                        ? Text(l.noAddressesTitle,
                            style: AppFonts.body(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(selected.recipientName,
                                  style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Text('${selected.shortLine} · ${selected.phone}',
                                  style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                              Text(selected.street,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                            ],
                          ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickAddress,
                    child: Text(selected == null ? l.addAddress : l.change,
                        style: AppFonts.body(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
                  ),
                ],
              ),
            ),
            _sectionLabel(l.paymentMethod),
            ...List.generate(methods.length, (i) {
              final (icon, title, sub, enabled) = methods[i];
              final sel = _pay == i && enabled;
              return Opacity(
                opacity: enabled ? 1 : 0.5,
                child: GestureDetector(
                  onTap: enabled ? () => setState(() => _pay = i) : null,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(18, 0, 18, 11),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.pomTintBg : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: sel ? AppColors.pomegranate : AppColors.line, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(12)),
                          child: Icon(icon, size: 20, color: AppColors.midnight),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(title, style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                  if (!enabled) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.cloud, borderRadius: BorderRadius.circular(6)),
                                      child: Text('Soon',
                                          style: AppFonts.body(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.muted)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(sub, style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sel ? AppColors.pomegranate : Colors.white,
                            border: Border.all(color: sel ? AppColors.pomegranate : AppColors.line, width: 2),
                          ),
                          child: sel
                              ? const Center(child: Icon(Icons.circle, size: 6, color: Colors.white))
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: GestureDetector(
                onTap: cart.isEmpty ? null : _placeOrder,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: cart.isEmpty ? AppColors.muted : AppColors.ink,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(_placing ? '…' : l.placeOrder(total),
                      style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 9),
        child: Text(text.toUpperCase(),
            style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
      );
}
