import 'package:flutter/material.dart';

import 'models/product.dart';
import 'models/store.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_city_screen.dart';
import 'screens/auth/register_name_screen.dart';
import 'screens/auth/register_otp_screen.dart';
import 'screens/auth/register_password_screen.dart';
import 'screens/auth/register_success_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/forgot_otp_screen.dart';
import 'screens/auth/forgot_new_password_screen.dart';
import 'screens/addresses/addresses_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/orders/approvals_screen.dart';
import 'screens/stock/stock_screen.dart';
import 'screens/profile/account_screen.dart';
import 'screens/profile/wallet_ledger_screen.dart';
import 'screens/profile/top_up_screen.dart';
import 'screens/profile/about_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/saved/saved_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/storefront/storefront_screen.dart';
import 'screens/tracking/tracking_screen.dart';
import 'screens/webstore/web_store_screen.dart';

/// Central route table for the app.
class Routes {
  Routes._();

  static const welcome = '/welcome';
  static const registerName = '/register/name';
  static const registerCity = '/register/city';
  static const registerOtp = '/register/otp';
  static const registerPassword = '/register/password';
  static const registerSuccess = '/register/success';
  static const login = '/login';
  static const account = '/account';
  static const forgotPassword = '/forgot';
  static const forgotOtp = '/forgot/otp';
  static const forgotNewPassword = '/forgot/new-password';

  static const home = '/home'; // main shell (tabbed)
  static const storefront = '/storefront';
  static const webStore = '/web-store';
  static const product = '/product';
  static const saved = '/saved';
  static const addresses = '/addresses';
  static const checkout = '/checkout';
  static const tracking = '/tracking';
  static const walletLedger = '/wallet-ledger';
  static const topUp = '/top-up';
  static const about = '/about';
  static const approvals = '/approvals';
  static const stock = '/stock';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case welcome:
        page = const WelcomeScreen();
        break;
      case registerName:
        page = const RegisterNameScreen();
        break;
      case registerCity:
        page = const RegisterCityScreen();
        break;
      case registerOtp:
        page = const RegisterOtpScreen();
        break;
      case registerPassword:
        page = const RegisterPasswordScreen();
        break;
      case registerSuccess:
        page = const RegisterSuccessScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case account:
        page = const AccountScreen();
        break;
      case forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case forgotOtp:
        page = ForgotOtpScreen(phone: settings.arguments as String);
        break;
      case forgotNewPassword:
        page = ForgotNewPasswordScreen(phone: settings.arguments as String);
        break;
      case home:
        page = MainShell(initialTab: (settings.arguments as int?) ?? 0);
        break;
      case storefront:
        page = const StorefrontScreen();
        break;
      case webStore:
        final wsArgs = settings.arguments;
        if (wsArgs is WebStoreArgs) {
          page = WebStoreScreen(store: wsArgs.store, initialUrl: wsArgs.url);
        } else {
          page = WebStoreScreen(store: wsArgs as Store);
        }
        break;
      case product:
        page = ProductDetailScreen(product: settings.arguments as Product);
        break;
      case saved:
        page = const SavedScreen();
        break;
      case addresses:
        page = const AddressesScreen();
        break;
      case checkout:
        page = const CheckoutScreen();
        break;
      case tracking:
        page = TrackingScreen(orderCode: settings.arguments as String?);
        break;
      case walletLedger:
        page = WalletLedgerScreen(currency: (settings.arguments as String?) ?? 'IQD');
        break;
      case topUp:
        page = const TopUpScreen();
        break;
      case about:
        page = const AboutScreen();
        break;
      case approvals:
        page = const ApprovalsScreen();
        break;
      case stock:
        page = const StockScreen();
        break;
      default:
        page = const WelcomeScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
