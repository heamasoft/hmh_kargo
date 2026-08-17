import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/stock_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/shell_controller.dart';
import '../../providers/stock_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/stock_card.dart';

enum _Sort { newest, priceAsc, priceDesc }

/// Full in-stock storefront: search, store filters, and sorting over the
/// products the company already holds (ready to buy now, no shipping wait).
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  int? _busyId;
  String _query = '';
  String _storeFilter = 'all'; // 'all' | 'shein' | '<store name>'
  _Sort _sort = _Sort.newest;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final stock = context.read<StockProvider>();
      if (stock.loadedLang != 'en' || !stock.hasAny) stock.load(lang: 'en');
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _add(StockItem item) async {
    final l = AppLocalizations.of(context);
    setState(() => _busyId = item.itemId);
    final err = await context.read<StockProvider>().addToCart(item);
    if (!mounted) return;
    setState(() => _busyId = null);
    if (err == null) {
      context.read<CartProvider>().load();
      showHeamaToast(context, l.stockAdded);
    } else {
      showHeamaToast(context, err);
    }
  }

  /// Distinct non-Shein store names present in stock (for the filter chips).
  List<String> _stores(StockProvider s) {
    final set = <String>{};
    for (final i in s.other) {
      final name = i.store.trim();
      if (name.isNotEmpty) set.add(_pretty(name));
    }
    final list = set.toList()..sort();
    return list;
  }

  String _pretty(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  List<StockItem> _filtered(StockProvider s) {
    var items = [...s.shein, ...s.other];

    if (_storeFilter == 'shein') {
      items = items.where((i) => i.isShein).toList();
    } else if (_storeFilter != 'all') {
      items = items
          .where((i) => i.store.toLowerCase() == _storeFilter.toLowerCase())
          .toList();
    }

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((i) {
        return i.title.toLowerCase().contains(q) ||
            (i.color ?? '').toLowerCase().contains(q) ||
            (i.size ?? '').toLowerCase().contains(q) ||
            (i.sku ?? '').toLowerCase().contains(q);
      }).toList();
    }

    switch (_sort) {
      case _Sort.priceAsc:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _Sort.priceDesc:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _Sort.newest:
        break; // server already returns newest first
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final stock = context.watch<StockProvider>();
    final results = _filtered(stock);

    return Scaffold(
      backgroundColor: Colors.white,
      // Same footer as the rest of the app — tapping a tab returns to the shell.
      bottomNavigationBar: AppBottomNav(
        current: -1, // this is a sub-page, so no tab is "active"
        onTap: (i) {
          context.read<ShellController>().goToTab(i);
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 18, 10),
              child: Row(
                children: [
                  BackChip(onTap: () => Navigator.pop(context), size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.readyNowTitle, style: AppFonts.display(fontSize: 19)),
                        Text(l.readyNowSub,
                            style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cloud,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 19, color: AppColors.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: l.stockSearchHint,
                          hintStyle: AppFonts.body(fontSize: 13, color: AppColors.muted),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: const Icon(Icons.close, size: 17, color: AppColors.muted),
                      ),
                  ],
                ),
              ),
            ),
            // Filters + sort
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      children: [
                        _filterChip(l.filterAll, 'all'),
                        if (stock.shein.isNotEmpty) _filterChip('Shein', 'shein'),
                        for (final s in _stores(stock)) _filterChip(s, s),
                      ],
                    ),
                  ),
                  _sortButton(l),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            // Count
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Text(l.stockCount(results.length),
                  style: AppFonts.body(
                      fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
            ),
            // Results
            Expanded(
              child: stock.loading && !stock.hasAny
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : results.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              stock.hasAny ? l.stockNoResults : l.readyEmpty,
                              textAlign: TextAlign.center,
                              style: AppFonts.body(fontSize: 13.5, color: AppColors.muted),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => context.read<StockProvider>().load(lang: 'en'),
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.60,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, i) => StockCard(
                              item: results[i],
                              busy: _busyId == results[i].itemId,
                              onAdd: () => _add(results[i]),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _storeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _storeFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.ink : AppColors.cloud,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.ink)),
        ),
      ),
    );
  }

  Widget _sortButton(AppLocalizations l) {
    String label(_Sort s) => switch (s) {
          _Sort.newest => l.sortNewest,
          _Sort.priceAsc => l.sortPriceLow,
          _Sort.priceDesc => l.sortPriceHigh,
        };
    return PopupMenuButton<_Sort>(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (s) => setState(() => _sort = s),
      itemBuilder: (_) => [
        for (final s in _Sort.values)
          PopupMenuItem(
            value: s,
            child: Row(
              children: [
                Expanded(
                  child: Text(label(s),
                      style: AppFonts.body(
                          fontSize: 13.5,
                          fontWeight: _sort == s ? FontWeight.w700 : FontWeight.w600)),
                ),
                if (_sort == s)
                  const Icon(Icons.check, size: 17, color: AppColors.pomegranate),
              ],
            ),
          ),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert, size: 16, color: AppColors.ink),
            const SizedBox(width: 4),
            Text(l.sortLabel,
                style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
