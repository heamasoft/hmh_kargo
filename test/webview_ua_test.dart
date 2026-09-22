import 'package:flutter_test/flutter_test.dart';
import 'package:hmh_kargo/utils/webview_ua.dart';

void main() {
  test("the iPhone's own agent is completed to Safari's, at its real iOS version", () {
    const wk = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';
    expect(
      iosSafariUa(wk),
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1',
    );
  });

  test('an agent that is already Safari-shaped is kept as it is', () {
    const safari = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1';
    expect(iosSafariUa(safari), safari);
  });

  test('nothing readable → keep the WebView default', () {
    expect(iosSafariUa(null), isNull);
    expect(iosSafariUa('garbage'), isNull);
  });
}
