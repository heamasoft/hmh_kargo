import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../providers/approvals_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/payment_badge.dart';
import '../../widgets/product_image.dart';

class TrackingScreen extends StatefulWidget {
  final String? orderCode;
  const TrackingScreen({super.key, this.orderCode});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late Future<Order> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<OrdersProvider>().loadOne(widget.orderCode ?? '');
    // Refresh pending shipping approvals so the item highlight is accurate.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ApprovalsProvider>().load();
    });
  }

  // status -> l10n title (the customer-facing pipeline derived from item steps)
  String _title(AppLocalizations l, String status) {
    switch (status) {
      case 'placed':
        return l.stepPlaced;
      case 'buying':
        return l.stepBuying;
      case 'bought':
        return l.stepBought;
      case 'zakho_office':
        return l.stepZakhoOffice;
      case 'delivery':
        return l.stepDelivery;
      case 'delivered':
        return l.delivered;
      // Legacy statuses (older orders / events) still render sensibly.
      case 'purchased':
        return l.stepPurchased;
      case 'warehouse':
        return l.stepWarehouse;
      case 'in_transit':
        return l.stepTransit;
      case 'arrived':
        return l.stepArrived;
      case 'out_for_delivery':
        return l.stepOutForDelivery;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 18, 8),
              child: Row(
                children: [
                  BackChip(onTap: () => Navigator.pop(context), size: 32),
                  const SizedBox(width: 12),
                  Text(l.trackOrder, style: AppFonts.display(fontSize: 17)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Order>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (snap.hasError || !snap.hasData) {
                    return Center(
                      child: Text('Could not load this order.',
                          style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
                    );
                  }
                  return _body(l, snap.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l, Order order) {
    final flow = order.statusFlow.isEmpty
        ? const ['placed', 'purchased', 'warehouse', 'in_transit', 'arrived', 'out_for_delivery', 'delivered']
        : order.statusFlow;
    final currentIndex = flow.indexOf(order.status).clamp(0, flow.length - 1);
    final eventsByStatus = {for (final e in order.events) e.status: e};

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFC9B6E8), Color(0xFFE9C7D6)],
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${order.code}',
                              style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(l.trackFromStores(order.itemCount),
                              style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Text(formatMoney(order.totalIqd, order.currency, iqdLabel: l.iqd),
                        style: AppFonts.display(fontSize: 13, color: AppColors.green)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PaymentBadge(order: order),
              ),
              const Divider(height: 1, color: AppColors.line),
              const SizedBox(height: 4),
              ...List.generate(flow.length, (i) {
                final status = flow[i];
                final state = i < currentIndex
                    ? _StepState.done
                    : (i == currentIndex ? _StepState.current : _StepState.todo);
                final ev = eventsByStatus[status];
                final sub = ev?.note ??
                    (ev?.happenedAt != null
                        ? '${ev!.happenedAt!.day}/${ev.happenedAt!.month}'
                        : '');
                return _StepRow(
                  title: _title(l, status),
                  subtitle: sub,
                  state: state,
                  isLast: i == flow.length - 1,
                  currentLabel: l.currentStep,
                );
              }),
            ],
          ),
        ),
        // Order items so the customer can review what's in this order.
        if (order.items.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.orderItems.toUpperCase(),
                    style: AppFonts.body(
                        fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                const SizedBox(height: 14),
                ...List.generate(order.items.length, (i) {
                  final it = order.items[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == order.items.length - 1 ? 0 : 14),
                    child: _itemRow(l, order, it),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _itemRow(AppLocalizations l, Order order, OrderItem it) {
    final variant = <String>[
      if ((it.color ?? '').isNotEmpty) it.color!,
      if ((it.size ?? '').isNotEmpty) it.size!,
      '×${it.qty}',
    ].join('   ·   ');
    // Amber highlight while THIS item has a pending shipping approval.
    final needsReview =
        context.watch<ApprovalsProvider>().pending.any((a) => a.itemId == it.id);
    // A single item can be cancelled only while THAT item is still pending (the
    // admin hasn't started buying it), and never the last one (cancel the whole
    // order for that). Each item advances independently, so this is per-item.
    final canCancelItem =
        it.canCancel && !order.isCancelled && order.items.length > 1;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: SizedBox(
            width: 50,
            height: 58,
            child: ProductImage(url: it.imageUrl, gradient: OrderItem.defaultGradient),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(it.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
              const SizedBox(height: 4),
              Text(variant, style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
              // This item's own stage (the admin advances items independently).
              if (!order.isCancelled) ...[
                const SizedBox(height: 4),
                _StatusPill(label: _title(l, it.status)),
              ],
              // Each item's own shipping fee (the admin can re-price it per item).
              if (it.shipping != null) ...[
                const SizedBox(height: 3),
                Text(
                  '${l.itemShipping}: ${formatMoney(it.shipping!, it.chargeCurrency, iqdLabel: l.iqd)}',
                  style: AppFonts.body(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.transitText),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(formatMoney(it.iqdPrice * it.qty, it.chargeCurrency, iqdLabel: l.iqd),
            style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700)),
      ],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        if (canCancelItem)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: () => _confirmCancelItem(order, it),
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l.cancelItemAction,
                    style: AppFonts.body(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pomegranate)),
              ),
            ),
          ),
      ],
    );

    if (!needsReview) return content;
    // Amber "needs your approval" highlight — tapping opens the approvals screen.
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.approvals),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.transitTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.transitText.withValues(alpha: 0.5)),
        ),
        child: content,
      ),
    );
  }

  /// Confirm + cancel ONE item: its price + shipping are refunded to the wallet
  /// and the order reloads with the recomputed totals.
  Future<void> _confirmCancelItem(Order order, OrderItem it) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.cancelItemAction, style: AppFonts.display(fontSize: 17)),
        content: Text(l.cancelItemConfirm,
            style: AppFonts.body(fontSize: 13.5, color: AppColors.muted, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel,
                style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.cancelItemAction,
                style: AppFonts.body(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final (updated, balances) =
          await context.read<OrdersProvider>().cancelItem(order.code, it.id);
      if (!mounted) return;
      context.read<WalletProvider>().setBalances(iqd: balances['IQD'], usd: balances['USD']);
      // Refresh this screen with the recomputed order, and the orders list +
      // wallet + approvals so everything reflects the removal immediately.
      setState(() => _future = Future.value(updated));
      context.read<OrdersProvider>().load();
      context.read<WalletProvider>().load();
      context.read<ApprovalsProvider>().refreshSilently();
      showHeamaToast(context, l.itemCancelledMsg);
    } on ApiException catch (e) {
      if (mounted) showHeamaToast(context, e.message);
    }
  }
}

/// Small rounded chip showing an item's current stage.
class _StatusPill extends StatelessWidget {
  final String label;
  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.transitTint,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(label,
          style: AppFonts.body(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.transitText)),
    );
  }
}

enum _StepState { done, current, todo }

class _StepRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final _StepState state;
  final bool isLast;
  final String currentLabel;

  const _StepRow({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.isLast,
    required this.currentLabel,
  });

  @override
  Widget build(BuildContext context) {
    final done = state == _StepState.done;
    final current = state == _StepState.current;
    final nodeColor = done ? AppColors.green : Colors.white;
    final borderColor = done
        ? AppColors.green
        : current
            ? AppColors.saffron
            : AppColors.line;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: current ? [const BoxShadow(color: Color(0xFFFDECCF), spreadRadius: 4)] : null,
                ),
                child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: done ? AppColors.green : AppColors.line),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1, bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: state == _StepState.todo ? FontWeight.w600 : FontWeight.w700,
                          color: state == _StepState.todo ? AppColors.muted : AppColors.ink)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
                  ],
                  if (current) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFFDECCF), borderRadius: BorderRadius.circular(6)),
                      child: Text(currentLabel,
                          style: AppFonts.body(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.hintText)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
