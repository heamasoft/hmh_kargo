import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'HMH KARGO'**
  String get appName;

  /// No description provided for @welcomeTitleLine1.
  ///
  /// In en, this message translates to:
  /// **'Shop the world,'**
  String get welcomeTitleLine1;

  /// No description provided for @welcomeTitleLine2.
  ///
  /// In en, this message translates to:
  /// **'delivered to Iraq.'**
  String get welcomeTitleLine2;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order from Shein, Temu, Zara and more — prices in dinars, shipped to your door in Erbil, Duhok and beyond.'**
  String get welcomeSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccount;

  /// No description provided for @browseAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Browse as guest'**
  String get browseAsGuest;

  /// No description provided for @regNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get regNameTitle;

  /// No description provided for @regNameStep.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 4 · This is how we\'ll address you on deliveries.'**
  String get regNameStep;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Aland Hassan'**
  String get fullNameHint;

  /// No description provided for @errName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get errName;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @regCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are we delivering?'**
  String get regCityTitle;

  /// No description provided for @regCityStep.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 4 · Your city and a phone number we can verify.'**
  String get regCityStep;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select your city…'**
  String get selectCity;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'750 123 4567'**
  String get phoneHint;

  /// No description provided for @errCity.
  ///
  /// In en, this message translates to:
  /// **'Please choose your city.'**
  String get errCity;

  /// No description provided for @errPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get errPhone;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendCode;

  /// No description provided for @regOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get regOtpTitle;

  /// No description provided for @regOtpStep.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 4 · Enter the 4-digit code we sent to {phone}'**
  String regOtpStep(String phone);

  /// No description provided for @errOtp.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t right. Please check and try again.'**
  String get errOtp;

  /// No description provided for @demoHint.
  ///
  /// In en, this message translates to:
  /// **'The code was sent to your WhatsApp.'**
  String get demoHint;

  /// No description provided for @didntGetIt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get didntGetIt;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'Code re-sent'**
  String get codeResent;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @regPwTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get regPwTitle;

  /// No description provided for @regPwStep.
  ///
  /// In en, this message translates to:
  /// **'Step 4 of 4 · Keep your account secure.'**
  String get regPwStep;

  /// No description provided for @regPwOptionalSub.
  ///
  /// In en, this message translates to:
  /// **'Optional · add a password to log in without a code.'**
  String get regPwOptionalSub;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @usePassword.
  ///
  /// In en, this message translates to:
  /// **'Log in with password'**
  String get usePassword;

  /// No description provided for @useCode.
  ///
  /// In en, this message translates to:
  /// **'Log in with a code instead'**
  String get useCode;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetTitle;

  /// No description provided for @resetSub.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number and we\'ll send you a verification code.'**
  String get resetSub;

  /// No description provided for @newPwTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get newPwTitle;

  /// No description provided for @newPwSub.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get newPwSub;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated — please log in'**
  String get passwordUpdated;

  /// No description provided for @notRegistered.
  ///
  /// In en, this message translates to:
  /// **'This number isn\'t registered yet. Create an account to get started.'**
  String get notRegistered;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile and security'**
  String get accountSubtitle;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @phoneLocked.
  ///
  /// In en, this message translates to:
  /// **'Your phone number can\'t be changed.'**
  String get phoneLocked;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get confirmPasswordHint;

  /// No description provided for @errPw.
  ///
  /// In en, this message translates to:
  /// **'Passwords must match and be at least 6 characters.'**
  String get errPw;

  /// No description provided for @regDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get regDoneTitle;

  /// No description provided for @regDoneTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set, {name}!'**
  String regDoneTitleNamed(String name);

  /// No description provided for @regDoneSub.
  ///
  /// In en, this message translates to:
  /// **'Your HMH KARGO account is ready. Let\'s find you something good.'**
  String get regDoneSub;

  /// No description provided for @enterHeama.
  ///
  /// In en, this message translates to:
  /// **'Enter HMH KARGO'**
  String get enterHeama;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSub.
  ///
  /// In en, this message translates to:
  /// **'Log in to your HMH KARGO account.'**
  String get loginSub;

  /// No description provided for @yourPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get yourPassword;

  /// No description provided for @newToHeama.
  ///
  /// In en, this message translates to:
  /// **'New to HMH KARGO?'**
  String get newToHeama;

  /// No description provided for @heamaWallet.
  ///
  /// In en, this message translates to:
  /// **'HMH KARGO Wallet'**
  String get heamaWallet;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUp;

  /// No description provided for @topUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Add money to wallet'**
  String get topUpTitle;

  /// No description provided for @topUpIntro.
  ///
  /// In en, this message translates to:
  /// **'Top up your HMH KARGO wallet in either of these ways:'**
  String get topUpIntro;

  /// No description provided for @topUpFibTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer via FIB'**
  String get topUpFibTitle;

  /// No description provided for @topUpFibBody.
  ///
  /// In en, this message translates to:
  /// **'Send the amount to us using the FIB (First Iraqi Bank) app, then send the receipt on WhatsApp so we can confirm it.'**
  String get topUpFibBody;

  /// No description provided for @topUpContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us to top up'**
  String get topUpContactTitle;

  /// No description provided for @topUpCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Top up with cash'**
  String get topUpCashTitle;

  /// No description provided for @topUpContactBody.
  ///
  /// In en, this message translates to:
  /// **'Message or call us on WhatsApp and we\'ll add the balance to your wallet:'**
  String get topUpContactBody;

  /// No description provided for @actionWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get actionWhatsapp;

  /// No description provided for @actionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get actionCall;

  /// No description provided for @exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchange;

  /// No description provided for @exchangeAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get exchangeAmount;

  /// No description provided for @exchangeReceive.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive'**
  String get exchangeReceive;

  /// No description provided for @exchangeCta.
  ///
  /// In en, this message translates to:
  /// **'Exchange now'**
  String get exchangeCta;

  /// No description provided for @exchangeRateLine.
  ///
  /// In en, this message translates to:
  /// **'1 USD = {rate} IQD'**
  String exchangeRateLine(String rate);

  /// No description provided for @exchangeDone.
  ///
  /// In en, this message translates to:
  /// **'Exchange complete'**
  String get exchangeDone;

  /// No description provided for @exchangeEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount to exchange'**
  String get exchangeEnterAmount;

  /// No description provided for @approvalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping approvals'**
  String get approvalsTitle;

  /// No description provided for @approvalsBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} shipping update(s) need your approval'**
  String approvalsBanner(int count);

  /// No description provided for @approvalsBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Review now'**
  String get approvalsBannerAction;

  /// No description provided for @approvalOldShipping.
  ///
  /// In en, this message translates to:
  /// **'Old shipping'**
  String get approvalOldShipping;

  /// No description provided for @approvalNewShipping.
  ///
  /// In en, this message translates to:
  /// **'New shipping'**
  String get approvalNewShipping;

  /// No description provided for @approvalNewTotal.
  ///
  /// In en, this message translates to:
  /// **'New total'**
  String get approvalNewTotal;

  /// No description provided for @approvalAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get approvalAccept;

  /// No description provided for @approvalReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get approvalReject;

  /// No description provided for @approvalAcceptedMsg.
  ///
  /// In en, this message translates to:
  /// **'Accepted — we\'ll buy your item now.'**
  String get approvalAcceptedMsg;

  /// No description provided for @approvalRejectedMsg.
  ///
  /// In en, this message translates to:
  /// **'Rejected — the item was removed from your order and refunded to your wallet.'**
  String get approvalRejectedMsg;

  /// No description provided for @approvalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending shipping approvals.'**
  String get approvalsEmpty;

  /// No description provided for @itemShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get itemShipping;

  /// No description provided for @cancelItemAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel item'**
  String get cancelItemAction;

  /// No description provided for @cancelItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this item? Its price and shipping will be refunded to your wallet.'**
  String get cancelItemConfirm;

  /// No description provided for @itemCancelledMsg.
  ///
  /// In en, this message translates to:
  /// **'Item cancelled — refunded to your wallet.'**
  String get itemCancelledMsg;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About HMH KARGO'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'HMH KARGO lets you shop from international stores — Shein, Trendyol, Zara, H&M and more — and have your orders delivered to Iraq. Browse any store right inside the app, add products to your cart at one clear all-in price, pay from your wallet, and track every order from purchase to your door.'**
  String get aboutBody;

  /// No description provided for @aboutHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get aboutHowTitle;

  /// No description provided for @aboutHowBody.
  ///
  /// In en, this message translates to:
  /// **'Open a store, find a product, and tap Add to Cart — we price it all-in (item + shipping + service). Check out from your wallet, and we buy it, ship it to Iraq, and keep you updated at every step.'**
  String get aboutHowBody;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by Heama Soft'**
  String get developedBy;

  /// No description provided for @footerVisit.
  ///
  /// In en, this message translates to:
  /// **'Click here to visit'**
  String get footerVisit;

  /// No description provided for @footerContact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get footerContact;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products or paste a link…'**
  String get searchProductsHint;

  /// No description provided for @shopFavStores.
  ///
  /// In en, this message translates to:
  /// **'Shop your favourite stores'**
  String get shopFavStores;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @freeShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shein ships free with us'**
  String get freeShippingTitle;

  /// No description provided for @freeShippingSub.
  ///
  /// In en, this message translates to:
  /// **'Order any Shein item through the app and we cover the shipping to Iraq.'**
  String get freeShippingSub;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get shopNow;

  /// No description provided for @trendingInIraq.
  ///
  /// In en, this message translates to:
  /// **'Trending in Iraq'**
  String get trendingInIraq;

  /// No description provided for @trendingOn.
  ///
  /// In en, this message translates to:
  /// **'Trending on {store}'**
  String trendingOn(String store);

  /// No description provided for @savedHeart.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedHeart;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @storesSub.
  ///
  /// In en, this message translates to:
  /// **'Tap a store to open it inside HMH KARGO. The arrow opens the real website.'**
  String get storesSub;

  /// No description provided for @searchStores.
  ///
  /// In en, this message translates to:
  /// **'Search stores…'**
  String get searchStores;

  /// No description provided for @international.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get international;

  /// No description provided for @turkiye.
  ///
  /// In en, this message translates to:
  /// **'Türkiye'**
  String get turkiye;

  /// No description provided for @catFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get catFashion;

  /// No description provided for @catEverything.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get catEverything;

  /// No description provided for @catApparel.
  ///
  /// In en, this message translates to:
  /// **'Apparel'**
  String get catApparel;

  /// No description provided for @catGadgets.
  ///
  /// In en, this message translates to:
  /// **'Gadgets'**
  String get catGadgets;

  /// No description provided for @catTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get catTech;

  /// No description provided for @moreStores.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreStores;

  /// No description provided for @twentyPlusStores.
  ///
  /// In en, this message translates to:
  /// **'10+ stores'**
  String get twentyPlusStores;

  /// No description provided for @sheinInsideHeama.
  ///
  /// In en, this message translates to:
  /// **'Shein, shown inside HMH KARGO'**
  String get sheinInsideHeama;

  /// No description provided for @openRealSite.
  ///
  /// In en, this message translates to:
  /// **'Open real shein.com'**
  String get openRealSite;

  /// No description provided for @searchShein.
  ///
  /// In en, this message translates to:
  /// **'Search Shein…'**
  String get searchShein;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catTops.
  ///
  /// In en, this message translates to:
  /// **'Tops'**
  String get catTops;

  /// No description provided for @catDresses.
  ///
  /// In en, this message translates to:
  /// **'Dresses'**
  String get catDresses;

  /// No description provided for @catBottoms.
  ///
  /// In en, this message translates to:
  /// **'Bottoms'**
  String get catBottoms;

  /// No description provided for @catBags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get catBags;

  /// No description provided for @catShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get catShoes;

  /// No description provided for @popularNow.
  ///
  /// In en, this message translates to:
  /// **'Popular now'**
  String get popularNow;

  /// No description provided for @viewOnSite.
  ///
  /// In en, this message translates to:
  /// **'View on site'**
  String get viewOnSite;

  /// No description provided for @colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @deliveryToIraq.
  ///
  /// In en, this message translates to:
  /// **'Delivery to Iraq'**
  String get deliveryToIraq;

  /// No description provided for @deliveryInfo.
  ///
  /// In en, this message translates to:
  /// **'Arrives in 10–18 days via HMH KARGO warehouse · Duhok → your city in 24–48h'**
  String get deliveryInfo;

  /// No description provided for @allInDinars.
  ///
  /// In en, this message translates to:
  /// **'All-in, in dinars'**
  String get allInDinars;

  /// No description provided for @allInPrice.
  ///
  /// In en, this message translates to:
  /// **'All-in price'**
  String get allInPrice;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addToHeama.
  ///
  /// In en, this message translates to:
  /// **'Add to HMH KARGO'**
  String get addToHeama;

  /// No description provided for @captureSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to your cart'**
  String get captureSheetTitle;

  /// No description provided for @captureCheckDetails.
  ///
  /// In en, this message translates to:
  /// **'Check the details, then add.'**
  String get captureCheckDetails;

  /// No description provided for @priceOnSite.
  ///
  /// In en, this message translates to:
  /// **'Price on site'**
  String get priceOnSite;

  /// No description provided for @productLink.
  ///
  /// In en, this message translates to:
  /// **'Product link'**
  String get productLink;

  /// No description provided for @fetchDetails.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get fetchDetails;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @itemNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get itemNote;

  /// No description provided for @itemNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Any requirement for this item — e.g. gift wrap, exact shade…'**
  String get itemNoteHint;

  /// No description provided for @loginToAdd.
  ///
  /// In en, this message translates to:
  /// **'Log in to add items to your cart.'**
  String get loginToAdd;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @couldntCapture.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this page automatically. Enter the details below.'**
  String get couldntCapture;

  /// No description provided for @detectedProduct.
  ///
  /// In en, this message translates to:
  /// **'HMH KARGO detected this product · price in IQD'**
  String get detectedProduct;

  /// No description provided for @chooseColorAndSize.
  ///
  /// In en, this message translates to:
  /// **'Please choose a colour and size first'**
  String get chooseColorAndSize;

  /// No description provided for @chooseColorFirst.
  ///
  /// In en, this message translates to:
  /// **'Please choose a colour first'**
  String get chooseColorFirst;

  /// No description provided for @chooseSizeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please choose a size first'**
  String get chooseSizeFirst;

  /// No description provided for @savedToFav.
  ///
  /// In en, this message translates to:
  /// **'Saved to favourites'**
  String get savedToFav;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart · {variant}'**
  String addedToCart(String variant);

  /// No description provided for @oneStorePerOrder.
  ///
  /// In en, this message translates to:
  /// **'Your cart has items from {store}. Check out or empty it before adding from another store.'**
  String oneStorePerOrder(String store);

  /// No description provided for @exclusiveOrder.
  ///
  /// In en, this message translates to:
  /// **'{store} must be ordered on its own. Check out or empty your cart before mixing stores.'**
  String exclusiveOrder(String store);

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(String count);

  /// No description provided for @soldCount.
  ///
  /// In en, this message translates to:
  /// **'5k+ sold'**
  String get soldCount;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @colorLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorLavender;

  /// No description provided for @colorRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// No description provided for @colorSage.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get colorSage;

  /// No description provided for @colorSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get colorSand;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @savedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved items'**
  String get savedItems;

  /// No description provided for @savedSub.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any product to save it here.'**
  String get savedSub;

  /// No description provided for @noSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved items yet'**
  String get noSavedTitle;

  /// No description provided for @noSavedSub.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any product and it lands here, ready to add to your cart.'**
  String get noSavedSub;

  /// No description provided for @yourCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart'**
  String get yourCart;

  /// No description provided for @cartSub.
  ///
  /// In en, this message translates to:
  /// **'Items captured from your stores'**
  String get cartSub;

  /// No description provided for @chooseVariantHint.
  ///
  /// In en, this message translates to:
  /// **'Choose colour & size on the product page'**
  String get chooseVariantHint;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String itemsCount(int count);

  /// No description provided for @shippingEst.
  ///
  /// In en, this message translates to:
  /// **'Shipping to Iraq (est.)'**
  String get shippingEst;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'HMH KARGO service fee'**
  String get serviceFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @continueToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Continue to checkout'**
  String get continueToCheckout;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay · {amount}'**
  String totalToPay(String amount);

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @walletBalanceLine.
  ///
  /// In en, this message translates to:
  /// **'Balance {amount} · best discounts'**
  String walletBalanceLine(String amount);

  /// No description provided for @fastpay.
  ///
  /// In en, this message translates to:
  /// **'FastPay / Zain Cash'**
  String get fastpay;

  /// No description provided for @fastpaySub.
  ///
  /// In en, this message translates to:
  /// **'Pay from your mobile wallet'**
  String get fastpaySub;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cashOnDelivery;

  /// No description provided for @cashOnDeliverySub.
  ///
  /// In en, this message translates to:
  /// **'Pay in cash when your order arrives'**
  String get cashOnDeliverySub;

  /// No description provided for @toPayOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'To pay on delivery'**
  String get toPayOnDelivery;

  /// No description provided for @paidByWallet.
  ///
  /// In en, this message translates to:
  /// **'Paid by wallet'**
  String get paidByWallet;

  /// No description provided for @paidOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Paid on delivery'**
  String get paidOnDelivery;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order · {amount}'**
  String placeOrder(String amount);

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderPlaced;

  /// No description provided for @yourOrders.
  ///
  /// In en, this message translates to:
  /// **'Your orders'**
  String get yourOrders;

  /// No description provided for @ordersSub.
  ///
  /// In en, this message translates to:
  /// **'Track every package on its journey to Iraq.'**
  String get ordersSub;

  /// No description provided for @ordersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersActive;

  /// No description provided for @ordersArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get ordersArchive;

  /// No description provided for @ordersActiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your in-progress orders will appear here.'**
  String get ordersActiveEmpty;

  /// No description provided for @ordersArchiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Delivered and closed orders will appear here.'**
  String get ordersArchiveEmpty;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @filterCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get filterCurrency;

  /// No description provided for @filterStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get filterStore;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterTopUps.
  ///
  /// In en, this message translates to:
  /// **'Top-ups'**
  String get filterTopUps;

  /// No description provided for @filterPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get filterPayments;

  /// No description provided for @filterRefunds.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get filterRefunds;

  /// No description provided for @walletLedgerTitle.
  ///
  /// In en, this message translates to:
  /// **'{currency} Wallet'**
  String walletLedgerTitle(String currency);

  /// No description provided for @inTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get inTransit;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @orderItemsPlaced.
  ///
  /// In en, this message translates to:
  /// **'{count} items · placed {date}'**
  String orderItemsPlaced(int count, String date);

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get cancelOrderTitle;

  /// No description provided for @cancelOrderBody.
  ///
  /// In en, this message translates to:
  /// **'You can cancel until we buy your items. Wallet payments are refunded to your wallet.'**
  String get cancelOrderBody;

  /// No description provided for @keepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get keepOrder;

  /// No description provided for @orderCancelledToast.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelledToast;

  /// No description provided for @refundedToWallet.
  ///
  /// In en, this message translates to:
  /// **'Refunded to wallet'**
  String get refundedToWallet;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order items'**
  String get orderItems;

  /// No description provided for @trackFromStores.
  ///
  /// In en, this message translates to:
  /// **'{count} items · from Shein & Temu'**
  String trackFromStores(int count);

  /// No description provided for @arrives.
  ///
  /// In en, this message translates to:
  /// **'Arrives'**
  String get arrives;

  /// No description provided for @stepPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get stepPlaced;

  /// No description provided for @stepBuying.
  ///
  /// In en, this message translates to:
  /// **'Buying your items'**
  String get stepBuying;

  /// No description provided for @stepBought.
  ///
  /// In en, this message translates to:
  /// **'Bought · Türkiye'**
  String get stepBought;

  /// No description provided for @stepZakhoOffice.
  ///
  /// In en, this message translates to:
  /// **'At Zakho office'**
  String get stepZakhoOffice;

  /// No description provided for @stepDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get stepDelivery;

  /// No description provided for @readyNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready now'**
  String get readyNowTitle;

  /// No description provided for @readyNowSub.
  ///
  /// In en, this message translates to:
  /// **'Already in Iraq — no shipping wait'**
  String get readyNowSub;

  /// No description provided for @readyShein.
  ///
  /// In en, this message translates to:
  /// **'Shein · in stock'**
  String get readyShein;

  /// No description provided for @readyOther.
  ///
  /// In en, this message translates to:
  /// **'Other stores · in stock'**
  String get readyOther;

  /// No description provided for @readyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in stock right now — check back soon.'**
  String get readyEmpty;

  /// No description provided for @stockAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get stockAdded;

  /// No description provided for @stockSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, size, colour…'**
  String get stockSearchHint;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low → high'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high → low'**
  String get sortPriceHigh;

  /// No description provided for @stockNoResults.
  ///
  /// In en, this message translates to:
  /// **'No items match your search.'**
  String get stockNoResults;

  /// No description provided for @stockCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String stockCount(int count);

  /// No description provided for @stepPlacedSub.
  ///
  /// In en, this message translates to:
  /// **'{date} · paid {amount}'**
  String stepPlacedSub(String date, String amount);

  /// No description provided for @stepPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased from store'**
  String get stepPurchased;

  /// No description provided for @stepPurchasedSub.
  ///
  /// In en, this message translates to:
  /// **'{date} · HMH KARGO bought your items'**
  String stepPurchasedSub(String date);

  /// No description provided for @stepWarehouse.
  ///
  /// In en, this message translates to:
  /// **'At warehouse · Türkiye'**
  String get stepWarehouse;

  /// No description provided for @stepWarehouseSub.
  ///
  /// In en, this message translates to:
  /// **'{date} · packed for Iraq'**
  String stepWarehouseSub(String date);

  /// No description provided for @stepTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit to Iraq'**
  String get stepTransit;

  /// No description provided for @stepTransitSub.
  ///
  /// In en, this message translates to:
  /// **'On the way to Duhok'**
  String get stepTransitSub;

  /// No description provided for @currentStep.
  ///
  /// In en, this message translates to:
  /// **'Current step'**
  String get currentStep;

  /// No description provided for @stepArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived · Duhok office'**
  String get stepArrived;

  /// No description provided for @stepArrivedSub.
  ///
  /// In en, this message translates to:
  /// **'Ready for local delivery'**
  String get stepArrivedSub;

  /// No description provided for @stepOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery · Erbil'**
  String get stepOutForDelivery;

  /// No description provided for @stepOutForDeliverySub.
  ///
  /// In en, this message translates to:
  /// **'To your door in 24–48h'**
  String get stepOutForDeliverySub;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'{city} · HMH KARGO member since {year}'**
  String memberSince(String city, String year);

  /// No description provided for @walletBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get walletBalanceLabel;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @topUpWith.
  ///
  /// In en, this message translates to:
  /// **'Top up with'**
  String get topUpWith;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrders;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddress;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @selectGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Select governorate'**
  String get selectGovernorate;

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home address'**
  String get homeAddress;

  /// No description provided for @homeAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Neighbourhood, street, house/apartment…'**
  String get homeAddressHint;

  /// No description provided for @otherCity.
  ///
  /// In en, this message translates to:
  /// **'Other (type your city)'**
  String get otherCity;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setDefault;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @noAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'No addresses yet'**
  String get noAddressesTitle;

  /// No description provided for @noAddressesSub.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery address so we know where to bring your orders.'**
  String get noAddressesSub;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards & points'**
  String get rewards;

  /// No description provided for @languageMenu.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageMenu;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This closes your account: you will be signed out and can no longer log in with this number. Your orders and wallet stay on record — contact us if you want it reopened.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountDone.
  ///
  /// In en, this message translates to:
  /// **'Your account has been closed.'**
  String get deleteAccountDone;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get deleteAccountError;

  /// No description provided for @fastpayShort.
  ///
  /// In en, this message translates to:
  /// **'FastPay'**
  String get fastpayShort;

  /// No description provided for @zainCash.
  ///
  /// In en, this message translates to:
  /// **'Zain Cash'**
  String get zainCash;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get navStores;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @cityErbil.
  ///
  /// In en, this message translates to:
  /// **'Erbil'**
  String get cityErbil;

  /// No description provided for @cityDuhok.
  ///
  /// In en, this message translates to:
  /// **'Duhok'**
  String get cityDuhok;

  /// No description provided for @citySulaymaniyah.
  ///
  /// In en, this message translates to:
  /// **'Sulaymaniyah'**
  String get citySulaymaniyah;

  /// No description provided for @cityHalabja.
  ///
  /// In en, this message translates to:
  /// **'Halabja'**
  String get cityHalabja;

  /// No description provided for @cityKirkuk.
  ///
  /// In en, this message translates to:
  /// **'Kirkuk'**
  String get cityKirkuk;

  /// No description provided for @cityMosul.
  ///
  /// In en, this message translates to:
  /// **'Mosul'**
  String get cityMosul;

  /// No description provided for @cityBaghdad.
  ///
  /// In en, this message translates to:
  /// **'Baghdad'**
  String get cityBaghdad;

  /// No description provided for @cityBasra.
  ///
  /// In en, this message translates to:
  /// **'Basra'**
  String get cityBasra;

  /// No description provided for @iqd.
  ///
  /// In en, this message translates to:
  /// **'IQD'**
  String get iqd;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageKurdish.
  ///
  /// In en, this message translates to:
  /// **'کوردی'**
  String get languageKurdish;

  /// No description provided for @exchangeRates.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get exchangeRates;

  /// No description provided for @tapToCalculate.
  ///
  /// In en, this message translates to:
  /// **'Tap to calculate'**
  String get tapToCalculate;

  /// No description provided for @dollarToDinar.
  ///
  /// In en, this message translates to:
  /// **'Dollar → Dinar'**
  String get dollarToDinar;

  /// No description provided for @liraToDollar.
  ///
  /// In en, this message translates to:
  /// **'Lira → Dollar'**
  String get liraToDollar;

  /// No description provided for @rateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Rate not set yet'**
  String get rateNotSet;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @inDinars.
  ///
  /// In en, this message translates to:
  /// **'In dinars'**
  String get inDinars;

  /// No description provided for @inDollars.
  ///
  /// In en, this message translates to:
  /// **'In dollars'**
  String get inDollars;

  /// No description provided for @sameAsCart.
  ///
  /// In en, this message translates to:
  /// **'Same price your cart charges'**
  String get sameAsCart;

  /// No description provided for @orderForCustomer.
  ///
  /// In en, this message translates to:
  /// **'Order for customer'**
  String get orderForCustomer;

  /// No description provided for @chooseCustomer.
  ///
  /// In en, this message translates to:
  /// **'Choose customer'**
  String get chooseCustomer;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone…'**
  String get searchCustomers;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @chooseCustomerFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose the customer this order is for.'**
  String get chooseCustomerFirst;

  /// No description provided for @chargedToWallet.
  ///
  /// In en, this message translates to:
  /// **'Charged to {name}\'s wallet'**
  String chargedToWallet(String name);

  /// No description provided for @orderPlacedFor.
  ///
  /// In en, this message translates to:
  /// **'Order placed for {name}'**
  String orderPlacedFor(String name);

  /// No description provided for @addByLink.
  ///
  /// In en, this message translates to:
  /// **'Add an item by link'**
  String get addByLink;

  /// No description provided for @addByLinkSub.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it in our stores? Paste its link and price.'**
  String get addByLinkSub;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPrice;

  /// No description provided for @linkRequired.
  ///
  /// In en, this message translates to:
  /// **'Paste the product\'s link.'**
  String get linkRequired;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the product\'s price.'**
  String get priceRequired;

  /// No description provided for @fromStore.
  ///
  /// In en, this message translates to:
  /// **'From {store} — priced in its currency'**
  String fromStore(String store);

  /// No description provided for @cartAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get cartAdd;

  /// No description provided for @addToCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to your cart'**
  String get addToCartTitle;

  /// No description provided for @importSharedCart.
  ///
  /// In en, this message translates to:
  /// **'Import a shared cart'**
  String get importSharedCart;

  /// No description provided for @importSharedCartSub.
  ///
  /// In en, this message translates to:
  /// **'A Shein cart or Trendyol collection link'**
  String get importSharedCartSub;

  /// No description provided for @icTitle.
  ///
  /// In en, this message translates to:
  /// **'Import cart'**
  String get icTitle;

  /// No description provided for @icFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding your cart…'**
  String get icFinding;

  /// No description provided for @icOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening {store}…'**
  String icOpening(String store);

  /// No description provided for @icReading.
  ///
  /// In en, this message translates to:
  /// **'Reading your cart…'**
  String get icReading;

  /// No description provided for @icPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait — this takes a few seconds.'**
  String get icPleaseWait;

  /// No description provided for @icNotALink.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a link.'**
  String get icNotALink;

  /// No description provided for @icTooLong.
  ///
  /// In en, this message translates to:
  /// **'Loading took too long. Check your connection and tap Load again.'**
  String get icTooLong;

  /// No description provided for @icServerCantRead.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read that link. Check it is a Shein cart or Trendyol collection link.'**
  String get icServerCantRead;

  /// No description provided for @icEmptyCollection.
  ///
  /// In en, this message translates to:
  /// **'That collection has no items we can order. Check it still has products in stock, then tap Load again.'**
  String get icEmptyCollection;

  /// No description provided for @icSingleProduct.
  ///
  /// In en, this message translates to:
  /// **'That link is a single product, not a cart. Share your cart (Shein) or a collection (Trendyol), or use \"Paste link\" on the store page for one item.'**
  String get icSingleProduct;

  /// No description provided for @icCouldNotRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read the cart. Tap Load again.'**
  String get icCouldNotRead;

  /// No description provided for @icNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items found on that cart. Check the link is a shared Shein cart and that it still has items, then tap Load again.'**
  String get icNoItems;

  /// No description provided for @icPickSizeOne.
  ///
  /// In en, this message translates to:
  /// **'Pick a size for \"{title}\" first — tap \"Choose size\".'**
  String icPickSizeOne(String title);

  /// No description provided for @icPickSizeMany.
  ///
  /// In en, this message translates to:
  /// **'Pick a size for {count} items first — tap \"Choose size\" on each.'**
  String icPickSizeMany(int count);

  /// No description provided for @icStoresLoading.
  ///
  /// In en, this message translates to:
  /// **'Stores are still loading — try again in a moment.'**
  String get icStoresLoading;

  /// No description provided for @icNothingAdded.
  ///
  /// In en, this message translates to:
  /// **'Nothing could be added.'**
  String get icNothingAdded;

  /// No description provided for @icCouldNotAdd.
  ///
  /// In en, this message translates to:
  /// **'Could not add: {title}'**
  String icCouldNotAdd(String title);

  /// No description provided for @icAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) added to your cart.'**
  String icAdded(int count);

  /// No description provided for @icBringOver.
  ///
  /// In en, this message translates to:
  /// **'Bring your cart over'**
  String get icBringOver;

  /// No description provided for @icBringOverSub.
  ///
  /// In en, this message translates to:
  /// **'Share your cart from the Shein app, or a collection from the Trendyol app, paste the link above and tap Load.'**
  String get icBringOverSub;

  /// No description provided for @icShareCart.
  ///
  /// In en, this message translates to:
  /// **'Cart → Share'**
  String get icShareCart;

  /// No description provided for @icShareCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection → Share'**
  String get icShareCollection;

  /// No description provided for @icHumanCheck.
  ///
  /// In en, this message translates to:
  /// **'Shein wants a quick check that you\'re human. Complete it below — loading carries on by itself afterwards.'**
  String get icHumanCheck;

  /// No description provided for @icLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Shein cart or Trendyol collection link'**
  String get icLinkLabel;

  /// No description provided for @icLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the link from the app'**
  String get icLinkHint;

  /// No description provided for @icLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get icLoad;

  /// No description provided for @icCurrencyAdvice.
  ///
  /// In en, this message translates to:
  /// **'Shein is showing prices in {foreign}, but this store is priced in {store} — adding them now would charge the wrong amount. Tap Load again; if it persists, tell us.'**
  String icCurrencyAdvice(String foreign, String store);

  /// No description provided for @icChooseSize.
  ///
  /// In en, this message translates to:
  /// **'Choose size'**
  String get icChooseSize;

  /// No description provided for @icSizeValue.
  ///
  /// In en, this message translates to:
  /// **'Size {size}'**
  String icSizeValue(String size);

  /// No description provided for @icAddChosen.
  ///
  /// In en, this message translates to:
  /// **'Add {count} to cart'**
  String icAddChosen(int count);

  /// No description provided for @closeAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Close account'**
  String get closeAccountSection;

  /// No description provided for @closeAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Signs you out and stops this number from logging in.'**
  String get closeAccountSub;

  /// No description provided for @deleteAccountAck.
  ///
  /// In en, this message translates to:
  /// **'I understand my account will be closed'**
  String get deleteAccountAck;

  /// No description provided for @couponHave.
  ///
  /// In en, this message translates to:
  /// **'Have a coupon?'**
  String get couponHave;

  /// No description provided for @couponHint.
  ///
  /// In en, this message translates to:
  /// **'Coupon code'**
  String get couponHint;

  /// No description provided for @couponApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get couponApply;

  /// No description provided for @couponRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get couponRemove;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon {code} applied — {percent} off'**
  String couponApplied(String code, String percent);

  /// No description provided for @couponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Coupon ({code})'**
  String couponDiscount(String code);

  /// No description provided for @coupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get coupons;

  /// No description provided for @couponNew.
  ///
  /// In en, this message translates to:
  /// **'New coupon'**
  String get couponNew;

  /// No description provided for @couponPercent.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get couponPercent;

  /// No description provided for @couponExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get couponExpires;

  /// No description provided for @couponNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get couponNoExpiry;

  /// No description provided for @couponCreate.
  ///
  /// In en, this message translates to:
  /// **'Create coupon'**
  String get couponCreate;

  /// No description provided for @couponCreated.
  ///
  /// In en, this message translates to:
  /// **'Coupon created'**
  String get couponCreated;

  /// No description provided for @couponsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No coupons yet. Create one with the + button.'**
  String get couponsEmpty;

  /// No description provided for @couponUsedTimes.
  ///
  /// In en, this message translates to:
  /// **'Used {count} times'**
  String couponUsedTimes(int count);

  /// No description provided for @couponActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get couponActive;

  /// No description provided for @couponOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get couponOff;

  /// No description provided for @couponExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get couponExpired;

  /// No description provided for @couponOnePerCustomer.
  ///
  /// In en, this message translates to:
  /// **'Each customer can use a coupon once.'**
  String get couponOnePerCustomer;

  /// No description provided for @adsTitle.
  ///
  /// In en, this message translates to:
  /// **'Home ads'**
  String get adsTitle;

  /// No description provided for @adsSub.
  ///
  /// In en, this message translates to:
  /// **'Images shown in the slider at the top of the Home page. Use 1600 × 800 px (2:1) so nothing is cut on any screen.'**
  String get adsSub;

  /// No description provided for @adsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ads yet. Tap + to add an image.'**
  String get adsEmpty;

  /// No description provided for @adsLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Link when tapped'**
  String get adsLinkTitle;

  /// No description provided for @adsLinkHint.
  ///
  /// In en, this message translates to:
  /// **'https://… (optional)'**
  String get adsLinkHint;

  /// No description provided for @adsPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get adsPublish;

  /// No description provided for @adsPublished.
  ///
  /// In en, this message translates to:
  /// **'Ad published'**
  String get adsPublished;

  /// No description provided for @adsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this ad? It will disappear from the Home page.'**
  String get adsDeleteConfirm;

  /// No description provided for @adsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adsDelete;

  /// No description provided for @adsHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get adsHidden;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
