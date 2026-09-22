import 'package:flutter_test/flutter_test.dart';
import 'package:hmh_kargo/utils/link_text.dart';

void main() {
  test('pulls the link out of a Shein cart share message', () {
    const pasted = 'I found some great items at SHEIN!\n'
        'These items in my shopping cart are great. I highly recommend them to '
        'everyone!https://onelink.shein.com/53/62mt6oxwnib6?shc=2_RcZhescjU0S';
    expect(firstUrlIn(pasted),
        'https://onelink.shein.com/53/62mt6oxwnib6?shc=2_RcZhescjU0S');
  });

  test('keeps a bare link untouched', () {
    const bare = 'https://onelink.shein.com/53/62mt6oxwnib6?shc=2_RcZhescjU0S';
    expect(firstUrlIn(bare), bare);
  });

  test('trims sentence punctuation but keeps query values', () {
    expect(firstUrlIn('see https://www.shein.com/x-p-123-cat-7.html.'),
        'https://www.shein.com/x-p-123-cat-7.html');
    expect(firstUrlIn('go to https://m.shein.com/a?b=1_Cd, now'),
        'https://m.shein.com/a?b=1_Cd');
  });

  test('falls back to the trimmed text when there is no url', () {
    expect(firstUrlIn('just words'), isNull);
    expect(linkFromPaste('  www.shein.com/x  '), 'www.shein.com/x');
  });
}
