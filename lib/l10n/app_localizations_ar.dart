// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'HMH KARGO';

  @override
  String get welcomeTitleLine1 => 'تسوّق من العالم كله،';

  @override
  String get welcomeTitleLine2 => 'ويصلك إلى العراق.';

  @override
  String get welcomeSubtitle =>
      'اطلب من شي إن وتيمو وزارا وغيرها — الأسعار بالدينار، ويصلك إلى بابك في أربيل ودهوك وما بعدها.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get haveAccount => 'لديّ حساب بالفعل';

  @override
  String get browseAsGuest => 'التصفّح كضيف';

  @override
  String get regNameTitle => 'ما اسمك؟';

  @override
  String get regNameStep => 'الخطوة 1 من 4 · هكذا سنخاطبك عند التوصيل.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameHint => 'مثال: آلان حسن';

  @override
  String get errName => 'الرجاء إدخال اسمك الكامل.';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get regCityTitle => 'إلى أين نوصّل؟';

  @override
  String get regCityStep =>
      'الخطوة 2 من 4 · مدينتك ورقم هاتف يمكننا التحقق منه.';

  @override
  String get city => 'المدينة';

  @override
  String get selectCity => 'اختر مدينتك…';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneHint => '750 123 4567';

  @override
  String get errCity => 'الرجاء اختيار مدينتك.';

  @override
  String get errPhone => 'الرجاء إدخال رقم هاتف صحيح.';

  @override
  String get sendCode => 'إرسال رمز التحقق';

  @override
  String get regOtpTitle => 'تحقّق من رقمك';

  @override
  String regOtpStep(String phone) {
    return 'الخطوة 3 من 4 · أدخل الرمز المكوّن من 4 أرقام الذي أرسلناه إلى $phone';
  }

  @override
  String get errOtp => 'الرمز غير صحيح. يرجى التحقق والمحاولة مرة أخرى.';

  @override
  String get demoHint => 'تم إرسال الرمز إلى واتساب الخاص بك.';

  @override
  String get didntGetIt => 'لم يصلك الرمز؟';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get codeResent => 'تم إعادة إرسال الرمز';

  @override
  String get verify => 'تحقّق';

  @override
  String get regPwTitle => 'أنشئ كلمة مرور';

  @override
  String get regPwStep => 'الخطوة 4 من 4 · حافظ على أمان حسابك.';

  @override
  String get regPwOptionalSub =>
      'اختياري · أضف كلمة مرور لتسجيل الدخول دون رمز.';

  @override
  String get skipForNow => 'تخطّي الآن';

  @override
  String get usePassword => 'تسجيل الدخول بكلمة المرور';

  @override
  String get useCode => 'تسجيل الدخول برمز بدلاً من ذلك';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetSub => 'أدخل رقم هاتفك وسنرسل لك رمز تحقّق.';

  @override
  String get newPwTitle => 'تعيين كلمة مرور جديدة';

  @override
  String get newPwSub => 'اختر كلمة مرور جديدة لحسابك.';

  @override
  String get savePassword => 'حفظ كلمة المرور';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور — سجّل الدخول من فضلك';

  @override
  String get notRegistered => 'هذا الرقم غير مسجّل بعد. أنشئ حسابًا للبدء.';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get accountSubtitle => 'إدارة ملفك الشخصي والأمان';

  @override
  String get profileSection => 'الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get phoneLocked => 'لا يمكن تغيير رقم هاتفك.';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => '6 أحرف على الأقل';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get errPw => 'يجب أن تتطابق كلمتا المرور وألّا تقلّ عن 6 أحرف.';

  @override
  String get regDoneTitle => 'كل شيء جاهز!';

  @override
  String regDoneTitleNamed(String name) {
    return 'كل شيء جاهز يا $name!';
  }

  @override
  String get regDoneSub => 'حساب HMH KARGO جاهز. لنجد لك شيئًا جميلًا.';

  @override
  String get enterHeama => 'ادخل إلى HMH KARGO';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get loginSub => 'سجّل الدخول إلى حساب HMH KARGO.';

  @override
  String get yourPassword => 'كلمة مرورك';

  @override
  String get newToHeama => 'جديد على HMH KARGO؟';

  @override
  String get heamaWallet => 'محفظة HMH KARGO';

  @override
  String get topUp => 'شحن الرصيد';

  @override
  String get topUpTitle => 'إضافة رصيد إلى المحفظة';

  @override
  String get topUpIntro => 'اشحن محفظتك في HMH KARGO بإحدى الطريقتين:';

  @override
  String get topUpFibTitle => 'التحويل عبر FIB';

  @override
  String get topUpFibBody =>
      'حوّل المبلغ إلينا عبر تطبيق FIB (المصرف العراقي الأول)، ثم أرسل لنا الإيصال على واتساب لتأكيده.';

  @override
  String get topUpContactTitle => 'تواصل معنا للشحن';

  @override
  String get topUpCashTitle => 'الشحن نقداً';

  @override
  String get topUpContactBody =>
      'راسلنا أو اتصل بنا على واتساب وسنضيف الرصيد إلى محفظتك:';

  @override
  String get actionWhatsapp => 'واتساب';

  @override
  String get actionCall => 'اتصال';

  @override
  String get exchange => 'تحويل';

  @override
  String get exchangeAmount => 'المبلغ';

  @override
  String get exchangeReceive => 'ستستلم';

  @override
  String get exchangeCta => 'تحويل الآن';

  @override
  String exchangeRateLine(String rate) {
    return '1 دولار = $rate دينار';
  }

  @override
  String get exchangeDone => 'تم التحويل';

  @override
  String get exchangeEnterAmount => 'أدخل مبلغاً للتحويل';

  @override
  String get approvalsTitle => 'موافقات الشحن';

  @override
  String approvalsBanner(int count) {
    return '$count تحديث شحن بحاجة لموافقتك';
  }

  @override
  String get approvalsBannerAction => 'راجع الآن';

  @override
  String get approvalOldShipping => 'الشحن السابق';

  @override
  String get approvalNewShipping => 'الشحن الجديد';

  @override
  String get approvalNewTotal => 'الإجمالي الجديد';

  @override
  String get approvalAccept => 'موافق';

  @override
  String get approvalReject => 'رفض';

  @override
  String get approvalAcceptedMsg => 'تمت الموافقة — سنشتري المنتج الآن.';

  @override
  String get approvalRejectedMsg =>
      'تم الرفض — أُزيل المنتج من طلبك وأُعيد المبلغ إلى محفظتك.';

  @override
  String get approvalsEmpty => 'لا توجد موافقات شحن معلّقة.';

  @override
  String get itemShipping => 'الشحن';

  @override
  String get cancelItemAction => 'إلغاء المنتج';

  @override
  String get cancelItemConfirm =>
      'إلغاء هذا المنتج؟ سيُعاد سعره وشحنه إلى محفظتك.';

  @override
  String get itemCancelledMsg => 'تم إلغاء المنتج — أُعيد المبلغ إلى محفظتك.';

  @override
  String get aboutTitle => 'عن HMH KARGO';

  @override
  String get aboutBody =>
      'يتيح لك HMH KARGO التسوّق من المتاجر العالمية — شي إن، ترينديول، زارا، H&M وغيرها — وتوصيل طلباتك إلى العراق. تصفّح أي متجر داخل التطبيق، أضف المنتجات إلى سلتك بسعر شامل واضح، وادفع من محفظتك، وتابع كل طلب من الشراء حتى باب منزلك.';

  @override
  String get aboutHowTitle => 'كيف يعمل';

  @override
  String get aboutHowBody =>
      'افتح متجراً، اختر منتجاً، واضغط أضف إلى السلة — نحسب السعر شاملاً (المنتج + الشحن + الخدمة). ادفع من محفظتك، ونتكفّل بالشراء والشحن إلى العراق وإبقائك على اطلاع في كل خطوة.';

  @override
  String get developedBy => 'تم التطوير بواسطة Heama Soft';

  @override
  String get footerVisit => 'اضغط هنا للزيارة';

  @override
  String get footerContact => 'تواصل معنا';

  @override
  String get searchProductsHint => 'ابحث عن منتجات أو الصق رابطًا…';

  @override
  String get shopFavStores => 'تسوّق من متاجرك المفضّلة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get freeShippingTitle => 'شي إن يُشحن مجاناً معنا';

  @override
  String get freeShippingSub =>
      'اطلب أي منتج من شي إن عبر التطبيق، ونحن نتكفّل بالشحن إلى العراق.';

  @override
  String get shopNow => 'تسوّق الآن';

  @override
  String get trendingInIraq => 'الرائج في العراق';

  @override
  String trendingOn(String store) {
    return 'الرائج على $store';
  }

  @override
  String get savedHeart => 'المحفوظات';

  @override
  String get stores => 'المتاجر';

  @override
  String get storesSub =>
      'اضغط على متجر لفتحه داخل HMH KARGO. السهم يفتح الموقع الحقيقي.';

  @override
  String get searchStores => 'ابحث في المتاجر…';

  @override
  String get international => 'عالمية';

  @override
  String get turkiye => 'تركيا';

  @override
  String get catFashion => 'أزياء';

  @override
  String get catEverything => 'كل شيء';

  @override
  String get catApparel => 'ملابس';

  @override
  String get catGadgets => 'إلكترونيات';

  @override
  String get catTech => 'تقنية';

  @override
  String get moreStores => 'المزيد';

  @override
  String get twentyPlusStores => 'أكثر من 10 متاجر';

  @override
  String get sheinInsideHeama => 'شي إن داخل HMH KARGO';

  @override
  String get openRealSite => 'افتح موقع shein.com الحقيقي';

  @override
  String get searchShein => 'ابحث في شي إن…';

  @override
  String get catAll => 'الكل';

  @override
  String get catTops => 'بلايز';

  @override
  String get catDresses => 'فساتين';

  @override
  String get catBottoms => 'سراويل';

  @override
  String get catBags => 'حقائب';

  @override
  String get catShoes => 'أحذية';

  @override
  String get popularNow => 'الأكثر رواجًا الآن';

  @override
  String get viewOnSite => 'عرض على الموقع';

  @override
  String get colour => 'اللون';

  @override
  String get size => 'المقاس';

  @override
  String get required => 'مطلوب';

  @override
  String get deliveryToIraq => 'التوصيل إلى العراق';

  @override
  String get deliveryInfo =>
      'يصل خلال 10–18 يومًا عبر مستودع HMH KARGO · من دهوك إلى مدينتك خلال 24–48 ساعة';

  @override
  String get allInDinars => 'السعر الكلي بالدينار';

  @override
  String get allInPrice => 'السعر الكلي';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get addToHeama => 'أضف إلى HMH KARGO';

  @override
  String get captureSheetTitle => 'أضف إلى سلّتك';

  @override
  String get captureCheckDetails => 'تحقّق من التفاصيل ثم أضف.';

  @override
  String get priceOnSite => 'السعر على الموقع';

  @override
  String get productLink => 'رابط المنتج';

  @override
  String get fetchDetails => 'جلب';

  @override
  String get optional => 'اختياري';

  @override
  String get itemNote => 'ملاحظة';

  @override
  String get itemNoteHint =>
      'أي متطلّب لهذا المنتج — مثل تغليف هدية أو درجة لون محدّدة…';

  @override
  String get loginToAdd => 'سجّل الدخول لإضافة المنتجات إلى سلّتك.';

  @override
  String get quantity => 'الكمية';

  @override
  String get couldntCapture =>
      'تعذّر قراءة الصفحة تلقائيًا. أدخل التفاصيل أدناه.';

  @override
  String get detectedProduct => 'اكتشفت HMH KARGO هذا المنتج · السعر بالدينار';

  @override
  String get chooseColorAndSize => 'الرجاء اختيار اللون والمقاس أولًا';

  @override
  String get chooseColorFirst => 'الرجاء اختيار اللون أولًا';

  @override
  String get chooseSizeFirst => 'الرجاء اختيار المقاس أولًا';

  @override
  String get savedToFav => 'أُضيف إلى المفضّلة';

  @override
  String addedToCart(String variant) {
    return 'أُضيف إلى السلة · $variant';
  }

  @override
  String oneStorePerOrder(String store) {
    return 'سلتك تحتوي على منتجات من $store. أكمل الطلب أو أفرغ السلة قبل الإضافة من متجر آخر.';
  }

  @override
  String exclusiveOrder(String store) {
    return 'يجب طلب $store بمفرده. أكمل الطلب أو أفرغ سلتك قبل الخلط بين المتاجر.';
  }

  @override
  String reviewsCount(String count) {
    return '$count تقييم';
  }

  @override
  String get soldCount => 'أكثر من 5 آلاف عملية بيع';

  @override
  String get sale => 'تخفيض';

  @override
  String get colorLavender => 'بنفسجي فاتح';

  @override
  String get colorRose => 'وردي';

  @override
  String get colorSage => 'أخضر مريمي';

  @override
  String get colorSand => 'رملي';

  @override
  String get colorBlack => 'أسود';

  @override
  String get savedItems => 'العناصر المحفوظة';

  @override
  String get savedSub => 'اضغط على القلب في أي منتج لحفظه هنا.';

  @override
  String get noSavedTitle => 'لا توجد عناصر محفوظة بعد';

  @override
  String get noSavedSub =>
      'اضغط على القلب في أي منتج ليظهر هنا، جاهزًا للإضافة إلى سلّتك.';

  @override
  String get yourCart => 'سلّتك';

  @override
  String get cartSub => 'عناصر ملتقطة من متاجرك';

  @override
  String get chooseVariantHint => 'اختر اللون والمقاس في صفحة المنتج';

  @override
  String itemsCount(int count) {
    return 'العناصر ($count)';
  }

  @override
  String get shippingEst => 'الشحن إلى العراق (تقديري)';

  @override
  String get serviceFee => 'رسوم خدمة HMH KARGO';

  @override
  String get total => 'الإجمالي';

  @override
  String get continueToCheckout => 'متابعة إلى الدفع';

  @override
  String get checkout => 'الدفع';

  @override
  String totalToPay(String amount) {
    return 'الإجمالي المطلوب · $amount';
  }

  @override
  String get deliverTo => 'التوصيل إلى';

  @override
  String get change => 'تغيير';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String walletBalanceLine(String amount) {
    return 'الرصيد $amount · أفضل الخصومات';
  }

  @override
  String get fastpay => 'فاست باي / زين كاش';

  @override
  String get fastpaySub => 'ادفع من محفظتك على الهاتف';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get cashOnDeliverySub => 'ادفع نقداً عند وصول طلبك';

  @override
  String get toPayOnDelivery => 'مبلغ يُدفع عند الاستلام';

  @override
  String get paidByWallet => 'مدفوع من المحفظة';

  @override
  String get paidOnDelivery => 'مدفوع عند الاستلام';

  @override
  String placeOrder(String amount) {
    return 'تأكيد الطلب · $amount';
  }

  @override
  String get orderPlaced => 'تم تأكيد الطلب';

  @override
  String get yourOrders => 'طلباتك';

  @override
  String get ordersSub => 'تابع كل طردٍ في رحلته إلى العراق.';

  @override
  String get ordersActive => 'الجارية';

  @override
  String get ordersArchive => 'الأرشيف';

  @override
  String get ordersActiveEmpty => 'ستظهر هنا طلباتك قيد التنفيذ.';

  @override
  String get ordersArchiveEmpty => 'ستظهر هنا الطلبات المسلَّمة والمغلقة.';

  @override
  String get filterStatus => 'الحالة';

  @override
  String get filterCurrency => 'العملة';

  @override
  String get filterStore => 'المتجر';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterTopUps => 'الإيداعات';

  @override
  String get filterPayments => 'المدفوعات';

  @override
  String get filterRefunds => 'المبالغ المستردة';

  @override
  String walletLedgerTitle(String currency) {
    return 'محفظة $currency';
  }

  @override
  String get inTransit => 'قيد الشحن';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String orderItemsPlaced(int count, String date) {
    return '$count عناصر · بتاريخ $date';
  }

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get cancelOrderTitle => 'إلغاء هذا الطلب؟';

  @override
  String get cancelOrderBody =>
      'يمكنك الإلغاء قبل أن نشتري منتجاتك. تُعاد مدفوعات المحفظة إلى محفظتك.';

  @override
  String get keepOrder => 'الاحتفاظ بالطلب';

  @override
  String get orderCancelledToast => 'تم إلغاء الطلب';

  @override
  String get refundedToWallet => 'أُعيد إلى المحفظة';

  @override
  String get trackOrder => 'تتبّع الطلب';

  @override
  String get orderItems => 'منتجات الطلب';

  @override
  String trackFromStores(int count) {
    return '$count عناصر · من شي إن وتيمو';
  }

  @override
  String get arrives => 'يصل';

  @override
  String get stepPlaced => 'تم إنشاء الطلب';

  @override
  String get stepBuying => 'جارٍ شراء منتجاتك';

  @override
  String get stepBought => 'تم الشراء · تركيا';

  @override
  String get stepZakhoOffice => 'في مكتب زاخو';

  @override
  String get stepDelivery => 'قيد التوصيل';

  @override
  String get readyNowTitle => 'متوفر الآن';

  @override
  String get readyNowSub => 'موجود في العراق — بدون انتظار الشحن';

  @override
  String get readyShein => 'شي إن · متوفر';

  @override
  String get readyOther => 'متاجر أخرى · متوفر';

  @override
  String get readyEmpty => 'لا يوجد مخزون حالياً — تحقق لاحقاً.';

  @override
  String get stockAdded => 'أُضيف إلى السلة';

  @override
  String get stockSearchHint => 'ابحث بالاسم أو المقاس أو اللون…';

  @override
  String get sortLabel => 'ترتيب';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortPriceLow => 'السعر: من الأقل';

  @override
  String get sortPriceHigh => 'السعر: من الأعلى';

  @override
  String get stockNoResults => 'لا توجد عناصر تطابق بحثك.';

  @override
  String stockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر',
      one: 'عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String stepPlacedSub(String date, String amount) {
    return '$date · دُفع $amount';
  }

  @override
  String get stepPurchased => 'تم الشراء من المتجر';

  @override
  String stepPurchasedSub(String date) {
    return '$date · اشترت HMH KARGO عناصرك';
  }

  @override
  String get stepWarehouse => 'في المستودع · تركيا';

  @override
  String stepWarehouseSub(String date) {
    return '$date · جُهّز للعراق';
  }

  @override
  String get stepTransit => 'قيد الشحن إلى العراق';

  @override
  String get stepTransitSub => 'في الطريق إلى دهوك';

  @override
  String get currentStep => 'الخطوة الحالية';

  @override
  String get stepArrived => 'وصل · مكتب دهوك';

  @override
  String get stepArrivedSub => 'جاهز للتوصيل المحلي';

  @override
  String get stepOutForDelivery => 'خرج للتوصيل · أربيل';

  @override
  String get stepOutForDeliverySub => 'إلى بابك خلال 24–48 ساعة';

  @override
  String get contactSupport => 'تواصل مع الدعم';

  @override
  String memberSince(String city, String year) {
    return '$city · عضو في HMH KARGO منذ $year';
  }

  @override
  String get walletBalanceLabel => 'رصيد المحفظة';

  @override
  String get transactions => 'المعاملات';

  @override
  String get topUpWith => 'اشحن عبر';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get addresses => 'العناوين';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get editAddress => 'تعديل العنوان';

  @override
  String get governorate => 'المحافظة';

  @override
  String get selectGovernorate => 'اختر المحافظة';

  @override
  String get homeAddress => 'عنوان المنزل';

  @override
  String get homeAddressHint => 'الحي، الشارع، المنزل/الشقة…';

  @override
  String get otherCity => 'أخرى (اكتب مدينتك)';

  @override
  String get saveLabel => 'حفظ';

  @override
  String get deleteLabel => 'حذف';

  @override
  String get setDefault => 'تعيين كافتراضي';

  @override
  String get defaultLabel => 'افتراضي';

  @override
  String get noAddressesTitle => 'لا توجد عناوين بعد';

  @override
  String get noAddressesSub => 'أضف عنوان توصيل لنعرف أين نوصّل طلباتك.';

  @override
  String get rewards => 'المكافآت والنقاط';

  @override
  String get languageMenu => 'اللغة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get fastpayShort => 'فاست باي';

  @override
  String get zainCash => 'زين كاش';

  @override
  String get cash => 'نقدًا';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navStores => 'المتاجر';

  @override
  String get navCart => 'السلة';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navMe => 'حسابي';

  @override
  String get cityErbil => 'أربيل';

  @override
  String get cityDuhok => 'دهوك';

  @override
  String get citySulaymaniyah => 'السليمانية';

  @override
  String get cityHalabja => 'حلبجة';

  @override
  String get cityKirkuk => 'كركوك';

  @override
  String get cityMosul => 'الموصل';

  @override
  String get cityBaghdad => 'بغداد';

  @override
  String get cityBasra => 'البصرة';

  @override
  String get iqd => 'د.ع';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageKurdish => 'کوردی';
}
