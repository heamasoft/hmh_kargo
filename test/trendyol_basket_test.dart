import 'package:flutter_test/flutter_test.dart';
import 'package:hmh_kargo/utils/trendyol_basket.dart';

void main() {
  // Trimmed from a real `ty.gl` share: the Adjust hop names the web page in
  // `adjust_redirect`, the next hop in an intent's browser fallback.
  const d = '61%253A958951908%253A531c22dadcc6b13a27475cbb3973d798%253A612%253A3';
  const adjust = 'https://p8zh.adj.st/x?Page=ReceiveBasket'
      '&adjust_redirect=https%3A%2F%2Fwww.trendyol.com%2Fsepetim%3Fd%3D$d%26source%3Dshare_basket';
  const intent = 'intent://?Page=ReceiveBasket#Intent;scheme=ty;package=trendyol.com;'
      'S.browser_fallback_url=https%3A%2F%2Fwww.trendyol.com%2Fsepetim%3Fd%3D$d;end';

  test('the basket page is found in either redirect', () {
    for (final location in [adjust, intent]) {
      final web = webPageInRedirect(location)!;
      expect(basketDataIn(web), '61:958951908:531c22dadcc6b13a27475cbb3973d798:612:3');
    }
  });

  test('only a basket page counts as a basket', () {
    expect(basketDataIn('https://www.trendyol.com/x/x-p-958951908'), isNull);
    expect(basketDataIn('https://www.trendyol.com/koleksiyonlar/abc'), isNull);
    expect(basketDataIn('https://www.trendyol.com/sepetim'), isNull);
    expect(basketDataIn('https://example.com/sepetim?d=61:1:a:2:1'), isNull);
  });
}
