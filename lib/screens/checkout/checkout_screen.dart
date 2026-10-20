import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/address.dart';
import '../../models/cart.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../services/customer_api.dart';
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

  /// Admin checkout: the customer this order is placed for (and charged to).
  AdminCustomer? _customer;

  /// Admin checkout: what each cart line costs to bring, per unit, keyed by
  /// cart item id. Kept here rather than saved to the cart, because the figure
  /// belongs to the order being placed — it is sent with it and stored on the
  /// order item. A line not in here ships at the standard rate.
  final Map<int, num> _shipping = {};

  bool get _isAdmin => context.read<AuthProvider>().user?.isAdmin ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().load();
      context.read<AddressProvider>().load();
    });
  }

  /// The addresses to deliver to: the chosen customer's own when they have
  /// any (the order goes to their door), else this account's.
  List<Address> _addressList(AddressProvider p) =>
      (_customer?.addresses.isNotEmpty ?? false) ? _customer!.addresses : p.addresses;

  Address? _current(AddressProvider p) {
    final list = _addressList(p);
    if (_selected != null && list.any((a) => a.id == _selected!.id)) return _selected;
    if (_customer?.addresses.isNotEmpty ?? false) return _customer!.addresses.first;
    return p.defaultAddress;
  }

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
                decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(l.deliverTo, style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ..._addressList(p).map((a) {
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
                              width: sel ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.recipientName,
                                      style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${a.shortLine} · ${a.phone}',
                                      style: AppFonts.body(fontSize: 11.5, color: AppColors.muted),
                                    ),
                                    Text(
                                      a.street,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.body(fontSize: 11.5, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                sel ? Icons.check_circle : Icons.circle_outlined,
                                color: sel ? AppColors.pomegranate : AppColors.line,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    // A new address would be saved to THIS account, so it isn't
                    // offered while choosing among a customer's own addresses.
                    if (!(_customer?.addresses.isNotEmpty ?? false))
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
                              Text(
                                l.addAddress,
                                style: AppFonts.body(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pomegranate,
                                ),
                              ),
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

  /// Admin only: pick the customer this order is for.
  Future<void> _pickCustomer() async {
    final picked = await showModalBottomSheet<AdminCustomer>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CustomerPicker(api: CustomerApi(context.read<ApiClient>())),
    );
    if (picked != null && mounted) {
      setState(() {
        _customer = picked;
        _selected = null; // their own address, not the previous pick
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_placing) return;
    final l = AppLocalizations.of(context);
    // An admin's order is always FOR a customer — never on the admin's account.
    if (_isAdmin && _customer == null) {
      showHeamaToast(context, l.chooseCustomerFirst);
      _pickCustomer();
      return;
    }
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

    // Wallet only — cash on delivery is no longer offered at checkout.
    const method = 'wallet';
    setState(() => _placing = true);
    try {
      final (_, balances) = await context.read<OrdersProvider>().placeOrder(
        address,
        paymentMethod: method,
        customerId: _customer?.id,
        // Only an admin has any of these, and only the server decides that.
        shipping: _shipping,
      );
      if (!mounted) return;
      context.read<WalletProvider>().setBalances(iqd: balances['IQD'], usd: balances['USD']);
      _orderPlaced();
    } on ApiException catch (e) {
      if (!mounted) return;
      // A server error or a dropped connection doesn't mean the order failed:
      // the server saves the order and empties the cart in one step, then
      // builds its reply — and a crash there came back as a 500 for an order
      // that WAS placed. Tapping again then read "Your cart is empty." So ask
      // the cart: emptied means the order went through.
      final ambiguous = e.statusCode == null || e.statusCode! >= 500;
      if (ambiguous && await _cartWasOrdered()) {
        if (mounted) _orderPlaced();
        return;
      }
      if (mounted) showHeamaToast(context, e.message);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  /// True when the server's cart is now empty — i.e. the order was saved even
  /// though its reply never arrived intact. False if the cart can't be read.
  Future<bool> _cartWasOrdered() async {
    final cart = context.read<CartProvider>();
    await cart.load();
    return cart.error == null && cart.isEmpty;
  }

  /// The order is in: clear the cart, refresh the wallet, show the orders tab.
  void _orderPlaced() {
    final l = AppLocalizations.of(context);
    context.read<CartProvider>().clearLocal();
    // Refresh so the balances and a COD order's "to pay on delivery" total update.
    context.read<WalletProvider>().load();
    context.read<OrdersProvider>().load();
    showHeamaToast(
      context,
      _customer != null ? '${l.orderPlacedFor(_customer!.name)} ✓' : '${l.orderPlaced} ✓',
    );
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (r) => false, arguments: 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cart = context.watch<CartProvider>();
    final wallet = context.watch<WalletProvider>();
    final addresses = context.watch<AddressProvider>();
    final selected = _current(addresses);
    // A mixed cart is checked out as one order per currency; show each total,
    // with whatever the admin has set for carriage already in it.
    final totals = _adjustedTotals(cart);
    final total = totals.isEmpty
        ? '—'
        : totals.map((t) => formatMoney(t.totalIqd, t.currency, iqdLabel: l.iqd)).join('  +  ');
    final walletLine =
        '${formatMoney(wallet.balanceIqd, 'IQD', iqdLabel: l.iqd)} · ${formatMoney(wallet.balanceUsd, 'USD')}';

    final methods = [
      (
        Icons.account_balance_wallet,
        l.heamaWallet,
        // For a customer's order it's THEIR wallet, not this account's balance.
        _customer != null ? l.chargedToWallet(_customer!.name) : l.walletBalanceLine(walletLine),
        true,
      ),
      (Icons.smartphone, l.fastpay, l.fastpaySub, false),
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
              child: Text(l.totalToPay(total), style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
            ),
            if (context.watch<AuthProvider>().user?.isAdmin ?? false) ...[
              _sectionLabel(l.orderForCustomer),
              _customerCard(l),
              if (!cart.isEmpty) ...[
                _sectionLabel(l.shippingPerItem),
                _shippingCard(l, cart),
              ],
            ],
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
                    decoration: BoxDecoration(
                      color: AppColors.pinBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.location_on, size: 18, color: AppColors.midnight),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: selected == null
                        ? Text(
                            l.noAddressesTitle,
                            style: AppFonts.body(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selected.recipientName,
                                style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${selected.shortLine} · ${selected.phone}',
                                style: AppFonts.body(fontSize: 11.5, color: AppColors.muted),
                              ),
                              Text(
                                selected.street,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.body(fontSize: 11.5, color: AppColors.muted),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickAddress,
                    child: Text(
                      selected == null ? l.addAddress : l.change,
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pomegranate,
                      ),
                    ),
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
                      border: Border.all(color: sel ? AppColors.pomegranate : AppColors.line, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.cloud,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, size: 20, color: AppColors.midnight),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    title,
                                    style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w700),
                                  ),
                                  if (!enabled) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.cloud,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Soon',
                                        style: AppFonts.body(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.muted,
                                        ),
                                      ),
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
                  child: Text(
                    _placing ? '…' : l.placeOrder(total),
                    style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The cart's totals with the admin's carriage figures folded in, so the
  /// header and the button say what will actually be charged. The server works
  /// the real totals out again from the same figures when the order is placed;
  /// this only keeps the screen honest while they are being typed.
  List<CartTotals> _adjustedTotals(CartProvider cart) {
    if (_shipping.isEmpty) return cart.totals;

    final delta = <String, num>{};
    for (final item in cart.items) {
      final set = _shipping[item.id];
      if (set == null) continue;
      final currency = item.chargeCurrency.toUpperCase();
      // Per unit, so a line of two moves the total by twice the difference.
      delta[currency] = (delta[currency] ?? 0) + (set - item.shippingUnit) * item.qty;
    }

    return cart.totals.map((t) {
      final d = delta[t.currency.toUpperCase()] ?? 0;
      if (d == 0) return t;
      return CartTotals(
        currency: t.currency,
        itemsTotalIqd: t.itemsTotalIqd,
        shippingIqd: t.shippingIqd + d,
        serviceFeeIqd: t.serviceFeeIqd,
        totalIqd: t.totalIqd + d,
      );
    }).toList();
  }

  /// Admin only: what each line costs to bring, set here rather than in the
  /// cart because the real cost is known when the order is placed and belongs
  /// to that order. Each figure is per unit — a line of two ships twice — and
  /// an empty field leaves the line on the standard rate.
  Widget _shippingCard(AppLocalizations l, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (final item in cart.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        if (item.qty > 1)
                          Text(
                            '× ${item.qty}',
                            style: AppFonts.body(fontSize: 11, color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ShippingInput(
                    // A new figure on the same line replaces the old one.
                    key: ValueKey(item.id),
                    unit: item.shippingUnit,
                    currency: item.chargeCurrency,
                    onChanged: (amount) => setState(() {
                      if (amount == null) {
                        _shipping.remove(item.id);
                      } else {
                        _shipping[item.id] = amount;
                      }
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Admin only: who this order is for — required before placing it.
  Widget _customerCard(AppLocalizations l) {
    final c = _customer;
    return GestureDetector(
      onTap: _pickCustomer,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c == null ? AppColors.pomTintBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c == null ? AppColors.pomegranate : AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.pinBg, borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.person, size: 18, color: AppColors.midnight),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: c == null
                  ? Text(
                      l.chooseCustomer,
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pomegranate,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(
                          [c.phone, c.city].where((s) => s.isNotEmpty).join(' · '),
                          style: AppFonts.body(fontSize: 11.5, color: AppColors.muted),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              c == null ? '' : l.change,
              style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.pomegranate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 6, 18, 9),
    child: Text(
      text.toUpperCase(),
      style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3),
    ),
  );
}

/// Admin only: search customers by name or phone and pick one.
class _CustomerPicker extends StatefulWidget {
  const _CustomerPicker({required this.api});
  final CustomerApi api;

  @override
  State<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<_CustomerPicker> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<AdminCustomer> _results = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  /// Waits for a pause in typing, so each keystroke isn't a request.
  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Future<void> _search() async {
    final q = _query.text;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await widget.api.search(q);
      // Ignore a reply to a query the admin has already typed past.
      if (!mounted || q != _query.text) return;
      setState(() => _results = r);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted && q == _query.text) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(l.chooseCustomer, style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _query,
              autofocus: true,
              onChanged: _onChanged,
              style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                hintText: l.searchCustomers,
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: _loading && _results.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: AppFonts.body(fontSize: 13, color: AppColors.muted),
                      ),
                    )
                  : _results.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l.noCustomersFound,
                        textAlign: TextAlign.center,
                        style: AppFonts.body(fontSize: 13, color: AppColors.muted),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (_, i) {
                        final c = _results[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          leading: const Icon(Icons.person_outline, color: AppColors.midnight),
                          title: Text(
                            c.name,
                            style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [c.phone, c.city].where((s) => s.isNotEmpty).join(' · '),
                            style: AppFonts.body(fontSize: 11.5, color: AppColors.muted),
                          ),
                          onTap: () => Navigator.pop(context, c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One line's carriage, typed by an admin at checkout.
///
/// It starts at the standard rate and reports every change as it is typed, so
/// the total above follows the figure without waiting for the field to be
/// left. Clearing it hands back nothing, which puts the line back on the rate.
class _ShippingInput extends StatefulWidget {
  const _ShippingInput({
    super.key,
    required this.unit,
    required this.currency,
    required this.onChanged,
  });

  /// What one unit ships for as things stand — the standard rate.
  final num unit;
  final String currency;

  /// Null means "leave it on the standard rate".
  final ValueChanged<num?> onChanged;

  @override
  State<_ShippingInput> createState() => _ShippingInputState();
}

class _ShippingInputState extends State<_ShippingInput> {
  late final TextEditingController _field = TextEditingController(text: _shown(widget.unit));

  /// Dinars are whole; dollars and lira keep their cents.
  String _shown(num amount) => widget.currency.toUpperCase() == 'IQD'
      ? amount.round().toString()
      : amount.toStringAsFixed(2);

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _report(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      widget.onChanged(null);
      return;
    }
    final typed = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
    // Half-typed is not an amount yet — leave the total as it was and wait.
    if (typed == null || typed < 0) return;
    widget.onChanged(typed);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = widget.currency.toUpperCase();

    return SizedBox(
      width: 108,
      child: TextField(
        controller: _field,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.end,
        style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          suffixText: currency == 'IQD' ? l.iqd : currency,
          suffixStyle:
              AppFonts.body(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.muted),
        ),
        onChanged: _report,
      ),
    );
  }
}
