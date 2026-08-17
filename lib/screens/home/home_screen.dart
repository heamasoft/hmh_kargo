import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../models/stock_item.dart';
import '../../models/store.dart';
import '../../providers/approvals_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_pill.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stock_card.dart';
import '../../widgets/store_tile.dart';
import '../../providers/shell_controller.dart';
import '../webstore/open_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _busyStockId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = context.read<CatalogProvider>();
      catalog.loadStores();
      catalog.loadTrending();
      catalog.loadAllProducts(); // fallback for the per-store rows
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<WalletProvider>().load();
        context.read<FavoritesProvider>().syncFromServer();
        // Poll for shipping-fee approvals waiting on the customer (app open).
        context.read<ApprovalsProvider>().load();
        // Products already in the company, ready to buy now (titles in English).
        context.read<StockProvider>().load(lang: 'en');
      }
    });
  }

  /// Finds the store a trending product belongs to (by id, then by name).
  Store? _storeFor(Product p, List<Store> stores) {
    for (final s in stores) {
      if (p.storeId != null && s.storeId == p.storeId) return s;
    }
    for (final s in stores) {
      if (s.name.toLowerCase() == p.store.toLowerCase()) return s;
    }
    return null;
  }

  /// Tapping a trending item opens that exact product inside its store's WebView
  /// (Shein → Shein, Trendyol → Trendyol), ready to add to Heama.
  void _openTrending(Product p) {
    final catalog = context.read<CatalogProvider>();
    final store = _storeFor(p, catalog.stores);
    final url = p.sourceUrl;
    if (store != null && url != null && url.trim().isNotEmpty) {
      openProductInStore(context, store, url.trim());
    } else if (store != null) {
      openStore(context, store);
    } else {
      Navigator.pushNamed(context, Routes.product, arguments: p);
    }
  }

  static String _langShort(String code) =>
      code == 'ar' ? 'AR' : (code == 'ku' ? 'KU' : 'EN');

  PopupMenuItem<String> _langMenuItem(String code, String name, String current) {
    final sel = code == current;
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w600)),
          ),
          if (sel) const Icon(Icons.check, size: 18, color: AppColors.pomegranate),
        ],
      ),
    );
  }

  /// Paste a product link from the home search and fetch it (opens the item in
  /// its store's WebView, which captures it — the same flow as the store bar).
  Future<void> _pasteLink() async {
    final l = AppLocalizations.of(context);
    final field = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.productLink, style: AppFonts.display(fontSize: 17)),
        content: TextField(
          controller: field,
          autofocus: true,
          keyboardType: TextInputType.url,
          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(hintText: 'https://…', isDense: true),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel,
                style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, field.text.trim()),
            child: Text(l.fetchDetails,
                style: AppFonts.body(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
          ),
        ],
      ),
    );
    if (!mounted || url == null || url.isEmpty) return;
    var u = url;
    if (!u.startsWith('http')) u = 'https://$u';
    final uri = Uri.tryParse(u);
    if (uri == null || !uri.hasAuthority) return;

    final stores = context.read<CatalogProvider>().stores;
    final host = uri.host.replaceFirst('www.', '');
    Store? store;
    for (final s in stores) {
      final sHost =
          (Uri.tryParse(s.url)?.host ?? '').replaceFirst('www.', '').replaceFirst('m.', '');
      final key = sHost.isEmpty ? '' : sHost.split('.').first;
      if (key.isNotEmpty && host.contains(key)) {
        store = s;
        break;
      }
    }
    store ??= stores.isNotEmpty ? stores.first : null;
    if (store != null) openProductInStore(context, store, u);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = context.watch<CatalogProvider>();
    // Show 8 stores + the "More" tile = 9 cards (a clean 3×3 grid).
    final homeStores = catalog.stores.take(8).toList();
    final langCode = context.watch<LocaleProvider>().locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
              child: Row(
                children: [
                  Image.asset('assets/logo/hmh_kargo_emblem.png', width: 34, height: 34),
                  const SizedBox(width: 9),
                  Text(l.appName, style: AppFonts.display(fontSize: 20)),
                  const Spacer(),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 42),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onSelected: (code) =>
                        context.read<LocaleProvider>().setLocale(Locale(code)),
                    itemBuilder: (_) => [
                      _langMenuItem('en', 'English', langCode),
                      _langMenuItem('ar', 'العربية', langCode),
                      _langMenuItem('ku', 'کوردی', langCode),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.cloud,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.language, size: 15, color: AppColors.ink),
                          const SizedBox(width: 5),
                          Text(_langShort(langCode),
                              style: AppFonts.body(fontSize: 11.5, fontWeight: FontWeight.w700)),
                          const Icon(Icons.expand_more, size: 16, color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 16),
              child: const _WalletChip(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SearchPill(
                hint: l.searchProductsHint,
                onTap: _pasteLink,
              ),
            ),
            SectionHeader(
              title: l.shopFavStores,
              action: l.seeAll,
              onAction: () => context.read<ShellController>().goToTab(1),
            ),
            _StoresGrid(stores: homeStores, loading: catalog.loadingStores),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _PromoBanner(
                onShop: () {
                  if (catalog.stores.isEmpty) {
                    context.read<ShellController>().goToTab(1);
                    return;
                  }
                  final shein = catalog.stores.firstWhere(
                    (s) => s.id == 'shein',
                    orElse: () => catalog.stores.first,
                  );
                  openStore(context, shein);
                },
              ),
            ),
            ..._buildReadyNow(l),
            ..._buildTrending(l, catalog),
          ],
        ),
      ),
    );
  }

  /// "Ready now" — a preview of in-stock products (already in the company),
  /// with a See-all link to the full stock screen. Hidden when nothing's in stock.
  List<Widget> _buildReadyNow(AppLocalizations l) {
    final stock = context.watch<StockProvider>();
    if (!stock.hasAny) return const [];
    // Shein first, then others; show up to 10 in the preview row.
    final preview = [...stock.shein, ...stock.other].take(10).toList();

    return [
      const SizedBox(height: 22),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 0, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF7EF), Color(0xFFF4FBF7)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.readyNowTitle, style: AppFonts.display(fontSize: 16)),
                          Text(l.readyNowSub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, Routes.stock),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l.seeAll,
                                style: AppFonts.body(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(width: 3),
                            const Icon(Icons.arrow_forward, size: 13, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 244,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 14),
                  itemCount: preview.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => SizedBox(
                    width: 150,
                    child: StockCard(
                      item: preview[i],
                      busy: _busyStockId == preview[i].itemId,
                      onAdd: () => _addStock(preview[i]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> _addStock(StockItem item) async {
    final l = AppLocalizations.of(context);
    setState(() => _busyStockId = item.itemId);
    final err = await context.read<StockProvider>().addToCart(item);
    if (!mounted) return;
    setState(() => _busyStockId = null);
    if (err == null) {
      context.read<CartProvider>().load();
      showHeamaToast(context, l.stockAdded);
    } else {
      showHeamaToast(context, err);
    }
  }

  /// Trending shown per store (Trending on Shein, Trending on Trendyol…), so each
  /// row's items open in that store. Falls back to one generic row if no store
  /// matches the products.
  List<Widget> _buildTrending(AppLocalizations l, CatalogProvider catalog) {
    // Prefer curated trending; fall back to the full catalog so each store still
    // shows items even before anything is flagged as trending.
    final source =
        catalog.trending.isNotEmpty ? catalog.trending : catalog.allProducts;

    if (source.isEmpty) {
      if (catalog.loadingTrending || catalog.stores.isEmpty) {
        return const [
          SizedBox(height: 250, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        ];
      }
      return const [];
    }

    // Only show trending for Shein and Trendyol — skip every other store.
    const trendingStores = {'shein', 'trendyol'};

    // Group by store, in the order stores are listed, up to 10 items each.
    final sections = <MapEntry<Store, List<Product>>>[];
    for (final s in catalog.stores) {
      if (!trendingStores.contains(s.id.toLowerCase())) continue;
      final items = source
          .where((p) =>
              (p.storeId != null && p.storeId == s.storeId) ||
              p.store.toLowerCase() == s.name.toLowerCase())
          .take(10)
          .toList();
      if (items.isNotEmpty) sections.add(MapEntry(s, items));
    }

    // Nothing trending for Shein/Trendyol yet — show no trending section.
    if (sections.isEmpty) return const [];

    final widgets = <Widget>[];
    for (final entry in sections) {
      widgets.add(const SizedBox(height: 22));
      widgets.add(SectionHeader(
        title: l.trendingOn(entry.key.name),
        action: l.seeAll,
        onAction: () => openStore(context, entry.key),
      ));
      widgets.add(_trendingRow(entry.value));
    }
    return widgets;
  }

  Widget _trendingRow(List<Product> items) {
    return SizedBox(
      height: 208,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => ProductCard(
          product: items[i],
          width: 116,
          imageHeight: 128,
          showFav: false,
          showPrice: false,
          onTap: () => _openTrending(items[i]),
        ),
      ),
    );
  }
}

class _WalletChip extends StatelessWidget {
  const _WalletChip();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = context.watch<WalletProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.midnight, AppColors.midnight700]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.heamaWallet,
              style: AppFonts.body(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.onDarkMuted)),
          const SizedBox(height: 12),
          // Both balances inside the same card; tap one to open its ledger.
          Row(
            children: [
              Expanded(
                child: _bal('IQD', formatIqd(w.balanceIqd),
                    onTap: () => Navigator.pushNamed(context, Routes.walletLedger,
                        arguments: 'IQD')),
              ),
              Container(
                width: 1,
                height: 36,
                color: const Color(0x1FFFFFFF),
                margin: const EdgeInsets.symmetric(horizontal: 14),
              ),
              Expanded(
                child: _bal('USD', formatMoney(w.balanceUsd, 'USD'),
                    onTap: () => Navigator.pushNamed(context, Routes.walletLedger,
                        arguments: 'USD')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bal(String code, String amount, {VoidCallback? onTap}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(code,
                    style: AppFonts.body(
                        fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.onDarkMuted)),
                if (onTap != null) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.chevron_right, size: 14, color: AppColors.onDarkMuted),
                ],
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(amount, style: AppFonts.display(fontSize: 23, color: Colors.white)),
            ),
          ],
        ),
      );
}

