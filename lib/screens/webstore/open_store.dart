import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../router.dart';
import '../../utils/launcher.dart';
import '../../utils/link_text.dart';
import '../../utils/store_link.dart';
import '../../widgets/heama_toast.dart';
import '../cart/manual_item_sheet.dart';
import 'capture_sheet.dart';
import 'web_store_screen.dart';

/// Opens a store the right way for the platform:
///  - mobile: the in-app WebView (the capture button grabs the current URL)
///  - web: the real site in a new tab + the capture sheet where the user
///    pastes the product link (the server does the scraping)
void openStore(BuildContext context, Store store) {
  if (kIsWeb) {
    openUrl(store.url);
    // Web can't read another site — user pastes the link, server scrapes it.
    showCaptureSheet(context, storeKey: store.id, autoServerFetch: true);
  } else {
    Navigator.pushNamed(context, Routes.webStore, arguments: store);
  }
}

/// Opens a specific product URL inside its store's WebView (e.g. a trending
/// item). On web, opens the real page + the paste/capture sheet.
void openProductInStore(BuildContext context, Store store, String url) {
  if (kIsWeb) {
    openUrl(url);
    showCaptureSheet(context, initialUrl: url, storeKey: store.id, autoServerFetch: true);
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
  Navigator.pushNamed(
    context,
    Routes.webStore,
    arguments: WebStoreArgs(store, url: url, captureOnOpen: true),
  );
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
