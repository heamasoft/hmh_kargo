import '../models/store.dart';

/// Which store a pasted link belongs to.
///
/// One rule, used by every paste field in the app — the Home header, the cart's
/// add-by-link sheet — so the same link always lands in the same place.

/// The part of a host that names the company: "m.shein.com" → "shein.com",
/// "www.trendyol.com" → "trendyol.com". A country second level is kept whole,
/// so "www.zara.com.tr" stays "zara.com.tr" rather than collapsing to "com.tr".
String registrableDomain(String host) {
  final parts = host.toLowerCase().split('.').where((p) => p.isNotEmpty).toList();
  if (parts.length < 2) return host.toLowerCase();
  final second = parts[parts.length - 2];
  final keep = parts.length >= 3 && const ['com', 'co', 'org', 'net'].contains(second) ? 3 : 2;
  return parts.sublist(parts.length - keep).join('.');
}

/// Hosts the stores share links through, which carry no name of their own.
/// A shopper sharing from the Shein app gets an `onelink.shein.com` link;
/// Trendyol's app shortens to `ty.gl`.
const _shareHostStore = <String, String>{
  'ty.gl': 'trendyol.com',
  'onelink.shein.com': 'shein.com',
  'app.shein.com': 'shein.com',
  'shein.top': 'shein.com',
};

/// The company domain a link points at, share links resolved to the store they
/// came from. Empty when [url] names no host.
String linkDomain(String url) {
  final host = (Uri.tryParse(url)?.host ?? '').toLowerCase();
  if (host.isEmpty) return '';
  return _shareHostStore[host] ?? registrableDomain(host);
}

/// A readable name for a shop we don't carry, taken from its own link:
/// "https://www.hepsiburada.com/…" → "Hepsiburada". It is what the admin who
/// has to buy the item sees beside it, in place of a bare URL.
String storeNameFromLink(String url) {
  final domain = linkDomain(url);
  if (!domain.contains('.')) return '';
  final label = domain.split('.').first;
  return label
      .split(RegExp(r'[-_]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// The catalogue store [url] belongs to, or null when none of them matches —
/// a link from a shop we don't carry, which is added by hand instead.
Store? storeForLink(String url, List<Store> stores) {
  final domain = linkDomain(url);
  if (!domain.contains('.')) return null;
  for (final s in stores) {
    final host = Uri.tryParse(s.url)?.host ?? '';
    if (host.isNotEmpty && registrableDomain(host) == domain) return s;
  }
  return null;
}

/// A link that is plainly a shared cart by its own address: Shein's
/// shared-cart page, a Trendyol collection, or a basket shared from the
/// Trendyol app. Such a link is many items, so it belongs on the cart import,
/// not in a store page waiting to capture one. Short app links (onelink,
/// ty.gl) can't be told apart from a product's until they are followed.
bool isSharedCartLink(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  final path = uri.path.toLowerCase();
  if (host.endsWith('shein.com')) return path.contains('/cart/share');
  if (host.endsWith('trendyol.com')) {
    return path.contains('/koleksiyonlar/') ||
        (path.startsWith('/sepetim') && (uri.queryParameters['d'] ?? '').contains(':'));
  }
  return false;
}
