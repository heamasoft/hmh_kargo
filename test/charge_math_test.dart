import 'package:flutter_test/flutter_test.dart';
import 'package:hmh_kargo/utils/charge_math.dart';

void main() {
  // The live production settings when this was written.
  const live = ChargeMath(
    usdRate: 1350,
    tryRate: 28.4211,
    markupPercent: 0,
    roundingStepIqd: 250,
    roundingStepUsd: 0.5,
  );

  group('matches what the server actually charged', () {
    test(r'$5.70 Shein item → 7,750 IQD, as the capture sheet showed', () {
      // 5.70 × 1350 = 7,695 → rounded up to the next 250.
      expect(live.usdToIqd(5.70), 7750);
    });

    test('350 TL Trendyol item → \$7.50, as the server sample reported', () {
      // 350 × 28.4211 ÷ 1350 = 7.37 → rounded up to the next 0.50.
      expect(live.tryToUsd(350), 7.5);
    });

    test(r'$100 → 135,000 IQD (already on a step, not bumped)', () {
      expect(live.usdToIqd(100), 135000);
    });
  });

  test('rounds UP, never down', () {
    expect(live.usdToIqd(0.01), 250);
    expect(live.tryToIqd(100), 3000); // 2,842.11 → 3,000
  });

  test('applies the markup before rounding', () {
    const marked = ChargeMath(
      usdRate: 1000,
      tryRate: 30,
      markupPercent: 15,
      roundingStepIqd: 250,
      roundingStepUsd: 0.25,
    );
    expect(marked.usdToIqd(10), 11500); // 10,000 × 1.15
    expect(marked.usdToIqd(10.01), 11750); // 11,511.5 → 11,750
  });

  test('a missing rate yields 0, never a made-up figure', () {
    const none = ChargeMath(
      usdRate: 0,
      tryRate: 0,
      markupPercent: 0,
      roundingStepIqd: 250,
      roundingStepUsd: 0.5,
    );
    expect(none.hasUsd, isFalse);
    expect(none.usdToIqd(100), 0);
    expect(none.tryToUsd(100), 0);
  });

  group('lira → dollar card', () {
    test('uses the settings rate: 100 TL at \$1 = 48 TL is \$2.08', () {
      const withSetting = ChargeMath(
        usdRate: 1350,
        tryRate: 28.4211,
        markupPercent: 0,
        roundingStepIqd: 250,
        roundingStepUsd: 0.5,
        usdTlRate: 48,
      );
      expect(withSetting.tlPerUsd, 48);
      expect(withSetting.tlToUsd(100), 2.08);
      expect(withSetting.tlToUsd(1699.99), 35.42);
    });

    test('lira → dinars through the dollar at the Turkish rates', () {
      const m = ChargeMath(
        usdRate: 1350,
        tryRate: 28.125,
        markupPercent: 0,
        roundingStepIqd: 250,
        roundingStepUsd: 0.5,
        usdTlRate: 48,
        usdIqdTurkish: 1550,
      );
      expect(m.iqdPerUsdTurkish, 1550);
      expect(m.tlToIqd(48), 1550); // 48 TL = $1 = 1,550 IQD
      expect(m.tlToIqd(100), 3229); // 100 / 48 × 1550 = 3,229.17
    });

    test('an older server without it falls back to the fx_rates cross rate', () {
      // 1350 / 28.4211 ≈ 47.5 TL per dollar.
      expect(live.tlPerUsd, closeTo(47.5, 0.01));
      expect(live.tlToUsd(100), 2.11);
    });
  });
}
