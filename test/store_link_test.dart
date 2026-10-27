import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';

import 'package:hmh_kargo/models/store.dart';
import 'package:hmh_kargo/utils/store_link.dart';

Store _store(String key, String url) => Store(
      id: key,
      storeId: 1,
      name: key,
      glyph: key.substring(0, 2).toUpperCase(),
      glyphColor: Colors.black,
      categoryKey: 'catFashion',
      url: url,
      region: 'international',
      currency: 'USD',
    );

final _stores = [
  _store('shein', 'https://m.shein.com/'),
  _store('trendyol', 'https://www.trendyol.com'),
  _store('zara', 'https://www.zara.com/tr/tr/'),
];

void main() {
  group('the company a host belongs to', () {
    test('drops whatever subdomain the storefront happens to use', () {
      expect(registrableDomain('m.shein.com'), 'shein.com');
      expect(registrableDomain('www.trendyol.com'), 'trendyol.com');
      expect(registrableDomain('ar.shein.com'), 'shein.com');
    });

    test('keeps a country second level whole', () {
      expect(registrableDomain('www.zara.com.tr'), 'zara.com.tr');
      expect(registrableDomain('shop.example.co.uk'), 'example.co.uk');
    });
  });

  group('naming a shop we do not carry', () {
    test('reads the name off its own address', () {
      expect(storeNameFromLink('https://www.hepsiburada.com/a-b-c-p-1'), 'Hepsiburada');
      expect(storeNameFromLink('https://www.lcwaikiki.com/tr-TR/TR'), 'Lcwaikiki');
    });

    test('a hyphenated name reads as words', () {
      expect(storeNameFromLink('https://shop-name.com/item'), 'Shop Name');
    });

    test('nothing to go on gives nothing', () {
      expect(storeNameFromLink('not a link'), '');
      expect(storeNameFromLink(''), '');
    });
  });

  group('the store a pasted link belongs to', () {
    test('finds the store however the link names it', () {
      expect(storeForLink('https://m.shein.com/ar-en/a-dress-p-123456.html', _stores)?.id, 'shein');
      expect(storeForLink('https://www.trendyol.com/x/y-p-286870891', _stores)?.id, 'trendyol');
    });

    test('follows the short links the stores\' own apps share', () {
      // Trendyol's app shortens to ty.gl; Shein's shares through onelink.
      expect(storeForLink('https://ty.gl/abc123', _stores)?.id, 'trendyol');
      expect(storeForLink('https://onelink.shein.com/53/62mt6oxwnib6', _stores)?.id, 'shein');
    });

    test('a shop we do not carry is nobody\'s — it is added by hand', () {
      expect(storeForLink('https://www.amazon.com/dp/B0000', _stores), isNull);
      expect(storeForLink('not a link at all', _stores), isNull);
      expect(storeForLink('', _stores), isNull);
    });

    test('zara is matched though its address carries a path', () {
      expect(storeForLink('https://www.zara.com/tr/tr/coat-p05644320.html', _stores)?.id, 'zara');
    });
  });

  group('isSharedCartLink', () {
    test('a cart, collection or basket page goes to the import', () {
      expect(isSharedCartLink('https://m.shein.com/ar-en/cart/share/landing?shc=2_RN&group_id=9'), isTrue);
      expect(isSharedCartLink('https://www.trendyol.com/koleksiyonlar/yaz-abc'), isTrue);
      expect(isSharedCartLink('https://www.trendyol.com/sepetim?d=61:958951908:531c:612:3'), isTrue);
    });

    test('a product, a plain basket or a short app link does not', () {
      expect(isSharedCartLink('https://m.shein.com/ar-en/Dress-p-12345.html'), isFalse);
      expect(isSharedCartLink('https://www.trendyol.com/x/x-p-958951908'), isFalse);
      expect(isSharedCartLink('https://www.trendyol.com/sepetim'), isFalse);
      expect(isSharedCartLink('https://ty.gl/ptv7h8933sh8f'), isFalse);
      expect(isSharedCartLink('https://onelink.shein.com/57/65rqad'), isFalse);
    });
  });
}
