/// Pulls a product/cart link out of whatever the shopper pasted.
///
/// Share buttons rarely put a bare URL on the clipboard. Shein's cart share, for
/// example, hands over the whole recommendation message with the link welded to
/// the end of a sentence:
///
///     I found some great items at SHEIN!
///     These items in my shopping cart are great. I highly recommend them to
///     everyone!https://onelink.shein.com/53/62mt6oxwnib6?shc=2_RcZhescjU0S
///
/// Pasting that as-is fails validation, so every paste field runs it through
/// [firstUrlIn] first.
library;

/// Stops at whitespace and at the characters that can't appear in a URL, so the
/// link is found even when it starts mid-sentence with no separator.
final _urlPattern = RegExp(
  r'https?://[^\s<>"' "'" r'\x00-\x1f]+',
  caseSensitive: false,
);

/// Trailing punctuation belongs to the sentence, not the link — but only when
/// it is unbalanced, so a URL that genuinely ends in `)` survives.
final _trailingJunk = RegExp(r'''[.,;:!?'"»”\]}]+$''');

/// The first `http(s)` URL in [text], or null when there isn't one.
String? firstUrlIn(String text) {
  final match = _urlPattern.firstMatch(text);
  if (match == null) return null;

  var url = match.group(0)!.replaceFirst(_trailingJunk, '');
  // A closing bracket only counts as junk when nothing opened it.
  while (url.endsWith(')') && !url.contains('(')) {
    url = url.substring(0, url.length - 1);
  }

  return url.isEmpty ? null : url;
}

/// The link to actually use from a paste: the embedded URL when there is one,
/// otherwise the trimmed text (which the caller may still prefix with a scheme).
String linkFromPaste(String text) => firstUrlIn(text) ?? text.trim();
