import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../utils/launcher.dart';
import '../../widgets/heama_toast.dart';
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
      storeKey: storeKey,
      autoServerFetch: autoServerFetch,
    ),
  );
}
