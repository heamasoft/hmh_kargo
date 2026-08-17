import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/cart.dart';
import '../../models/store.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/stock_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/product_image.dart';
import '../webstore/open_store.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Text(l.yourCart, style: AppFonts.display(fontSize: 21)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Text(l.cartSub, style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
            ),
            if (cart.loading && cart.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (cart.isEmpty)
              _empty(l)
            else ...[
              ...cart.items.map((item) => _CartRow(item: item)),
              _Summary(cart: cart),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.checkout),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.pomegranate,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text('${l.continueToCheckout} →',
                        style: AppFonts.body(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _empty(AppLocalizations l) => Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 44, color: AppColors.muted),
              const SizedBox(height: 12),
              Text(l.yourCart, style: AppFonts.display(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(l.cartSub, style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
            ],
          ),
        ),
      );
}

class _CartRow extends StatelessWidget {
  final CartLine item;
  const _CartRow({required this.item});

  /// Trim long product names to ~24 chars for the compact cart line.
  String _shortTitle(String t) => t.length > 24 ? '${t.substring(0, 24).trimRight()}…' : t;

  /// Removes the line, then refreshes the stock list so any stock item that was
  /// removed becomes available again on the home + stock screens without a
  /// manual reload. (Runs for every removal — a stock reload is cheap/cached —
  /// so it doesn't depend on the backend's is_stock flag being present.)
  Future<void> _removeItem(BuildContext context, CartProvider cart, CartLine item) async {
    await cart.remove(item.id);
    if (context.mounted) {
      context.read<StockProvider>().load(lang: 'en');
    }
  }

  /// Opens the product in its store's WebView (review / re-add).
  void _open(BuildContext context) {
    final url = item.sourceUrl;
    if (url == null || url.trim().isEmpty) return;
    final stores = context.read<CatalogProvider>().stores;
    Store? store;
    for (final s in stores) {
      if (item.storeId != null && s.storeId == item.storeId) {
        store = s;
        break;
      }
    }
    store ??= stores.cast<Store?>().firstWhere(
        (s) => s!.name.toLowerCase() == item.store.toLowerCase(),
        orElse: () => null);
    if (store != null) openProductInStore(context, store, url.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cart = context.read<CartProvider>();
    final variant = [
      if (item.color != null) item.color!,
      if (item.size != null) '${l.size} ${item.size}',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _open(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 62,
                height: 72,
                child: ProductImage(url: item.imageUrl, gradient: CartLine.defaultGradient),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.store.toUpperCase(),
                          style: AppFonts.body(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                              letterSpacing: 0.4)),
                    ),
                    if (item.sourceUrl != null && item.sourceUrl!.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () => _open(context),
                        child: const Icon(Icons.open_in_new,
                            size: 15, color: AppColors.pomegranate),
                      ),
                      const SizedBox(width: 12),
                    ],
                    GestureDetector(
                      onTap: () => _removeItem(context, cart, item),
                      child: const Icon(Icons.close, size: 16, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => _open(context),
                  child: Text(_shortTitle(item.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
                ),
                if (variant.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(variant, style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
                ],
                if (item.note != null && item.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.sticky_note_2_outlined,
                          size: 12, color: AppColors.pomegranate),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.note!.trim(),
                            style: AppFonts.body(
                                fontSize: 11,
                                color: AppColors.pomegranate,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(formatMoney(item.iqdPrice, item.chargeCurrency, iqdLabel: l.iqd),
                    style: AppFonts.display(fontSize: 15)),
                // This line's shipping — $2 per unit × qty (0 for Shein), so the
                // shopper sees exactly what each product adds to the total.
                if (item.shipping > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+ ${l.itemShipping}: ${formatMoney(item.shipping, item.chargeCurrency, iqdLabel: l.iqd)}',
                    style: AppFonts.body(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.transitText),
                  ),
                ],
                const SizedBox(height: 6),
                _QtyStepper(item: item),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final CartLine item;
  const _QtyStepper({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    Widget btn(String label, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(7)),
            alignment: Alignment.center,
            child: Text(label, style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        );
    return Row(
      children: [
        btn('−', () => cart.updateQty(item.id, item.qty - 1)),
        const SizedBox(width: 10),
        Text('${item.qty}', style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        btn('+', () => cart.updateQty(item.id, item.qty + 1)),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final CartProvider cart;
  const _Summary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final totals = cart.totals;
    final multi = totals.length > 1;

    Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppFonts.body(fontSize: 13, color: AppColors.muted))),
              Text(value, style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        );

    String money(num amount, String cur) => formatMoney(amount, cur, iqdLabel: l.iqd);

    Widget block(CartTotals t) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // When the cart mixes currencies, label each block so it's clear
            // these become two separate orders.
            if (multi)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${l.total} · ${t.currency}',
                    style: AppFonts.body(
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
              ),
            line(l.itemsCount(cart.count), money(t.itemsTotalIqd, t.currency)),
            line(l.shippingEst, money(t.shippingIqd, t.currency)),
            line(l.serviceFee, money(t.serviceFeeIqd, t.currency)),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFD6D1E6))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l.total,
                        style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  Text(money(t.totalIqd, t.currency), style: AppFonts.display(fontSize: 20)),
                ],
              ),
            ),
          ],
        );

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          for (var i = 0; i < totals.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Color(0xFFD6D1E6)),
              ),
            block(totals[i]),
          ],
        ],
      ),
    );
  }
}
