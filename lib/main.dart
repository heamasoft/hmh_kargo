import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'l10n/fallback_localizations.dart';
import 'providers/address_provider.dart';
import 'providers/approvals_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/registration_provider.dart';
import 'providers/shell_controller.dart';
import 'providers/stock_provider.dart';
import 'providers/wallet_provider.dart';
import 'router.dart';
import 'screens/auth_gate.dart';
import 'services/api_client.dart';
import 'services/push_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the app to portrait — it must not rotate with the device.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const HeamaApp());
}

class HeamaApp extends StatelessWidget {
  const HeamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // One API client shared by every provider so the auth token set at login
    // applies to all subsequent requests (cart, orders, wallet, ...).
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<PushService>(
          create: (_) => PushService(apiClient),
          dispose: (_, s) => s.dispose(),
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ShellController()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(apiClient)..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider(client: apiClient)..restore()),
        ChangeNotifierProvider(create: (_) => CatalogProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CartProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => WalletProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => AddressProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ApprovalsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => StockProvider(apiClient)),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'HMH KARGO',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supported,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              // Kurdish (ku) isn't in Flutter's bundled Material/Cupertino
              // localizations, so supply it (via Arabic data) before the Global
              // delegates to avoid "No MaterialLocalizations found" on ku pages.
              KuMaterialLocalizationsDelegate(),
              KuCupertinoLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthGate(),
            onGenerateRoute: Routes.onGenerateRoute,
            // Arabic and Kurdish Sorani are right-to-left. Force it explicitly
            // because `intl` doesn't always classify `ku` as RTL.
            builder: (context, child) {
              final code = localeProvider.locale.languageCode;
              final rtl = code == 'ar' || code == 'ku';
              return Directionality(
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