class _StoresGrid extends StatelessWidget {
  final List stores;
  final bool loading;
  const _StoresGrid({required this.stores, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading && stores.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    // Wrap (not a fixed-aspect grid) so each card sizes to its own content —
    // it can never overflow, whatever the device width or text scale.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: LayoutBuilder(
        builder: (context, c) {
          const gap = 11.0;
          final w = (c.maxWidth - gap * 2) / 3;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              ...stores.map((s) => SizedBox(
                    width: w,
                    child: StoreTile(store: s, onTap: () => openStore(context, s)),
                  )),
              SizedBox(width: w, child: const _MoreStoresTile()),
            ],
          );
        },
      ),
    );
  }
}

/// The "+ More" card that matches [StoreTile]'s shape.
class _MoreStoresTile extends StatelessWidget {
  const _MoreStoresTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => context.read<ShellController>().goToTab(1),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.midnight,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(l.moreStores,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(l.twentyPlusStores,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(fontSize: 10, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final VoidCallback onShop;
  const _PromoBanner({required this.onShop});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.pomegranate, Color(0xFFE1683B)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.freeShippingTitle,
              style: AppFonts.display(fontSize: 19, color: Colors.white, height: 1.15)),
          const SizedBox(height: 6),
          Text(l.freeShippingSub, style: AppFonts.body(fontSize: 12.5, color: const Color(0xFFFFE9DF))),
          const SizedBox(height: 13),
          GestureDetector(
            onTap: onShop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
              child: Text('${l.shopNow} →',
                  style: AppFonts.body(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.pomegranateDark)),
            ),
          ),
        ],
      ),
    );
  }
}
