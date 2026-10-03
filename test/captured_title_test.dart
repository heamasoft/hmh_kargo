import 'package:flutter_test/flutter_test.dart';

import 'package:hmh_kargo/models/captured_product.dart';

void main() {
  group('a product title that has to fit', () {
    test('an ordinary title is left exactly as the store wrote it', () {
      const title = 'MAANGE 7pcs Dual-Ended Multi-Function Makeup Brush Set';
      expect(cappedTitle(title), title);
    });

    test('a title too long to store is cut on a word', () {
      // Shein names some products by listing every variant in the title.
      final long = List.filled(60, 'Dual-Ended Multi-Function Brush').join(' ');
      final capped = cappedTitle(long);

      expect(capped.length, lessThanOrEqualTo(255));
      expect(capped.endsWith(' '), isFalse);
      // Cut between words, so the name does not end mid-syllable.
      expect(long.startsWith(capped), isTrue);
      expect(long[capped.length], ' ');
    });

    test('a long title with nothing to cut on is simply cut', () {
      final run = 'x' * 400;
      expect(cappedTitle(run).length, 255);
    });

    test('surrounding space is not counted against it', () {
      expect(cappedTitle('   A brush set   '), 'A brush set');
    });
  });
}
