/// The app's copy of the server's PricingService::chargeUnit, so the Me page
/// can show — and calculate, per keystroke, without a round trip — exactly
/// what adding an item to the cart would charge.
///
/// The server's rule: convert via IQD as the bridge, add the markup, then round
/// UP to a clean step (250 dinars / half a dollar). It is NOT a flat rate — a
/// $5.70 Shein item is 7,695 dinars at the raw rate but charged 7,750 — which
/// is why this mirrors the formula instead of multiplying by one figure.
///
/// Every input comes from the server with the wallet, so a change to the
/// markup or rounding there is followed here without an app release.
library;

class ChargeMath {
  const ChargeMath({
    required this.usdRate,
    required this.tryRate,
    required this.markupPercent,
    required this.roundingStepIqd,
    required this.roundingStepUsd,
    this.usdTlRate = 0,
    this.usdIqdTurkish = 0,
  });

  /// Lira per 1 USD as the admin sets it (settings `fx_usd_tl_turkish`, e.g.
  /// 48). 0 = not sent — an older server — so [tlPerUsd] falls back to the
  /// rate implied by `fx_rates`.
  final num usdTlRate;

  /// Dinars per 1 USD for Turkish orders (settings `fx_usd_iqd_turkish`, e.g.
  /// 1550). 0 = not sent, then [iqdPerUsdTurkish] uses the general USD rate.
  final num usdIqdTurkish;

  num get iqdPerUsdTurkish => usdIqdTurkish > 0 ? usdIqdTurkish : usdRate;

  /// Lira → dinars through the dollar, at the Turkish rates, whole dinars.
  num tlToIqd(num lira) => tlPerUsd <= 0 ? 0 : (lira / tlPerUsd * iqdPerUsdTurkish).round();

  /// Lira per dollar: the settings rate, else the `fx_rates` cross rate.
  num get tlPerUsd => usdTlRate > 0
      ? usdTlRate
      : (tryRate > 0 && usdRate > 0 ? usdRate / tryRate : 0);

  bool get hasTlUsd => tlPerUsd > 0;

  /// Plain lira → dollars at [tlPerUsd], to the cent — the Me page's rate,
  /// not a cart charge (no markup or rounding step).
  num tlToUsd(num lira) => tlPerUsd <= 0 || lira <= 0 ? 0 : _cents(lira / tlPerUsd);

  /// IQD per 1 USD / per 1 TL, from `fx_rates`. 0 = not configured.
  final num usdRate;
  final num tryRate;

  final num markupPercent;
  final num roundingStepIqd;
  final num roundingStepUsd;

  bool get hasUsd => usdRate > 0;
  bool get hasTry => tryRate > 0;

  /// What a Shein item priced [dollars] is charged, in dinars.
  num usdToIqd(num dollars) => _charge(dollars * usdRate, roundingStepIqd, whole: true);

  /// The dinar equivalent of a Trendyol item priced [lira].
  num tryToIqd(num lira) => _charge(lira * tryRate, roundingStepIqd, whole: true);

  /// What a Trendyol item priced [lira] is actually charged — Trendyol is
  /// billed in dollars, bridged through IQD like the server does.
  num tryToUsd(num lira) =>
      usdRate <= 0 ? 0 : _charge(lira * tryRate / usdRate, roundingStepUsd, whole: false);

  /// Markup, then round UP to [step]. The tiny epsilon matches the server's, so
  /// an amount already on a step (10,250) isn't bumped by float noise.
  num _charge(num amount, num step, {required bool whole}) {
    if (amount <= 0) return 0;
    final withMarkup = amount * (1 + markupPercent / 100);
    if (step <= 0) return whole ? withMarkup.round() : _cents(withMarkup);
    final rounded = (withMarkup / step - 1e-9).ceil() * step;
    return whole ? rounded.round() : _cents(rounded);
  }

  static num _cents(num v) => (v * 100).round() / 100;
}
