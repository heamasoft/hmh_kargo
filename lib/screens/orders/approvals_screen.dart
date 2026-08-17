import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/approval.dart';
import '../../models/cart.dart';
import '../../models/order.dart';
import '../../providers/approvals_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/product_image.dart';

/// Pending shipping-fee approvals, grouped by ORDER: the whole order's items are
/// shown for context, and each re-priced item carries its own old→new shipping
/// breakdown with Accept / Reject — an order can have several items under review.
class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  int? _busyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ApprovalsProvider>().load();
      // The orders give us the full item list for context.
      final ordersProvider = context.read<OrdersProvider>();
      if (ordersProvider.orders.isEmpty) ordersProvider.load();
    });
  }

  Future<void> _answer(ShippingApproval a, bool accept) async {
    final l = AppLocalizations.of(context);
    setState(() => _busyId = a.id);
    final approvals = context.read<ApprovalsProvider>();
    final ok = await approvals.respond(a.id, accept: accept);
    if (!mounted) return;
    setState(() => _busyId = null);
    if (ok) {
      // A reject removes the item from the order and refunds the wallet — pull
      // fresh orders + balances so every screen reflects it immediately.
      context.read<OrdersProvider>().load();
      context.read<WalletProvider>().load();
    }
    showHeamaToast(
      context,
      ok
          ? (accept ? l.approvalAcceptedMsg : l.approvalRejectedMsg)
          : (approvals.error ?? 'Could not send your answer.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final approvals = context.watch<ApprovalsProvider>();
    final orders = context.watch<OrdersProvider>().orders;

    // Group the pending requests by order.
    final byOrder = <String, List<ShippingApproval>>{};
    for (final a in approvals.pending) {
      byOrder.putIfAbsent(a.orderCode, () => []).add(a);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              child: Row(
                children: [
                  BackChip(onTap: () => Navigator.pop(context), size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.approvalsTitle, style: AppFonts.display(fontSize: 20)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: approvals.loading && approvals.pending.isEmpty
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : approvals.pending.isEmpty
                      ? Center(
                          child: Text(l.approvalsEmpty,
                              style: AppFonts.body(fontSize: 13.5, color: AppColors.muted)),
                        )
                      : RefreshIndicator(
                          onRefresh: () => context.read<ApprovalsProvider>().load(),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                            children: [
                              for (final entry in byOrder.entries)
                                _orderCard(l, entry.key, entry.value, _orderFor(orders, entry.key)),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Order? _orderFor(List<Order> orders, String code) {
    for (final o in orders) {
      if (o.code == code) return o;
    }
    return null;
  }

  /// One ORDER card: every item of the order for context; the re-priced ones get
  /// the amber breakdown + Accept/Reject inline.
  Widget _orderCard(AppLocalizations l, String code, List<ShippingApproval> reqs, Order? order) {
    final items = order?.items ?? const <OrderItem>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Order #$code',
                    style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w700)),
              ),
              if (order != null)
                Text(formatMoney(order.totalIqd, order.currency, iqdLabel: l.iqd),
                    style: AppFonts.display(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isNotEmpty)
            // The FULL order: normal rows for untouched items, amber blocks with
            // Accept/Reject for the re-priced ones.
            ...items.map((it) {
              ShippingApproval? req;
              for (final a in reqs) {
                if (a.itemId == it.id) {
                  req = a;
                  break;
                }
              }
              return _itemBlock(l,
                  title: it.title,
                  imageUrl: it.imageUrl,
                  qty: it.qty,
                  priceLabel:
                      formatMoney(it.iqdPrice * it.qty, it.chargeCurrency, iqdLabel: l.iqd),
                  req: req);
            })
          else
            // Order not loaded — still fully usable: show the requests themselves.
            ...reqs.map((a) => _itemBlock(l,
                title: a.title,
                imageUrl: a.imageUrl,
                qty: 1,
                priceLabel: formatMoney(a.itemPrice, a.currency, iqdLabel: l.iqd),
                req: a)),
        ],
      ),
    );
  }

  /// One item inside the order. When [req] is set this item is under review:
  /// amber background, old→new shipping, new total, and its own Accept/Reject.
  Widget _itemBlock(
    AppLocalizations l, {
    required String title,
    required String imageUrl,
    required int qty,
    required String priceLabel,
    ShippingApproval? req,
  }) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: SizedBox(
            width: 46,
            height: 54,
            child: ProductImage(url: imageUrl, gradient: CartLine.defaultGradient),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('×$qty', style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(priceLabel,
            style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );

    if (req == null) {
      // Untouched item — context only.
      return Padding(padding: const EdgeInsets.only(bottom: 10), child: row);
    }

    String money(num v) => formatMoney(v, req.currency, iqdLabel: l.iqd);
    final busy = _busyId == req.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.transitTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.transitText.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row,
          const SizedBox(height: 10),
          _line(l.approvalOldShipping,
              req.oldShipping != null ? money(req.oldShipping!) : '—',
              strike: true),
          const SizedBox(height: 5),
          _line(l.approvalNewShipping, money(req.newShipping), highlight: true),
          const Divider(height: 14, color: AppColors.line),
          _line(l.approvalNewTotal, money(req.newTotal), bold: true),
          if (req.note != null && req.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(req.note!, style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _btn(l.approvalReject, Colors.white, AppColors.ink,
                    busy ? null : () => _answer(req, false)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _btn(busy ? '…' : l.approvalAccept, AppColors.green, Colors.white,
                    busy ? null : () => _answer(req, true)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value,
      {bool strike = false, bool highlight = false, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppFonts.body(fontSize: 12, color: AppColors.muted)),
        Text(value,
            style: bold
                ? AppFonts.display(fontSize: 14.5)
                : AppFonts.body(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: highlight ? AppColors.pomegranate : AppColors.ink,
                    decoration: strike ? TextDecoration.lineThrough : null,
                  )),
      ],
    );
  }

  Widget _btn(String label, Color bg, Color fg, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.muted : bg,
          borderRadius: BorderRadius.circular(11),
          border: bg == Colors.white ? Border.all(color: AppColors.line) : null,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }
}
