// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'HMH KARGO';

  @override
  String get welcomeTitleLine1 => 'Shop the world,';

  @override
  String get welcomeTitleLine2 => 'delivered to Iraq.';

  @override
  String get welcomeSubtitle =>
      'Order from Shein, Temu, Zara and more — prices in dinars, shipped to your door in Erbil, Duhok and beyond.';

  @override
  String get createAccount => 'Create an account';

  @override
  String get haveAccount => 'I already have an account';

  @override
  String get browseAsGuest => 'Browse as guest';

  @override
  String get regNameTitle => 'What\'s your name?';

  @override
  String get regNameStep =>
      'Step 1 of 4 · This is how we\'ll address you on deliveries.';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameHint => 'e.g. Aland Hassan';

  @override
  String get errName => 'Please enter your full name.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get login => 'Log in';

  @override
  String get regCityTitle => 'Where are we delivering?';

  @override
  String get regCityStep =>
      'Step 2 of 4 · Your city and a phone number we can verify.';

  @override
  String get city => 'City';

  @override
  String get selectCity => 'Select your city…';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneHint => '750 123 4567';

  @override
  String get errCity => 'Please choose your city.';

  @override
  String get errPhone => 'Please enter a valid phone number.';

  @override
  String get sendCode => 'Send verification code';

  @override
  String get regOtpTitle => 'Verify your number';

  @override
  String regOtpStep(String phone) {
    return 'Step 3 of 4 · Enter the 4-digit code we sent to $phone';
  }

  @override
  String get errOtp => 'That code isn\'t right. Please check and try again.';

  @override
  String get demoHint => 'The code was sent to your WhatsApp.';

  @override
  String get didntGetIt => 'Didn\'t get it?';

  @override
  String get resendCode => 'Resend code';

  @override
  String get codeResent => 'Code re-sent';

  @override
  String get verify => 'Verify';

  @override
  String get regPwTitle => 'Create a password';

  @override
  String get regPwStep => 'Step 4 of 4 · Keep your account secure.';

  @override
  String get regPwOptionalSub =>
      'Optional · add a password to log in without a code.';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get usePassword => 'Log in with password';

  @override
  String get useCode => 'Log in with a code instead';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetSub =>
      'Enter your phone number and we\'ll send you a verification code.';

  @override
  String get newPwTitle => 'Set a new password';

  @override
  String get newPwSub => 'Choose a new password for your account.';

  @override
  String get savePassword => 'Save password';

  @override
  String get passwordUpdated => 'Password updated — please log in';

  @override
  String get notRegistered =>
      'This number isn\'t registered yet. Create an account to get started.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSubtitle => 'Manage your profile and security';

  @override
  String get profileSection => 'Profile';

  @override
  String get changePassword => 'Change password';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get phoneLocked => 'Your phone number can\'t be changed.';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Repeat password';

  @override
  String get errPw => 'Passwords must match and be at least 6 characters.';

  @override
  String get regDoneTitle => 'You\'re all set!';

  @override
  String regDoneTitleNamed(String name) {
    return 'You\'re all set, $name!';
  }

  @override
  String get regDoneSub =>
      'Your HMH KARGO account is ready. Let\'s find you something good.';

  @override
  String get enterHeama => 'Enter HMH KARGO';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSub => 'Log in to your HMH KARGO account.';

  @override
  String get yourPassword => 'Your password';

  @override
  String get newToHeama => 'New to HMH KARGO?';

  @override
  String get heamaWallet => 'HMH KARGO Wallet';

  @override
  String get topUp => 'Top up';

  @override
  String get topUpTitle => 'Add money to wallet';

  @override
  String get topUpIntro =>
      'Top up your HMH KARGO wallet in either of these ways:';

  @override
  String get topUpFibTitle => 'Transfer via FIB';

  @override
  String get topUpFibBody =>
      'Send the amount to us using the FIB (First Iraqi Bank) app, then send the receipt on WhatsApp so we can confirm it.';

  @override
  String get topUpContactTitle => 'Contact us to top up';

  @override
  String get topUpCashTitle => 'Top up with cash';

  @override
  String get topUpContactBody =>
      'Message or call us on WhatsApp and we\'ll add the balance to your wallet:';

  @override
  String get actionWhatsapp => 'WhatsApp';

  @override
  String get actionCall => 'Call';

  @override
  String get exchange => 'Exchange';

  @override
  String get exchangeAmount => 'Amount';

  @override
  String get exchangeReceive => 'You\'ll receive';

  @override
  String get exchangeCta => 'Exchange now';

  @override
  String exchangeRateLine(String rate) {
    return '1 USD = $rate IQD';
  }

  @override
  String get exchangeDone => 'Exchange complete';

  @override
  String get exchangeEnterAmount => 'Enter an amount to exchange';

  @override
  String get approvalsTitle => 'Shipping approvals';

  @override
  String approvalsBanner(int count) {
    return '$count shipping update(s) need your approval';
  }

  @override
  String get approvalsBannerAction => 'Review now';

  @override
  String get approvalOldShipping => 'Old shipping';

  @override
  String get approvalNewShipping => 'New shipping';

  @override
  String get approvalNewTotal => 'New total';

  @override
  String get approvalAccept => 'Accept';

  @override
  String get approvalReject => 'Reject';

  @override
  String get approvalAcceptedMsg => 'Accepted — we\'ll buy your item now.';

  @override
  String get approvalRejectedMsg =>
      'Rejected — the item was removed from your order and refunded to your wallet.';

  @override
  String get approvalsEmpty => 'No pending shipping approvals.';

  @override
  String get itemShipping => 'Shipping';

  @override
  String get cancelItemAction => 'Cancel item';

  @override
  String get cancelItemConfirm =>
      'Cancel this item? Its price and shipping will be refunded to your wallet.';

  @override
  String get itemCancelledMsg => 'Item cancelled — refunded to your wallet.';

  @override
  String get aboutTitle => 'About HMH KARGO';

  @override
  String get aboutBody =>
      'HMH KARGO lets you shop from international stores — Shein, Trendyol, Zara, H&M and more — and have your orders delivered to Iraq. Browse any store right inside the app, add products to your cart at one clear all-in price, pay from your wallet, and track every order from purchase to your door.';

  @override
  String get aboutHowTitle => 'How it works';

  @override
  String get aboutHowBody =>
      'Open a store, find a product, and tap Add to Cart — we price it all-in (item + shipping + service). Check out from your wallet, and we buy it, ship it to Iraq, and keep you updated at every step.';

  @override
  String get developedBy => 'Developed by Heama Soft';

  @override
  String get footerVisit => 'Click here to visit';

  @override
  String get footerContact => 'Contact us';

  @override
  String get searchProductsHint => 'Search products or paste a link…';

  @override
  String get shopFavStores => 'Shop your favourite stores';

  @override
  String get seeAll => 'See all';

  @override
  String get freeShippingTitle => 'Shein ships free with us';

  @override
  String get freeShippingSub =>
      'Order any Shein item through the app and we cover the shipping to Iraq.';

  @override
  String get shopNow => 'Shop now';

  @override
  String get trendingInIraq => 'Trending in Iraq';

  @override
  String trendingOn(String store) {
    return 'Trending on $store';
  }

  @override
  String get savedHeart => 'Saved';

  @override
  String get stores => 'Stores';

  @override
  String get storesSub =>
      'Tap a store to open it inside HMH KARGO. The arrow opens the real website.';

  @override
  String get searchStores => 'Search stores…';

  @override
  String get international => 'International';

  @override
  String get turkiye => 'Türkiye';

  @override
  String get catFashion => 'Fashion';

  @override
  String get catEverything => 'Everything';

  @override
  String get catApparel => 'Apparel';

  @override
  String get catGadgets => 'Gadgets';

  @override
  String get catTech => 'Tech';

  @override
  String get moreStores => 'More';

  @override
  String get twentyPlusStores => '10+ stores';

  @override
  String get sheinInsideHeama => 'Shein, shown inside HMH KARGO';

  @override
  String get openRealSite => 'Open real shein.com';

  @override
  String get searchShein => 'Search Shein…';

  @override
  String get catAll => 'All';

  @override
  String get catTops => 'Tops';

  @override
  String get catDresses => 'Dresses';

  @override
  String get catBottoms => 'Bottoms';

  @override
  String get catBags => 'Bags';

  @override
  String get catShoes => 'Shoes';

  @override
  String get popularNow => 'Popular now';

  @override
  String get viewOnSite => 'View on site';

  @override
  String get colour => 'Colour';

  @override
  String get size => 'Size';

  @override
  String get required => 'Required';

  @override
  String get deliveryToIraq => 'Delivery to Iraq';

  @override
  String get deliveryInfo =>
      'Arrives in 10–18 days via HMH KARGO warehouse · Duhok → your city in 24–48h';

  @override
  String get allInDinars => 'All-in, in dinars';

  @override
  String get allInPrice => 'All-in price';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get addToHeama => 'Add to HMH KARGO';

  @override
  String get captureSheetTitle => 'Add to your cart';

  @override
  String get captureCheckDetails => 'Check the details, then add.';

  @override
  String get priceOnSite => 'Price on site';

  @override
  String get productLink => 'Product link';

  @override
  String get fetchDetails => 'Fetch';

  @override
  String get optional => 'optional';

  @override
  String get itemNote => 'Note';

  @override
  String get itemNoteHint =>
      'Any requirement for this item — e.g. gift wrap, exact shade…';

  @override
  String get loginToAdd => 'Log in to add items to your cart.';

  @override
  String get quantity => 'Quantity';

  @override
  String get couldntCapture =>
      'Couldn\'t read this page automatically. Enter the details below.';

  @override
  String get detectedProduct =>
      'HMH KARGO detected this product · price in IQD';

  @override
  String get chooseColorAndSize => 'Please choose a colour and size first';

  @override
  String get chooseColorFirst => 'Please choose a colour first';

  @override
  String get chooseSizeFirst => 'Please choose a size first';

  @override
  String get savedToFav => 'Saved to favourites';

  @override
  String addedToCart(String variant) {
    return 'Added to cart · $variant';
  }

  @override
  String oneStorePerOrder(String store) {
    return 'Your cart has items from $store. Check out or empty it before adding from another store.';
  }

  @override
  String exclusiveOrder(String store) {
    return '$store must be ordered on its own. Check out or empty your cart before mixing stores.';
  }

  @override
  String reviewsCount(String count) {
    return '$count reviews';
  }

  @override
  String get soldCount => '5k+ sold';

  @override
  String get sale => 'Sale';

  @override
  String get colorLavender => 'Lavender';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorSage => 'Sage';

  @override
  String get colorSand => 'Sand';

  @override
  String get colorBlack => 'Black';

  @override
  String get savedItems => 'Saved items';

  @override
  String get savedSub => 'Tap the heart on any product to save it here.';

  @override
  String get noSavedTitle => 'No saved items yet';

  @override
  String get noSavedSub =>
      'Tap the heart on any product and it lands here, ready to add to your cart.';

  @override
  String get yourCart => 'Your cart';

  @override
  String get cartSub => 'Items captured from your stores';

  @override
  String get chooseVariantHint => 'Choose colour & size on the product page';

  @override
  String itemsCount(int count) {
    return 'Items ($count)';
  }

  @override
  String get shippingEst => 'Shipping to Iraq (est.)';

  @override
  String get serviceFee => 'HMH KARGO service fee';

  @override
  String get total => 'Total';

  @override
  String get continueToCheckout => 'Continue to checkout';

  @override
  String get checkout => 'Checkout';

  @override
  String totalToPay(String amount) {
    return 'Total to pay · $amount';
  }

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get change => 'Change';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String walletBalanceLine(String amount) {
    return 'Balance $amount · best discounts';
  }

  @override
  String get fastpay => 'FastPay / Zain Cash';

  @override
  String get fastpaySub => 'Pay from your mobile wallet';

  @override
  String get cashOnDelivery => 'Cash on delivery';

  @override
  String get cashOnDeliverySub => 'Pay in cash when your order arrives';

  @override
  String get toPayOnDelivery => 'To pay on delivery';

  @override
  String get paidByWallet => 'Paid by wallet';

  @override
  String get paidOnDelivery => 'Paid on delivery';

  @override
  String placeOrder(String amount) {
    return 'Place order · $amount';
  }

  @override
  String get orderPlaced => 'Order placed';

  @override
  String get yourOrders => 'Your orders';

  @override
  String get ordersSub => 'Track every package on its journey to Iraq.';

  @override
  String get ordersActive => 'Active';

  @override
  String get ordersArchive => 'Archive';

  @override
  String get ordersActiveEmpty => 'Your in-progress orders will appear here.';

  @override
  String get ordersArchiveEmpty =>
      'Delivered and closed orders will appear here.';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterCurrency => 'Currency';

  @override
  String get filterStore => 'Store';

  @override
  String get filterAll => 'All';

  @override
  String get filterTopUps => 'Top-ups';

  @override
  String get filterPayments => 'Payments';

  @override
  String get filterRefunds => 'Refunds';

  @override
  String walletLedgerTitle(String currency) {
    return '$currency Wallet';
  }

  @override
  String get inTransit => 'In transit';

  @override
  String get delivered => 'Delivered';

  @override
  String orderItemsPlaced(int count, String date) {
    return '$count items · placed $date';
  }

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get cancelOrderTitle => 'Cancel this order?';

  @override
  String get cancelOrderBody =>
      'You can cancel until we buy your items. Wallet payments are refunded to your wallet.';

  @override
  String get keepOrder => 'Keep order';

  @override
  String get orderCancelledToast => 'Order cancelled';

  @override
  String get refundedToWallet => 'Refunded to wallet';

  @override
  String get trackOrder => 'Track order';

  @override
  String get orderItems => 'Order items';

  @override
  String trackFromStores(int count) {
    return '$count items · from Shein & Temu';
  }

  @override
  String get arrives => 'Arrives';

  @override
  String get stepPlaced => 'Order placed';

  @override
  String get stepBuying => 'Buying your items';

  @override
  String get stepBought => 'Bought · Türkiye';

  @override
  String get stepZakhoOffice => 'At Zakho office';

  @override
  String get stepDelivery => 'Out for delivery';

  @override
  String get readyNowTitle => 'Ready now';

  @override
  String get readyNowSub => 'Already in Iraq — no shipping wait';

  @override
  String get readyShein => 'Shein · in stock';

  @override
  String get readyOther => 'Other stores · in stock';

  @override
  String get readyEmpty => 'Nothing in stock right now — check back soon.';

  @override
  String get stockAdded => 'Added to cart';

  @override
  String get stockSearchHint => 'Search name, size, colour…';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceLow => 'Price: low → high';

  @override
  String get sortPriceHigh => 'Price: high → low';

  @override
  String get stockNoResults => 'No items match your search.';

  @override
  String stockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String stepPlacedSub(String date, String amount) {
    return '$date · paid $amount';
  }

  @override
  String get stepPurchased => 'Purchased from store';

  @override
  String stepPurchasedSub(String date) {
    return '$date · HMH KARGO bought your items';
  }

  @override
  String get stepWarehouse => 'At warehouse · Türkiye';

  @override
  String stepWarehouseSub(String date) {
    return '$date · packed for Iraq';
  }

  @override
  String get stepTransit => 'In transit to Iraq';

  @override
  String get stepTransitSub => 'On the way to Duhok';

  @override
  String get currentStep => 'Current step';

  @override
  String get stepArrived => 'Arrived · Duhok office';

  @override
  String get stepArrivedSub => 'Ready for local delivery';

  @override
  String get stepOutForDelivery => 'Out for delivery · Erbil';

  @override
  String get stepOutForDeliverySub => 'To your door in 24–48h';

  @override
  String get contactSupport => 'Contact support';

  @override
  String memberSince(String city, String year) {
    return '$city · HMH KARGO member since $year';
  }

  @override
  String get walletBalanceLabel => 'Wallet balance';

  @override
  String get transactions => 'Transactions';

  @override
  String get topUpWith => 'Top up with';

  @override
  String get myOrders => 'My orders';

  @override
  String get addresses => 'Addresses';

  @override
  String get addAddress => 'Add address';

  @override
  String get editAddress => 'Edit address';

  @override
  String get governorate => 'Governorate';

  @override
  String get selectGovernorate => 'Select governorate';

  @override
  String get homeAddress => 'Home address';

  @override
  String get homeAddressHint => 'Neighbourhood, street, house/apartment…';

  @override
  String get otherCity => 'Other (type your city)';

  @override
  String get saveLabel => 'Save';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get setDefault => 'Set as default';

  @override
  String get defaultLabel => 'Default';

  @override
  String get noAddressesTitle => 'No addresses yet';

  @override
  String get noAddressesSub =>
      'Add a delivery address so we know where to bring your orders.';

  @override
  String get rewards => 'Rewards & points';

  @override
  String get languageMenu => 'Language';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'This permanently deletes your account and personal data (profile, addresses, cart, saved items). This can\'t be undone. Completed order records may be kept as required by law.';

  @override
  String get deleteAccountDone => 'Your account has been deleted.';

  @override
  String get deleteAccountError =>
      'Could not delete your account. Please try again.';

  @override
  String get fastpayShort => 'FastPay';

  @override
  String get zainCash => 'Zain Cash';

  @override
  String get cash => 'Cash';

  @override
  String get navHome => 'Home';

  @override
  String get navStores => 'Stores';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navMe => 'Me';

  @override
  String get cityErbil => 'Erbil';

  @override
  String get cityDuhok => 'Duhok';

  @override
  String get citySulaymaniyah => 'Sulaymaniyah';

  @override
  String get cityHalabja => 'Halabja';

  @override
  String get cityKirkuk => 'Kirkuk';

  @override
  String get cityMosul => 'Mosul';

  @override
  String get cityBaghdad => 'Baghdad';

  @override
  String get cityBasra => 'Basra';

  @override
  String get iqd => 'IQD';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageKurdish => 'کوردی';
}
