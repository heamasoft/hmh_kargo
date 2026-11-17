import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/launcher.dart';
import '../../utils/link_text.dart';
import '../../utils/store_link.dart';
import '../../widgets/heama_toast.dart';
import '../cart/manual_item_sheet.dart';
import 'capture_sheet.dart';
import 'web_store_screen.dart';

/// On iPhone and iPad a shop's website is never shown inside our own screens.
///
/// App Review rejected the app three times under guideline 4.1(b): a shop's
/// site drawn inside an HMH screen, with our cart and add buttons over it,
/// reads as the app presenting that shop's brand. So on iOS the site opens in
/// the system's own browser sheet, which is Safari, not us; the shopper copies
/// the link there and pastes it here, and a pasted link is read behind our own
/// loading screen. Android keeps the in-app store.
bool get storesInSystemBrowser => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Opens a store the right way for the platform:
///  - iOS: the system browser sheet, after a word on bringing the link back
///  - Android: the in-app WebView (the capture button grabs the current URL)
///  - web: the real site in a new tab + the capture sheet where the user
///    pastes the product link (the server does the scraping)
void openStore(BuildContext context, Store store) {
  if (kIsWeb) {
    openUrl(store.url);
    // Web can't read another site — user pastes the link, server scrapes it.
    showCaptureSheet(context, storeKey: store.id, autoServerFetch: true);
  } else if (storesInSystemBrowser) {
    _openInSystemBrowser(context, store.url);
  } else {
    Navigator.pushNamed(context, Routes.webStore, arguments: store);
  }
}

const _browserTipSeenKey = 'browser_tip_seen_v1';

/// Shows, the first time, how a find on the website comes back here; then
/// opens the site in the system browser sheet.
Future<void> _openInSystemBrowser(BuildContext context, String url) async {
  var seen = false;
  try {
    seen = (await SharedPreferences.getInstance()).getBool(_browserTipSeenKey) ?? false;
  } catch (_) {}
  if (!seen && context.mounted) {
    final go = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _BrowserTip(),
    );
    if (go != true) return;
    try {
      (await SharedPreferences.getInstance()).setBool(_browserTipSeenKey, true);
    } catch (_) {}
  }
  await openInBrowserSheet(url);
}

class _BrowserTip extends StatelessWidget {
  const _BrowserTip();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [
      (Icons.search_rounded, l.browserTipStep1),
      (Icons.ios_share_rounded, l.browserTipStep2),
      (Icons.add_link_rounded, l.browserTipStep3),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.browserTipTitle, style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 6),
            Text(l.browserTipSub,
                style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 16),
            for (final s in steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.pomegranate.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(s.$1, size: 19, color: AppColors.pomegranate),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s.$2,
                          style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.3)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pomegranate,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.browserTipOpen,
                    style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens a specific product URL inside its store's WebView (e.g. a trending
/// item). On web, opens the real page + the paste/capture sheet. On iOS the
/// product is read behind our own loading screen and the add sheet comes up.
void openProductInStore(BuildContext context, Store store, String url) {
  if (kIsWeb) {
    openUrl(url);
    showCaptureSheet(context, initialUrl: url, storeKey: store.id, autoServerFetch: true);
  } else if (storesInSystemBrowser) {
    Navigator.pushNamed(context, Routes.webStore,
        arguments: WebStoreArgs(store, url: url, captureOnOpen: true));
  } else {
    Navigator.pushNamed(context, Routes.webStore,
        arguments: WebStoreArgs(store, url: url));
  }
}

/// Opens whatever the shopper pasted, wherever they pasted it.
///
/// A link to a store we carry goes into that store's page with the capture
/// armed: the page is read where it stands, so the sheet comes up with the
/// price, the sizes and the colours the product actually has — which is what
/// browsing to it by hand would have given them. Anything else goes to the
/// add-by-hand sheet with the link already filled in, where they name the price
/// themselves.
void openPastedLink(BuildContext context, String pasted) {
  var url = linkFromPaste(pasted.trim());
  if (url.isEmpty) return;
  if (!url.startsWith('http')) url = 'https://$url';
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasAuthority) {
    showHeamaToast(context, AppLocalizations.of(context).icNotALink);
    return;
  }

