import 'package:dio/dio.dart';

/// Finds a basket shared from the Trendyol app.
///
/// Trendyol's "share basket" gives a `ty.gl` link that redirects through
/// Adjust and ends in an app hand-off; the web page it stands for is
/// `trendyol.com/sepetim?d=…`, where `d` lists every item as
/// `61:<product id>:<listing id>:<seller id>:<quantity>`, joined by `|`.
///
/// The link is followed here, on the phone, because Trendyol refuses the
/// server: a basket can only be read from where the shopper is.

/// The basket's `d` value, or null when [link] is not a shared basket.
Future<String?> trendyolBasketData(String link) async {
  final direct = basketDataIn(link);
  if (direct != null) return direct;
  if ((Uri.tryParse(link)?.host ?? '').toLowerCase() != 'ty.gl') return null;

  final dio = Dio(BaseOptions(
    followRedirects: false,
    validateStatus: (_) => true,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  var next = link;
  // One hop at a time: followed to the end, the link becomes an `intent://`
  // the HTTP client can't open — the web page is named on the way there.
  for (var hop = 0; hop < 4; hop++) {
    final location = (await dio.get<void>(next)).headers.value('location') ?? '';
    if (location.isEmpty) return null;
    final web = webPageInRedirect(location);
    if (web != null) return basketDataIn(web);
    if (!location.startsWith('http')) return null;
    next = location;
  }
  return null;
}

/// The trendyol.com page a redirect points at: the address itself, Adjust's
/// `adjust_redirect`, or an app intent's browser fallback.
String? webPageInRedirect(String location) {
  final uri = Uri.tryParse(location);
  if (uri != null && uri.host.toLowerCase().endsWith('trendyol.com')) return location;
  final adjust = uri?.queryParameters['adjust_redirect'];
  if (adjust != null && adjust.isNotEmpty) return adjust;
  final fallback = RegExp(r'S\.browser_fallback_url=([^;]+)').firstMatch(location);
  return fallback == null ? null : Uri.decodeComponent(fallback.group(1)!);
}

/// The `d` value of a `trendyol.com/sepetim` link, or null for any other page.
String? basketDataIn(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.host.toLowerCase().endsWith('trendyol.com')) return null;
  if (!uri.path.toLowerCase().startsWith('/sepetim')) return null;
  final d = uri.queryParameters['d'] ?? '';
  return d.contains(':') ? d : null;
}
