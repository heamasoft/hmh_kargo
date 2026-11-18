import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/stock_item.dart';
import '../../providers/approvals_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/shell_controller.dart';
import '../../providers/stock_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/ads_carousel.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/motion.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/paste_link_box.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/safari_button_card.dart';
import '../../widgets/store_tile.dart';
import 'home_sections.dart';

/// Home, top to bottom: the header (greeting, wallet, the link box), the ads,
/// four shortcuts, the order on its way, the shopping websites, and what is
/// already in Iraq. Each section rises in a moment after the one above it.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _busyStockId;

  late final ShellController _shell;

  @override
  void initState() {
    super.initState();
    // Home is kept alive in the shell's IndexedStack, so coming back to it
    // rebuilds nothing on its own. Check for waiting answers on every return,
    // so the bell is right when the customer is looking at it.
    _shell = context.read<ShellController>()..addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadStores();
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<WalletProvider>().load();
        context.read<FavoritesProvider>().syncFromServer();
        context.read<OrdersProvider>().load();
        // Poll for shipping-fee approvals waiting on the customer (app open).
        context.read<ApprovalsProvider>().load();
        // Products already in the company, ready to buy now (titles in English).
        context.read<StockProvider>().load(lang: 'en');
      }
    });
  }

  void _onTabChanged() {
    if (!mounted || _shell.tab != ShellController.home) return;
    if (context.read<AuthProvider>().isAuthenticated) {
      context.read<ApprovalsProvider>().refreshSilently();
    }
  }

  @override
  void dispose() {
    _shell.removeListener(_onTabChanged);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = context.watch<CatalogProvider>();
    var step = Duration.zero;
    Widget rise(Widget child) {
      final w = RiseIn(delay: step, child: child);
      step += RiseIn.step;
      return w;
    }

    return Scaffold(
      backgroundColor: AppColors.cloud,
      // Light status-bar icons over the navy header.
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: RefreshIndicator(
          color: AppColors.pomegranate,
          onRefresh: () async {
            final auth = context.read<AuthProvider>().isAuthenticated;
            await Future.wait([
              context.read<CatalogProvider>().loadStores(),
              if (auth) context.read<WalletProvider>().load(),
              if (auth) context.read<OrdersProvider>().load(),
              if (auth) context.read<StockProvider>().load(lang: 'en'),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const _HomeHeader(),
              const SizedBox(height: 16),
              // Ads the admins publish (Me → Home ads); nothing shows without any.
              rise(const AdsCarousel()),
              rise(const QuickActions()),
              const SafariButtonCard(),
              rise(const ActiveOrderCard()),
              const SizedBox(height: 26),
              rise(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    HomeSectionTitle(
                      title: l.websitesTitle,
                      action: l.seeAll,
                      onAction: () => context.read<ShellController>().goToTab(1),
                    ),
                    const SizedBox(height: 14),
                    HomeStoresGrid(stores: catalog.stores, loading: catalog.loadingStores),
                  ],
                ),
              )),
              rise(ReadyNowPanel(onAdd: _addStock, busyId: _busyStockId)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The navy header: who is shopping, their wallet, and the link box.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  static String _langShort(String code) => code == 'ar' ? 'AR' : (code == 'ku' ? 'KU' : 'EN');

  PopupMenuItem<String> _langItem(String code, String name, String current) {
    final sel = code == current;
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: AppFonts.body(fontSize: 14, fontWeight: sel ? FontWeight.w700 : FontWeight.w600)),
          ),
          if (sel) const Icon(Icons.check, size: 18, color: AppColors.pomegranate),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final langCode = context.watch<LocaleProvider>().locale.languageCode;
    final name = auth.isAuthenticated ? (auth.user?.name ?? '').trim() : '';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Two soft circles for depth.
          const PositionedDirectional(end: -70, top: -60, child: _Blob(size: 220, color: AppColors.midnight700)),
          const PositionedDirectional(start: -40, bottom: -90, child: _Blob(size: 180, color: AppColors.welcomeTop)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RiseIn(
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.pomegranate,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Image.asset('assets/logo/hmh_kargo_emblem_white.png'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.homeHello,
                                  style: AppFonts.body(
                                      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onDarkMuted)),
                              Text(
                                name.isNotEmpty ? name : l.appName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.display(fontSize: 19, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(0, 42),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onSelected: (code) => context.read<LocaleProvider>().setLocale(Locale(code)),
                          itemBuilder: (_) => [
                            _langItem('en', 'English', langCode),
                            _langItem('ar', 'العربية', langCode),
                            _langItem('ku', 'کوردی', langCode),
                          ],
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 11),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.language, size: 15, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(_langShort(langCode),
                                    style: AppFonts.body(
                                        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // What the admin is waiting on an answer for — a
                        // changed shipping price — found from the first screen.
                        const NotificationBell(),
                      ],
                    ),
                  ),
                  if (auth.isAuthenticated) ...[
                    const SizedBox(height: 18),
                    const RiseIn(delay: RiseIn.step, child: _WalletStrip()),
                  ],
                  const SizedBox(height: 14),
                  const RiseIn(delay: Duration(milliseconds: 140), child: PasteLinkBox()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      );
}

/// The wallet balance, with Top up beside it.
class _WalletStrip extends StatelessWidget {
  const _WalletStrip();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final balance = context.watch<WalletProvider>().balanceIqd;
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.walletLedger),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.saffron.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.saffron),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.walletBalance,
                      style: AppFonts.body(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onDarkMuted)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: balance.toDouble()),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Text(
                      '${formatIqd(v)} ${l.iqd}',
                      style: AppFonts.body(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Pressable(
              onTap: () => Navigator.pushNamed(context, Routes.topUp),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: AppColors.saffron, borderRadius: BorderRadius.circular(999)),
                child: Text('+ ${l.topUp}',
                    style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.saffronInk)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