  final store = storeForLink(url, context.read<CatalogProvider>().stores);
  if (store == null) {
    showManualItemSheet(context, initialUrl: url);
    return;
  }
  if (kIsWeb) {
    openUrl(url);
    showCaptureSheet(context, initialUrl: url, storeKey: store.id, autoServerFetch: true);
    return;
  }
  // A cart is many items — straight to the import, which reads every one.
  // Short app links go to the store page, which follows them and hands a
  // cart over to the import when that is what they turn out to be.
  if (isSharedCartLink(url)) {
    Navigator.pushNamed(context, Routes.sheinCart, arguments: url);
    return;
  }
  Navigator.pushNamed(
    context,
    Routes.webStore,
    arguments: WebStoreArgs(store, url: url, captureOnOpen: true),
  );
}

/// Opens a website the shopper typed or pasted themselves — "trendyol.com",
/// a full product link, anything.
///
/// The app lists no shops of its own (guideline 4.1): the shopper names the
/// site, and only then is it shown, in the in-app browser, where they add what
/// they like. A product or cart link goes the way a pasted link always does; a
/// site we can't buy from goes to the add-by-hand sheet with its link filled
/// in, so nothing they find is a dead end.
void openWebsite(BuildContext context, String typed) {
  var url = linkFromPaste(typed.trim());
  if (url.isEmpty) url = typed.trim();
  if (url.isEmpty) return;
  // "trendyol" alone means the .com site.
  if (!url.contains('.') && !url.contains('/') && RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(url)) {
    url = '$url.com';
  }
  if (!url.startsWith('http')) url = 'https://$url';
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasAuthority || !uri.host.contains('.')) {
    showHeamaToast(context, AppLocalizations.of(context).icNotALink);
    return;
  }
  // A link to a product or cart — read it, exactly as a pasted link is.
  final isDeep = uri.path.length > 1 || uri.query.isNotEmpty;
  if (isDeep) {
    openPastedLink(context, url);
    return;
  }
  final store = storeForLink(url, context.read<CatalogProvider>().stores);
  if (store == null) {
    showManualItemSheet(context, initialUrl: url);
    return;
  }
  if (kIsWeb) {
    openUrl(url);
    showCaptureSheet(context, storeKey: store.id, autoServerFetch: true);
    return;
  }
  Navigator.pushNamed(context, Routes.webStore, arguments: WebStoreArgs(store, url: url));
}

/// Shows the capture sheet. On mobile the initial fields come straight from the
/// rendered page; on web only a link is provided and the server scrapes it.
Future<void> showCaptureSheet(
  BuildContext context, {
  String? initialUrl,
  String? initialTitle,
  String? initialImage,
  double? initialPrice,
  String? initialCurrency,
  String? initialColor,
  String? initialSize,
  String? initialSku,
  bool offersColor = true,
  bool offersSize = true,
  List<String> colorOptions = const [],
  List<String> sizeOptions = const [],
  Map<String, double> sizePrices = const {},
  required String storeKey,
  bool autoServerFetch = false,
}) {
  // Capturing requires an account (cart is per-user). Send guests to log in.
  if (!context.read<AuthProvider>().isAuthenticated) {
    showHeamaToast(context, AppLocalizations.of(context).loginToAdd);
    Navigator.pushNamed(context, Routes.login);
    return Future.value();
  }
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CaptureSheet(
      initialUrl: initialUrl,
      initialTitle: initialTitle,
      initialImage: initialImage,
      initialPrice: initialPrice,
      initialCurrency: initialCurrency,
      initialColor: initialColor,
      initialSize: initialSize,
      initialSku: initialSku,
      offersColor: offersColor,
      offersSize: offersSize,
      colorOptions: colorOptions,
      sizeOptions: sizeOptions,
      sizePrices: sizePrices,
      storeKey: storeKey,
      autoServerFetch: autoServerFetch,
    ),
  );
}
