// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appName => 'HMH KARGO';

  @override
  String get welcomeTitleLine1 => 'لە جیهانەوە بکڕە،';

  @override
  String get welcomeTitleLine2 => 'بۆ عێراق دەگەیەنرێت.';

  @override
  String get welcomeSubtitle =>
      'لە شیعین و تیمو و زارا و زیاتر داوا بکە — نرخەکان بە دیناری، دەگاتە بەردەم دەرگاکەت لە هەولێر و دهۆک و زیاتر.';

  @override
  String get createAccount => 'هەژمار دروست بکە';

  @override
  String get haveAccount => 'پێشتر هەژمارم هەیە';

  @override
  String get browseAsGuest => 'وەک میوان بگەڕێ';

  @override
  String get regNameTitle => 'ناوت چییە؟';

  @override
  String get regNameStep =>
      'هەنگاوی ١ لە ٤ · بەم شێوەیە لە کاتی گەیاندندا بانگت دەکەین.';

  @override
  String get fullName => 'ناوی تەواو';

  @override
  String get fullNameHint => 'بۆ نموونە: ئالان حەسەن';

  @override
  String get errName => 'تکایە ناوی تەواوت بنووسە.';

  @override
  String get continueLabel => 'بەردەوامبوون';

  @override
  String get alreadyHaveAccount => 'پێشتر هەژمارت هەیە؟';

  @override
  String get login => 'چوونەژوورەوە';

  @override
  String get regCityTitle => 'بۆ کوێ بگەیەنین؟';

  @override
  String get regCityStep =>
      'هەنگاوی ٢ لە ٤ · شارەکەت و ژمارەیەکی مۆبایل کە بتوانین پشتڕاستی بکەینەوە.';

  @override
  String get city => 'شار';

  @override
  String get selectCity => 'شارەکەت هەڵبژێرە…';

  @override
  String get phoneNumber => 'ژمارەی مۆبایل';

  @override
  String get phoneHint => '750 123 4567';

  @override
  String get errCity => 'تکایە شارەکەت هەڵبژێرە.';

  @override
  String get errPhone => 'تکایە ژمارەیەکی دروست بنووسە.';

  @override
  String get sendCode => 'ناردنی کۆدی پشتڕاستکردنەوە';

  @override
  String get regOtpTitle => 'ژمارەکەت پشتڕاست بکەرەوە';

  @override
  String regOtpStep(String phone) {
    return 'هەنگاوی ٣ لە ٤ · ئەو کۆدە چوار ژمارەییە بنووسە کە ناردمان بۆ $phone';
  }

  @override
  String get errOtp => 'کۆدەکە هەڵەیە. تکایە بیپشکنە و دووبارە هەوڵ بدەرەوە.';

  @override
  String get demoHint => 'کۆدەکە بۆ واتساپەکەت نێردرا.';

  @override
  String get didntGetIt => 'کۆدەکەت پێنەگەیشت؟';

  @override
  String get resendCode => 'دووبارە ناردنەوەی کۆد';

  @override
  String get codeResent => 'کۆد دووبارە نێردرا';

  @override
  String get verify => 'پشتڕاستکردنەوە';

  @override
  String get regPwTitle => 'وشەی نهێنی دروست بکە';

  @override
  String get regPwStep => 'هەنگاوی ٤ لە ٤ · هەژمارەکەت بپارێزە.';

  @override
  String get regPwOptionalSub =>
      'ئارەزوومەندانە · وشەیەکی نهێنی زیاد بکە بۆ چوونەژوورەوە بەبێ کۆد.';

  @override
  String get skipForNow => 'ئێستا تێپەڕاندن';

  @override
  String get usePassword => 'چوونەژوورەوە بە وشەی نهێنی';

  @override
  String get useCode => 'لەبری ئەوە بە کۆد بچۆ ژوورەوە';

  @override
  String get forgotPassword => 'وشەی نهێنیت لەبیرچووە؟';

  @override
  String get resetTitle => 'ڕێکخستنەوەی وشەی نهێنی';

  @override
  String get resetSub =>
      'ژمارەی مۆبایلەکەت بنووسە و کۆدێکی پشتڕاستکردنەوەت بۆ دەنێرین.';

  @override
  String get newPwTitle => 'وشەی نهێنی نوێ دابنێ';

  @override
  String get newPwSub => 'وشەیەکی نهێنی نوێ بۆ هەژمارەکەت هەڵبژێرە.';

  @override
  String get savePassword => 'پاشەکەوتکردنی وشەی نهێنی';

  @override
  String get passwordUpdated => 'وشەی نهێنی نوێکرایەوە — تکایە بچۆ ژوورەوە';

  @override
  String get notRegistered =>
      'ئەم ژمارەیە هێشتا تۆمار نەکراوە. هەژمارێک دروست بکە بۆ دەستپێکردن.';

  @override
  String get accountTitle => 'هەژمار';

  @override
  String get accountSubtitle => 'بەڕێوەبردنی پرۆفایل و پاراستن';

  @override
  String get profileSection => 'پرۆفایل';

  @override
  String get changePassword => 'گۆڕینی وشەی نهێنی';

  @override
  String get saveChanges => 'پاشەکەوتکردنی گۆڕانکارییەکان';

  @override
  String get profileUpdated => 'پرۆفایل نوێکرایەوە';

  @override
  String get phoneLocked => 'ناتوانرێت ژمارەی مۆبایلەکەت بگۆڕدرێت.';

  @override
  String get password => 'وشەی نهێنی';

  @override
  String get passwordHint => 'لانیکەم ٦ پیت';

  @override
  String get confirmPassword => 'دووبارەکردنەوەی وشەی نهێنی';

  @override
  String get confirmPasswordHint => 'وشەی نهێنی دووبارە بنووسە';

  @override
  String get errPw => 'وشە نهێنییەکان دەبێت وەک یەک بن و لانیکەم ٦ پیت بن.';

  @override
  String get regDoneTitle => 'هەموو شت ئامادەیە!';

  @override
  String regDoneTitleNamed(String name) {
    return 'هەموو شت ئامادەیە، $name!';
  }

  @override
  String get regDoneSub =>
      'هەژماری HMH KARGO ئامادەیە. با شتێکی جوانت بۆ بدۆزینەوە.';

  @override
  String get enterHeama => 'بچۆ ناو HMH KARGO';

  @override
  String get welcomeBack => 'بەخێربێیتەوە';

  @override
  String get loginSub => 'بچۆ ژوورەوە بۆ هەژماری HMH KARGO.';

  @override
  String get yourPassword => 'وشەی نهێنیت';

  @override
  String get newToHeama => 'نوێیت لە HMH KARGO؟';

  @override
  String get heamaWallet => 'جزدانی HMH KARGO';

  @override
  String get topUp => 'پڕکردنەوە';

  @override
  String get topUpTitle => 'زیادکردنی پارە بۆ جزدان';

  @override
  String get topUpIntro =>
      'جزدانی HMH KARGO بە یەکێک لەم دوو ڕێگایە پڕ بکەرەوە:';

  @override
  String get topUpFibTitle => 'گواستنەوە لە ڕێگەی FIB';

  @override
  String get topUpFibBody =>
      'بڕەکە بۆمان بنێرە لە ڕێگەی ئەپی FIB (یەکەم بانکی عێراقی)، پاشان پسوڵەکە بە واتساپ بۆمان بنێرە بۆ پشتڕاستکردنەوە.';

  @override
  String get topUpContactTitle => 'پەیوەندیمان پێوە بکە بۆ پڕکردنەوە';

  @override
  String get topUpCashTitle => 'پڕکردنەوە بە کاش';

  @override
  String get topUpContactBody =>
      'لە ڕێگەی واتساپ نامەمان بۆ بنێرە یان پەیوەندیمان پێوە بکە، ئێمە بڕەکە زیاد دەکەین بۆ جزدانەکەت:';

  @override
  String get actionWhatsapp => 'واتساپ';

  @override
  String get actionCall => 'پەیوەندی';

  @override
  String get exchange => 'گۆڕین';

  @override
  String get exchangeAmount => 'بڕ';

  @override
  String get exchangeReceive => 'وەردەگریت';

  @override
  String get exchangeCta => 'گۆڕین ئێستا';

  @override
  String exchangeRateLine(String rate) {
    return '١ دۆلار = $rate دینار';
  }

  @override
  String get exchangeDone => 'گۆڕین تەواوبوو';

  @override
  String get exchangeEnterAmount => 'بڕێک بنووسە بۆ گۆڕین';

  @override
  String get approvalsTitle => 'ڕەزامەندییەکانی گەیاندن';

  @override
  String approvalsBanner(int count) {
    return '$count نوێکردنەوەی گەیاندن پێویستی بە ڕەزامەندیتە';
  }

  @override
  String get approvalsBannerAction => 'ئێستا بیبینە';

  @override
  String get approvalOldShipping => 'گەیاندنی پێشوو';

  @override
  String get approvalNewShipping => 'گەیاندنی نوێ';

  @override
  String get approvalNewTotal => 'کۆی نوێ';

  @override
  String get approvalAccept => 'ڕازیم';

  @override
  String get approvalReject => 'ڕەتکردنەوە';

  @override
  String get approvalAcceptedMsg => 'ڕازیبوون — ئێستا کاڵاکەت دەکڕین.';

  @override
  String get approvalRejectedMsg =>
      'ڕەتکرایەوە — کاڵاکە لە داواکارییەکەت لابرا و پارەکە گەڕایەوە بۆ جزدانەکەت.';

  @override
  String get approvalsEmpty => 'هیچ ڕەزامەندییەکی گەیاندنی چاوەڕوان نییە.';

  @override
  String get itemShipping => 'گەیاندن';

  @override
  String get cancelItemAction => 'هەڵوەشاندنەوەی کاڵا';

  @override
  String get cancelItemConfirm =>
      'ئەم کاڵایە هەڵبوەشێنرێتەوە؟ نرخ و گەیاندنەکەی دەگەڕێتەوە بۆ جزدانەکەت.';

  @override
  String get itemCancelledMsg =>
      'کاڵاکە هەڵوەشێنرایەوە — پارەکە گەڕایەوە بۆ جزدانەکەت.';

  @override
  String get aboutTitle => 'دەربارەی HMH KARGO';

  @override
  String get aboutBody =>
      'HMH KARGO ڕێگەت پێدەدات لە فرۆشگا نێودەوڵەتییەکان بکڕیت — شیعین، ترێندیۆل، زارا، H&M و زیاتر — و داواکارییەکانت بگەیەنرێن بۆ عێراق. هەر فرۆشگایەک لەناو ئەپەکەدا بگەڕێ، بەرهەم زیاد بکە بۆ سەبەتەکەت بە نرخێکی گشتگیری ڕوون، لە جزدانەکەتەوە پارە بدە، و هەموو داواکارییەک بەدواداچوونی بۆ بکە لە کڕینەوە تا بەردەم دەرگات.';

  @override
  String get aboutHowTitle => 'چۆن کار دەکات';

  @override
  String get aboutHowBody =>
      'فرۆشگایەک بکەرەوە، بەرهەمێک بدۆزەرەوە، و دەست بنێ بە زیادکردن بۆ سەبەتە — ئێمە نرخی گشتگیر دەکەین (بەرهەم + گەیاندن + خزمەت). لە جزدانەکەتەوە پارە بدە، ئێمە دەیکڕین، بۆ عێراق دەیگەیەنین، و لە هەموو هەنگاوێکدا ئاگادارت دەکەینەوە.';

  @override
  String get developedBy => 'گەشەپێدراوە لەلایەن Heama Soft';

  @override
  String get footerVisit => 'کلیک لێرە بکە بۆ سەردان';

  @override
  String get footerContact => 'پەیوەندیمان پێوە بکە';

  @override
  String get searchProductsHint => 'بەدوای بەرهەم بگەڕێ یان بەستەرێک بلکێنە…';

  @override
  String get shopFavStores => 'لە دڵخوازترین فرۆشگاکانت بکڕە';

  @override
  String get seeAll => 'هەمووی ببینە';

  @override
  String get freeShippingTitle => 'شیعین بەخۆڕایی دەگەیەنرێت لەگەڵ ئێمە';

  @override
  String get freeShippingSub =>
      'هەر کاڵایەکی شیعین لە ڕێگەی ئەپەکەوە داوا بکە، ئێمە گەیاندن بۆ عێراق دەگرینە ئەستۆ.';

  @override
  String get shopNow => 'ئێستا بکڕە';

  @override
  String get trendingInIraq => 'بەناوبانگ لە عێراق';

  @override
  String trendingOn(String store) {
    return 'بەناوبانگ لە $store';
  }

  @override
  String get savedHeart => 'هەڵگیراوەکان';

  @override
  String get stores => 'فرۆشگاکان';

  @override
  String get storesSub =>
      'لە فرۆشگایەک بدە بۆ کردنەوەی لەناو HMH KARGO. تیرەکە ماڵپەڕە ڕاستەقینەکە دەکاتەوە.';

  @override
  String get searchStores => 'لە فرۆشگاکان بگەڕێ…';

  @override
  String get international => 'نێودەوڵەتی';

  @override
  String get turkiye => 'تورکیا';

  @override
  String get catFashion => 'مۆدە';

  @override
  String get catEverything => 'هەموو شت';

  @override
  String get catApparel => 'جلوبەرگ';

  @override
  String get catGadgets => 'ئامێرەکان';

  @override
  String get catTech => 'تەکنەلۆژیا';

  @override
  String get moreStores => 'زیاتر';

  @override
  String get twentyPlusStores => 'زیاتر لە ١٠ فرۆشگا';

  @override
  String get sheinInsideHeama => 'شیعین لەناو HMH KARGO';

  @override
  String get openRealSite => 'ماڵپەڕی ڕاستەقینەی shein.com بکەرەوە';

  @override
  String get searchShein => 'لە شیعین بگەڕێ…';

  @override
  String get catAll => 'هەموو';

  @override
  String get catTops => 'سەرەوەکان';

  @override
  String get catDresses => 'کراس';

  @override
  String get catBottoms => 'خوارەوەکان';

  @override
  String get catBags => 'جانتا';

  @override
  String get catShoes => 'پێڵاو';

  @override
  String get popularNow => 'ئێستا بەناوبانگ';

  @override
  String get viewOnSite => 'لەسەر ماڵپەڕ ببینە';

  @override
  String get colour => 'ڕەنگ';

  @override
  String get size => 'قەبارە';

  @override
  String get required => 'پێویستە';

  @override
  String get deliveryToIraq => 'گەیاندن بۆ عێراق';

  @override
  String get deliveryInfo =>
      'لە ماوەی ١٠–١٨ ڕۆژدا دەگات لە ڕێگەی کۆگای HMH KARGO · لە دهۆکەوە بۆ شارەکەت لە ٢٤–٤٨ کاتژمێردا';

  @override
  String get allInDinars => 'نرخی گشتی بە دیناری';

  @override
  String get allInPrice => 'نرخی گشتی';

  @override
  String get addToCart => 'زیادکردن بۆ سەبەتە';

  @override
  String get addToHeama => 'زیادکردن بۆ HMH KARGO';

  @override
  String get captureSheetTitle => 'زیادی بکە بۆ سەبەتەکەت';

  @override
  String get captureCheckDetails => 'وردەکارییەکان بپشکنە، پاشان زیادی بکە.';

  @override
  String get priceOnSite => 'نرخ لەسەر ماڵپەڕ';

  @override
  String get productLink => 'بەستەری بەرهەم';

  @override
  String get fetchDetails => 'هێنان';

  @override
  String get optional => 'ئارەزوومەندانە';

  @override
  String get itemNote => 'تێبینی';

  @override
  String get itemNoteHint =>
      'هەر پێداویستییەک بۆ ئەم کاڵایە — وەک لفاف دیاری یان ڕەنگی ورد…';

  @override
  String get loginToAdd => 'بچۆ ژوورەوە بۆ زیادکردنی بەرهەم بۆ سەبەتەکەت.';

  @override
  String get quantity => 'بڕ';

  @override
  String get couldntCapture =>
      'نەتوانرا پەڕەکە بە خۆکار بخوێنرێتەوە. وردەکارییەکان لە خوارەوە بنووسە.';

  @override
  String get detectedProduct =>
      'HMH KARGO ئەم بەرهەمەی دۆزییەوە · نرخ بە دیناری';

  @override
  String get chooseColorAndSize => 'تکایە سەرەتا ڕەنگ و قەبارە هەڵبژێرە';

  @override
  String get chooseColorFirst => 'تکایە سەرەتا ڕەنگ هەڵبژێرە';

  @override
  String get chooseSizeFirst => 'تکایە سەرەتا قەبارە هەڵبژێرە';

  @override
  String get savedToFav => 'زیادکرا بۆ دڵخوازەکان';

  @override
  String addedToCart(String variant) {
    return 'زیادکرا بۆ سەبەتە · $variant';
  }

  @override
  String oneStorePerOrder(String store) {
    return 'سەبەتەکەت کاڵای هەیە لە $store. پێش زیادکردن لە فرۆشگایەکی تر، داواکاری تەواو بکە یان سەبەتەکە بەتاڵ بکە.';
  }

  @override
  String exclusiveOrder(String store) {
    return '$store دەبێت بە تەنها داواکاری بکرێت. پێش تێکەڵکردنی فرۆشگاکان، داواکاری تەواو بکە یان سەبەتەکە بەتاڵ بکە.';
  }

  @override
  String reviewsCount(String count) {
    return '$count هەڵسەنگاندن';
  }

  @override
  String get soldCount => 'زیاتر لە ٥ هەزار فرۆشراوە';

  @override
  String get sale => 'داشکاندن';

  @override
  String get colorLavender => 'مۆری کاڵ';

  @override
  String get colorRose => 'پەمەیی';

  @override
  String get colorSage => 'سەوزی کاڵ';

  @override
  String get colorSand => 'خۆڵەمێشی';

  @override
  String get colorBlack => 'ڕەش';

  @override
  String get savedItems => 'بەرهەمە هەڵگیراوەکان';

  @override
  String get savedSub => 'لە دڵی هەر بەرهەمێک بدە بۆ هەڵگرتنی لێرە.';

  @override
  String get noSavedTitle => 'هێشتا هیچ بەرهەمێک هەڵنەگیراوە';

  @override
  String get noSavedSub =>
      'لە دڵی هەر بەرهەمێک بدە و لێرە دەردەکەوێت، ئامادە بۆ زیادکردن بۆ سەبەتەکەت.';

  @override
  String get yourCart => 'سەبەتەکەت';

  @override
  String get cartSub => 'بەرهەمەکان لە فرۆشگاکانتەوە';

  @override
  String get chooseVariantHint => 'لە پەڕەی بەرهەمدا ڕەنگ و قەبارە هەڵبژێرە';

  @override
  String itemsCount(int count) {
    return 'بەرهەمەکان ($count)';
  }

  @override
  String get shippingEst => 'گەیاندن بۆ عێراق (خەمڵێنراو)';

  @override
  String get serviceFee => 'کرێی خزمەتگوزاری HMH KARGO';

  @override
  String get total => 'کۆی گشتی';

  @override
  String get continueToCheckout => 'بەردەوامبوون بۆ پارەدان';

  @override
  String get checkout => 'پارەدان';

  @override
  String totalToPay(String amount) {
    return 'کۆی پارەدان · $amount';
  }

  @override
  String get deliverTo => 'گەیاندن بۆ';

  @override
  String get change => 'گۆڕین';

  @override
  String get paymentMethod => 'شێوازی پارەدان';

  @override
  String walletBalanceLine(String amount) {
    return 'باڵانس $amount · باشترین داشکاندن';
  }

  @override
  String get fastpay => 'فاست پەی / زەین کاش';

  @override
  String get fastpaySub => 'لە جزدانی مۆبایلەکەتەوە بدە';

  @override
  String get cashOnDelivery => 'پارەدان لە کاتی گەیاندن';

  @override
  String get cashOnDeliverySub => 'بە کاش بدە کاتێک داواکارییەکەت دەگات';

  @override
  String get toPayOnDelivery => 'بڕی پارە لە کاتی وەرگرتن';

  @override
  String get paidByWallet => 'لە جزدان پارەدراوە';

  @override
  String get paidOnDelivery => 'لە کاتی وەرگرتن پارەدراوە';

  @override
  String placeOrder(String amount) {
    return 'داواکاری بنێرە · $amount';
  }

  @override
  String get orderPlaced => 'داواکاری نێردرا';

  @override
  String get yourOrders => 'داواکارییەکانت';

  @override
  String get ordersSub => 'هەر پاکەتێک بەدواداچوون بکە لە گەشتەکەیدا بۆ عێراق.';

  @override
  String get ordersActive => 'چالاک';

  @override
  String get ordersArchive => 'ئەرشیف';

  @override
  String get ordersActiveEmpty =>
      'داواکارییە جێبەجێنەکراوەکانت لێرە دەردەکەون.';

  @override
  String get ordersArchiveEmpty =>
      'داواکارییە گەیەنراو و داخراوەکان لێرە دەردەکەون.';

  @override
  String get filterStatus => 'دۆخ';

  @override
  String get filterCurrency => 'دراو';

  @override
  String get filterStore => 'فرۆشگا';

  @override
  String get filterAll => 'هەموو';

  @override
  String get filterTopUps => 'پڕکردنەوەکان';

  @override
  String get filterPayments => 'پارەدانەکان';

  @override
  String get filterRefunds => 'گەڕاندنەوەکان';

  @override
  String walletLedgerTitle(String currency) {
    return 'جزدانی $currency';
  }

  @override
  String get inTransit => 'لە ڕێگەدایە';

  @override
  String get delivered => 'گەیەنرا';

  @override
  String orderItemsPlaced(int count, String date) {
    return '$count بەرهەم · لە $date';
  }

  @override
  String get statusCancelled => 'هەڵوەشێنراوە';

  @override
  String get cancelOrder => 'هەڵوەشاندنەوەی داواکاری';

  @override
  String get cancelOrderTitle => 'ئەم داواکارییە هەڵبوەشێنرێتەوە؟';

  @override
  String get cancelOrderBody =>
      'دەتوانیت هەڵیبوەشێنیتەوە پێش ئەوەی بەرهەمەکانت بکڕین. پارەی جزدان دەگەڕێتەوە بۆ جزدانەکەت.';

  @override
  String get keepOrder => 'داواکاری بهێڵەوە';

  @override
  String get orderCancelledToast => 'داواکاری هەڵوەشێنرایەوە';

  @override
  String get refundedToWallet => 'گەڕایەوە بۆ جزدان';

  @override
  String get trackOrder => 'بەدواداچوونی داواکاری';

  @override
  String get orderItems => 'کاڵاکانی داواکاری';

  @override
  String trackFromStores(int count) {
    return '$count بەرهەم · لە شیعین و تیمو';
  }

  @override
  String get arrives => 'دەگات';

  @override
  String get stepPlaced => 'داواکاری نێردرا';

  @override
  String get stepBuying => 'کڕینی کاڵاکانت';

  @override
  String get stepBought => 'کڕدرا · تورکیا';

  @override
  String get stepZakhoOffice => 'لە نووسینگەی زاخۆ';

  @override
  String get stepDelivery => 'لە گەیاندندایە';

  @override
  String get readyNowTitle => 'ئێستا بەردەستە';

  @override
  String get readyNowSub => 'لە عێراقدایە — بێ چاوەڕوانی گەیاندن';

  @override
  String get readyShein => 'شەین · لە کۆگا';

  @override
  String get readyOther => 'فرۆشگاکانی تر · لە کۆگا';

  @override
  String get readyEmpty =>
      'هیچ کاڵایەک لە کۆگا نییە ئێستا — دواتر سەیر بکەرەوە.';

  @override
  String get stockAdded => 'زیادکرا بۆ سەبەتە';

  @override
  String get stockSearchHint => 'گەڕان بە ناو، قەبارە، ڕەنگ…';

  @override
  String get sortLabel => 'ڕیزکردن';

  @override
  String get sortNewest => 'نوێترین';

  @override
  String get sortPriceLow => 'نرخ: کەمترین بۆ زۆرترین';

  @override
  String get sortPriceHigh => 'نرخ: زۆرترین بۆ کەمترین';

  @override
  String get stockNoResults => 'هیچ کاڵایەک لەگەڵ گەڕانەکەت ناگونجێت.';

  @override
  String stockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کاڵا',
      one: '١ کاڵا',
    );
    return '$_temp0';
  }

  @override
  String stepPlacedSub(String date, String amount) {
    return '$date · $amount درا';
  }

  @override
  String get stepPurchased => 'لە فرۆشگا کڕدرا';

  @override
  String stepPurchasedSub(String date) {
    return '$date · HMH KARGO بەرهەمەکانی کڕی';
  }

  @override
  String get stepWarehouse => 'لە کۆگا · تورکیا';

  @override
  String stepWarehouseSub(String date) {
    return '$date · بۆ عێراق پاکەتکرا';
  }

  @override
  String get stepTransit => 'لە ڕێگەدایە بۆ عێراق';

  @override
  String get stepTransitSub => 'لە ڕێگەدایە بۆ دهۆک';

  @override
  String get currentStep => 'هەنگاوی ئێستا';

  @override
  String get stepArrived => 'گەیشت · نووسینگەی دهۆک';

  @override
  String get stepArrivedSub => 'ئامادە بۆ گەیاندنی ناوخۆیی';

  @override
  String get stepOutForDelivery => 'چووە دەرەوە بۆ گەیاندن · هەولێر';

  @override
  String get stepOutForDeliverySub => 'بۆ بەردەم دەرگات لە ٢٤–٤٨ کاتژمێردا';

  @override
  String get contactSupport => 'پەیوەندی بە پشتگیری';

  @override
  String memberSince(String city, String year) {
    return '$city · ئەندامی HMH KARGO لە $yearەوە';
  }

  @override
  String get walletBalanceLabel => 'باڵانسی جزدان';

  @override
  String get transactions => 'مامەڵەکان';

  @override
  String get topUpWith => 'پڕکردنەوە بە';

  @override
  String get myOrders => 'داواکارییەکانم';

  @override
  String get addresses => 'ناونیشانەکان';

  @override
  String get addAddress => 'زیادکردنی ناونیشان';

  @override
  String get editAddress => 'دەستکاریی ناونیشان';

  @override
  String get governorate => 'پارێزگا';

  @override
  String get selectGovernorate => 'پارێزگا هەڵبژێرە';

  @override
  String get homeAddress => 'ناونیشانی ماڵ';

  @override
  String get homeAddressHint => 'گەڕەک، شەقام، ماڵ/شوقە…';

  @override
  String get otherCity => 'ئەوانی تر (شارەکەت بنووسە)';

  @override
  String get saveLabel => 'پاشەکەوتکردن';

  @override
  String get deleteLabel => 'سڕینەوە';

  @override
  String get setDefault => 'کردنی بە بنەڕەت';

  @override
  String get defaultLabel => 'بنەڕەت';

  @override
  String get noAddressesTitle => 'هێشتا ناونیشان نییە';

  @override
  String get noAddressesSub =>
      'ناونیشانی گەیاندن زیاد بکە تا بزانین داواکارییەکانت بۆ کوێ بگەیەنین.';

  @override
  String get rewards => 'خەڵات و خاڵەکان';

  @override
  String get languageMenu => 'زمان';

  @override
  String get logout => 'چوونەدەرەوە';

  @override
  String get logoutConfirm => 'دڵنیایت لە چوونەدەرەوە؟';

  @override
  String get fastpayShort => 'فاست پەی';

  @override
  String get zainCash => 'زەین کاش';

  @override
  String get cash => 'کاش';

  @override
  String get navHome => 'سەرەکی';

  @override
  String get navStores => 'فرۆشگاکان';

  @override
  String get navCart => 'سەبەتە';

  @override
  String get navOrders => 'داواکارییەکان';

  @override
  String get navMe => 'من';

  @override
  String get cityErbil => 'هەولێر';

  @override
  String get cityDuhok => 'دهۆک';

  @override
  String get citySulaymaniyah => 'سلێمانی';

  @override
  String get cityHalabja => 'هەڵەبجە';

  @override
  String get cityKirkuk => 'کەرکووک';

  @override
  String get cityMosul => 'مووسڵ';

  @override
  String get cityBaghdad => 'بەغدا';

  @override
  String get cityBasra => 'بەسرە';

  @override
  String get iqd => 'د.ع';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageKurdish => 'کوردی';
}
