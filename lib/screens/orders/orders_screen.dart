import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../providers/approvals_provider.dart';
import '../../providers/orders_provider.dart';
import '../../router.dart';
import '../tracking/tracking_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/product_image.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  // Active filters (null = all). Applied to both tabs.
  String? _status;
  String? _currency;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().load();
      // Poll for shipping-fee approvals the admin is waiting on.
      context.read<ApprovalsProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    // One entry per ordered ITEM, not per order: every item moves through its
    // own steps (the admin buys and ships them one by one), so each is shown
    // and filed on its own. Newest order first, its items in order.
    final all = [
      for (final o in provider.orders)
        for (final it in o.items) _Entry(o, it),
    ];
    final filtered = all.where(_passes).toList();
    // Active = still on its way. Archive = closed: delivered (received) or cancelled.
    final active = filtered.where((e) => !e.isClosed).toList();
    final archive = filtered.where((e) => e.isClosed).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                child: Text(l.yourOrders, style: AppFonts.display(fontSize: 21)),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Text(l.ordersSub, style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
              ),
            ),
            // The admin re-priced shipping on item(s) — the customer must answer
            // before we can buy them, so surface it loudly at the top.
            if (context.watch<ApprovalsProvider>().hasPending)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, Routes.approvals),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.transitTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          size: 20, color: AppColors.transitText),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.approvalsBanner(context.watch<ApprovalsProvider>().count),
                          style: AppFonts.body(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.transitText),
                        ),
                      ),
                      Text(l.approvalsBannerAction,
                          style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pomegranate)),
                    ],
                  ),
                ),
              ),
            if (all.isNotEmpty) _filterBar(l, all),
            TabBar(
              controller: _tabs,
              labelColor: AppColors.ink,
              unselectedLabelColor: AppColors.muted,
              indicatorColor: AppColors.pomegranate,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2.5,
              dividerColor: AppColors.line,
              labelStyle: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w700),
              unselectedLabelStyle: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: _tabLabel(l.ordersActive, active.length)),
                Tab(text: _tabLabel(l.ordersArchive, archive.length)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _list(provider, active, l.ordersActive, l.ordersActiveEmpty),
                  _list(provider, archive, l.ordersArchive, l.ordersArchiveEmpty),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tabLabel(String name, int count) => count > 0 ? '$name ($count)' : name;

  bool _passes(_Entry e) {
    if (_status != null && e.status != _status) return false;
    if (_currency != null && e.item.chargeCurrency.toUpperCase() != _currency) return false;
    return true;
  }

  // status → localized label (reuses the tracking-step strings).
  String _statusLabel(AppLocalizations l, String status) => statusLabel(l, status);

  static String statusLabel(AppLocalizations l, String status) {
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
      case 'delivered':
        return l.delivered;
      case 'cancelled':
        return l.statusCancelled;
      default:
        return status;
    }
  }

  // A horizontally-scrolling row of filter dropdowns (status / currency).
  Widget _filterBar(AppLocalizations l, List<_Entry> all) {
    const pipeline = [
      'placed', 'buying', 'bought', 'zakho_office', 'delivery', 'delivered', 'cancelled'
    ];
    final statuses = all.map((e) => e.status).toSet().toList()
      ..sort((a, b) => pipeline.indexOf(a).compareTo(pipeline.indexOf(b)));
    final currencies =
        all.map((e) => e.item.chargeCurrency.toUpperCase()).toSet().toList()..sort();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
        children: [
          _pill(
            label: _status == null ? l.filterStatus : _statusLabel(l, _status!),
            selected: _status != null,
            items: _menu(l.filterAll, [
              for (final s in statuses) (value: s, label: _statusLabel(l, s)),
            ]),
            // '' is the "All" sentinel → clears the filter.
            onSelected: (v) => setState(() => _status = v.isEmpty ? null : v),
          ),
          if (currencies.length > 1) ...[
            const SizedBox(width: 8),
            _pill(
              label: _currency ?? l.filterCurrency,
              selected: _currency != null,
              items: _menu(l.filterAll, [
                for (final c in currencies) (value: c, label: c),
              ]),
              onSelected: (v) => setState(() => _currency = v.isEmpty ? null : v),
            ),
          ],
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _menu(
      String allLabel, List<({String value, String label})> opts) {
    return [
      // Non-null value: PopupMenuButton ignores a null result (treats it as a
      // cancel), so the "All" entry must carry a real value ('').
      PopupMenuItem<String>(
          value: '',
          child: Text(allLabel, style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w600))),
      for (final o in opts)
        PopupMenuItem<String>(
            value: o.value,
            child: Text(o.label, style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w600))),
    ];
  }

  Widget _pill({
    required String label,
    required bool selected,
    required List<PopupMenuEntry<String>> items,
    required ValueChanged<String> onSelected,
  }) {
    return PopupMenuButton<String>(
      tooltip: '',
      position: PopupMenuPosition.under,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
      itemBuilder: (_) => items,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.pomTintBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.pomegranate : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.pomegranate : AppColors.ink)),
            const SizedBox(width: 4),
            Icon(Icons.expand_more,
                size: 16, color: selected ? AppColors.pomegranate : AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _list(OrdersProvider provider, List<_Entry> orders, String title, String emptyMsg) {
    return RefreshIndicator(
      onRefresh: () => context.read<OrdersProvider>().load(),
      child: (provider.loading && provider.orders.isEmpty)
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 70),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ],
            )
          : orders.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 44, color: AppColors.muted),
                            const SizedBox(height: 12),
                            Text(title,
                                style: AppFonts.display(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(emptyMsg,
                                  textAlign: TextAlign.center,
                                  style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  children: orders.map((e) => _ItemCard(entry: e)).toList(),
                ),
    );
  }
}

