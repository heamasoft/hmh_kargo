import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/favorite_item.dart';
import '../../models/order.dart';
import '../../models/stock_item.dart';
import '../../models/store.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/shell_controller.dart';
import '../../providers/stock_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/product_image.dart';
import '../../widgets/store_tile.dart';
import '../orders/orders_screen.dart';
import '../tracking/tracking_screen.dart';
import '../webstore/open_store.dart';

/// A section title with an optional "See all" on the other side.
class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle({super.key, required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: AppFonts.display(fontSize: 20))),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(action!,
                  style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
            ),
          ),
      ],
    );
  }
}

/// The newest order still on its way: a live dot, its progress along its
/// steps, and where it is now. Nothing when every order has arrived.
class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({super.key});

  static Order? activeOf(List<Order> orders) {
    for (final o in orders) {
      if (!o.isDelivered && !o.isCancelled) return o;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final order = activeOf(context.watch<OrdersProvider>().orders);
    if (order == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);

    final flow = order.statusFlow.isNotEmpty ? order.statusFlow : const ['placed', 'delivered'];
    final at = flow.indexOf(order.status);
    final progress = flow.length < 2 ? 0.1 : ((at < 0 ? 0 : at) / (flow.length - 1)).clamp(0.08, 1.0);
    void open() => Navigator.pushNamed(context, Routes.tracking, arguments: TrackingArgs(order.code));

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
      child: Pressable(
        onTap: open,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [BoxShadow(color: Color(0x0F211B3E), blurRadius: 20, offset: Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _LiveDot(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l.orderOnTheWay, style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w800)),
                  ),
                  Text(l.orderDetails,
                      style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
                ],
              ),
              const SizedBox(height: 4),
              Text(l.orderSummary(order.code, order.itemCount),
                  style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.05, end: progress.toDouble()),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    backgroundColor: AppColors.transitTint,
                    color: AppColors.pomegranate,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      orderStatusLabel(l, order.status),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.pomegranate),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    orderStatusLabel(l, flow.last),
                    style: AppFonts.body(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.pomegranate,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.pomegranate.withValues(alpha: 0.45 * (1 - _c.value)),
              spreadRadius: 7 * _c.value,
            ),
          ],
        ),
      ),
    );
  }
}

/// The shopping websites on Home: four to a row, the last tile "More".
class HomeStoresGrid extends StatelessWidget {
  const HomeStoresGrid({super.key, required this.stores, required this.loading});

  final List<Store> stores;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading && stores.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    final l = AppLocalizations.of(context);
    final tiles = <Widget>[
      for (final s in stores.take(7)) StoreTile(store: s, onTap: () => openStore(context, s)),
      Pressable(
        onTap: () => context.read<ShellController>().goToTab(1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: StoreTile.iconSize,
              height: StoreTile.iconSize,
              decoration: StoreTile.iconDecoration(color: AppColors.midnight),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 7),
            Text(l.moreStores, style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ];
    return FourGrid(children: tiles);
  }
}

/// Lays tiles out four to a row with even gaps, each tile as tall as it needs.
class FourGrid extends StatelessWidget {
  const FourGrid({super.key, required this.children, this.rowGap = 16});

  final List<Widget> children;
  final double rowGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const gap = 10.0;
      final w = (c.maxWidth - gap * 3) / 4;
      return Wrap(
        spacing: gap,
        runSpacing: rowGap,
        children: [for (final t in children) SizedBox(width: w, child: t)],
      );
    });
  }
}

enum _StockFilter { all, international, other }

/// "Ready now": what is already in Iraq — filters, a sideways row of small
/// cards (+ to add, a heart to save), and a way to see everything.
class ReadyNowPanel extends StatefulWidget {
  const ReadyNowPanel({super.key, required this.onAdd, required this.busyId});

  final Future<void> Function(StockItem) onAdd;
  final int? busyId;

  @override
  State<ReadyNowPanel> createState() => _ReadyNowPanelState();
}

class _ReadyNowPanelState extends State<ReadyNowPanel> {
  _StockFilter _filter = _StockFilter.all;

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockProvider>();
    if (!stock.hasAny) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final all = [...stock.shein, ...stock.other];
    final shown = switch (_filter) {
      _StockFilter.all => all,
      _StockFilter.international => all.where((i) => i.isShein).toList(),
      _StockFilter.other => all.where((i) => !i.isShein).toList(),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 0, 16),
        decoration: BoxDecoration(color: AppColors.greenTint, borderRadius: BorderRadius.circular(26)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.readyNowTitle, style: AppFonts.display(fontSize: 20)),
                        Text(l.readyNowSub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                                fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1F6E4A))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: Row(
                children: [
                  _chip(l.filterAll, _StockFilter.all),
                  const SizedBox(width: 8),
                  _chip(l.international, _StockFilter.international),
                  const SizedBox(width: 8),
                  _chip(l.stockOther, _StockFilter.other),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 184,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.only(end: 14),
                itemCount: shown.take(12).length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => CompactStockCard(
                  item: shown[i],
                  busy: widget.busyId == shown[i].itemId,
                  onAdd: () => widget.onAdd(shown[i]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: Pressable(
                onTap: () => Navigator.pushNamed(context, Routes.stock),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFE3CF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.seeAllStock(all.length),
                          style: AppFonts.body(
                              fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF1F6E4A))),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF1F6E4A)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, _StockFilter value) {
    final on = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? AppColors.midnight : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? AppColors.midnight : const Color(0xFFBFE3CF)),
        ),
        child: Text(label,
            style: AppFonts.body(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: on ? Colors.white : AppColors.ink)),
      ),
    );
  }
}

/// A small card for one item in stock: photo with a heart, name, price, +.
class CompactStockCard extends StatelessWidget {
  const CompactStockCard({super.key, required this.item, required this.onAdd, this.busy = false});

  final StockItem item;
  final VoidCallback onAdd;
  final bool busy;

  String get _favId => 'stock-${item.itemId}';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final favs = context.watch<FavoritesProvider>();
    final saved = favs.isFavorite(_favId);

    return Container(
      width: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x12211B3E), blurRadius: 12, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 112,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(url: item.imageUrl, gradient: const [AppColors.cloud, AppColors.line]),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: GestureDetector(
                    onTap: () {
                      final now = favs.toggle(FavoriteItem(
                        id: _favId,
                        name: item.title,
                        store: item.store,
                        sourceUrl: item.sourceUrl.isEmpty ? null : item.sourceUrl,
                        priceIqd: item.currency.toUpperCase() == 'IQD' ? item.price.round() : 0,
                        imageUrl: item.imageUrl,
                      ));
                      if (now) showHeamaToast(context, l.savedToFav);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: Icon(
                          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          key: ValueKey(saved),
                          size: 15,
                          color: AppColors.pomegranate,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatMoney(item.price, item.currency, iqdLabel: l.iqd),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.pomegranate),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: l.addToCart,
                      child: GestureDetector(
                        onTap: busy ? null : onAdd,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: busy ? AppColors.muted : AppColors.midnight,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: busy
                              ? const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.add_rounded, size: 17, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
