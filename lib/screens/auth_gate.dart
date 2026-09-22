import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/store.dart';
import '../providers/auth_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/stock_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/ads_api.dart';
import '../services/api_client.dart';
import '../widgets/heama_splash.dart';
import 'auth/welcome_screen.dart';
import 'shell/main_shell.dart';

/// Decides the first screen based on the saved session:
///  - still checking → splash
///  - signed in      → the app (Home)
///  - signed out     → Welcome
///
/// While the splash is up (it stays at least ~1.3 s for its animation) it also
/// fetches what Home shows — stores, trending, ads, and their images — so Home
/// opens already filled in instead of loading in front of the shopper.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _signedInWarmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmPublic());
  }

  /// Public data — no account needed, so it starts at once, alongside the
  /// session check. Home asks for the same things; requests already in flight
  /// are shared (ApiClient), so nothing is fetched twice.
  Future<void> _warmPublic() async {
    if (!mounted) return;
    final catalog = context.read<CatalogProvider>();
    final ads = AdsApi(context.read<ApiClient>());
    await Future.wait<void>([
      catalog.loadStores().then((_) => _precacheStoreIcons(catalog.stores)),
      catalog.loadTrending(),
      ads.list().then(_precacheAds).catchError((_) {}),
    ]);
  }

  /// The signed-in extras, once the saved session is confirmed.
  void _warmSignedIn() {
    if (_signedInWarmed) return;
    _signedInWarmed = true;
    context.read<WalletProvider>().load();
    context.read<StockProvider>().load(lang: 'en');
  }

  /// Downloads and decodes the pictures Home shows first, so they appear with
  /// the page rather than popping in after it.
  void _precacheStoreIcons(List<Store> stores) {
    for (final s in stores.take(8)) {
      final url = s.iconUrl;
      if (url != null) _precache(url);
    }
  }

  void _precacheAds(List<Ad> ads) {
    for (final a in ads.take(3)) {
      _precache(a.imageUrl);
    }
  }

  void _precache(String url) {
    if (!mounted) return;
    precacheImage(CachedNetworkImageProvider(url), context).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.restoring) return const HeamaSplash();
    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _warmSignedIn();
      });
      return const MainShell();
    }
    return const WelcomeScreen();
  }
}