/// One ordered item, with the order it belongs to (for its code, date and
/// whether the whole order was cancelled).
class _Entry {
  const _Entry(this.order, this.item);
  final Order order;
  final OrderItem item;

  /// The item's own step; a cancelled order cancels all of its items.
  String get status => order.isCancelled ? 'cancelled' : item.status;
  bool get isCancelled => status == 'cancelled';
  bool get isDelivered => status == 'delivered';
  bool get isClosed => isCancelled || isDelivered;
}

class _ItemCard extends StatelessWidget {
  final _Entry entry;
  const _ItemCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final order = entry.order;
    final it = entry.item;
    final date = order.placedAt != null
        ? '${_month(order.placedAt!.month)} ${order.placedAt!.day}'
        : '';
    final (chipBg, chipFg) = entry.isCancelled
        ? (AppColors.cloud, AppColors.muted)
        : entry.isDelivered
            ? (AppColors.greenTint, AppColors.green)
            : (AppColors.transitTint, AppColors.transitText);
    final chipLabel = _OrdersScreenState.statusLabel(l, entry.status);
    final variant = [
      if ((it.color ?? '').isNotEmpty) it.color!,
      if ((it.size ?? '').isNotEmpty) it.size!,
      '×${it.qty}',
    ].join('  ·  ');
    // THIS item has a shipping re-price waiting for the customer's answer.
    final needsApproval =
        context.watch<ApprovalsProvider>().pending.any((a) => a.itemId == it.id);

    return GestureDetector(
      // A cancelled item has nothing left to track — the card is its record.
      onTap: entry.isCancelled
          ? null
          : () => needsApproval
              ? Navigator.pushNamed(context, Routes.approvals)
              // Track THIS item alone — its own step, not the whole order's.
              : Navigator.pushNamed(context, Routes.tracking,
                  arguments: TrackingArgs(order.code, itemId: it.id)),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: needsApproval ? AppColors.transitTint : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: needsApproval ? AppColors.transitText : AppColors.line,
              width: needsApproval ? 1.4 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 54,
                height: 62,
                child: ProductImage(url: it.imageUrl, gradient: OrderItem.defaultGradient),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(it.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                                fontSize: 13, fontWeight: FontWeight.w700, height: 1.3)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(chipLabel,
                            style: AppFonts.body(
                                fontSize: 10.5, fontWeight: FontWeight.w700, color: chipFg)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(variant, style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                  if (needsApproval)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined,
                              size: 14, color: AppColors.transitText),
                          const SizedBox(width: 6),
                          Text(l.approvalsBannerAction,
                              style: AppFonts.body(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.transitText)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: Text('#${order.code}${date.isEmpty ? '' : ' · $date'}',
                            style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                      ),
                      Text(formatMoney(it.iqdPrice * it.qty, it.chargeCurrency, iqdLabel: l.iqd),
                          style: AppFonts.display(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}
