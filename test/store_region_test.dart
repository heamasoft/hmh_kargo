import 'package:flutter_test/flutter_test.dart';
import 'package:hmh_kargo/utils/store_region.dart';

void main() {
  group('forceSheinRegion', () {
    test('prefixes a bare product path', () {
      expect(forceSheinRegion('https://m.shein.com/x-p-460998563-cat-1738.html'),
          'https://m.shein.com/ar-en/x-p-460998563-cat-1738.html');
    });

    test('replaces a different storefront', () {
      expect(forceSheinRegion('https://m.shein.com/us/x-p-1-cat-2.html'),
          'https://m.shein.com/ar-en/x-p-1-cat-2.html');
      expect(forceSheinRegion('https://m.shein.com/ar/x-p-1-cat-2.html'),
          'https://m.shein.com/ar-en/x-p-1-cat-2.html');
    });

    test('is idempotent once pinned', () {
      expect(forceSheinRegion('https://m.shein.com/ar-en/x-p-1-cat-2.html'), isNull);
      expect(forceSheinRegion('https://m.shein.com/ar-en/'), isNull);
    });

    test('pins the shared-cart page too — it prices by storefront as well', () {
      expect(
          forceSheinRegion('https://m.shein.com/cart/share/landing?shc=2_X&group_id=1'),
          'https://m.shein.com/ar-en/cart/share/landing?shc=2_X&group_id=1');
    });

    test('ignores other stores', () {
      expect(forceSheinRegion('https://www.trendyol.com/x-p-123'), isNull);
      expect(forceSheinRegion('not a url at all'), isNull);
    });

    test('keeps the query string', () {
      expect(forceSheinRegion('https://m.shein.com/x-p-1-cat-2.html?a=b'),
          'https://m.shein.com/ar-en/x-p-1-cat-2.html?a=b');
    });
  });

  group('sheinStartUrl', () {
    test('opens a shared cart on the UAE storefront in dollars', () {
      final u = Uri.parse(sheinStartUrl(
          'https://m.shein.com/cart/share/landing?shc=2_X&group_id=876247730&local_country=AE'));
      expect(u.path, '/ar-en/cart/share/landing');
      expect(u.queryParameters['currency'], 'USD');
      expect(u.queryParameters['countryCode'], 'AE');
      // The cart's own parameters survive untouched.
      expect(u.queryParameters['group_id'], '876247730');
      expect(u.queryParameters['shc'], '2_X');
    });

    test('overrides a currency the URL already asked for', () {
      final u = Uri.parse(sheinStartUrl('https://m.shein.com/ar-en/?currency=SAR'));
      expect(u.queryParameters['currency'], 'USD');
    });

    test('leaves other stores exactly as they were', () {
      const zara = 'https://www.zara.com/tr/tr/x-p05644320.html';
      expect(sheinStartUrl(zara), zara);
    });
  });

  test('share links are left alone for the server to resolve', () {
    // The home-screen paste opened the store on this link, and /ar-en/ got
    // inserted into it — the server then couldn't read the share.
    const share = 'https://onelink.shein.com/53/62plvuf5pgej?shc=2_Rcy2QwY8wwL';
    expect(forceSheinRegion(share), isNull);
    expect(sheinStartUrl(share), share);
    expect(forceSheinRegion('https://api-shein.shein.com/h5/sharejump/appjump?x=1'), isNull);
  });
}
