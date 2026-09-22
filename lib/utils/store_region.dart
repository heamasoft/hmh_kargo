/// Storefront pinning for stores that price by region.
///
/// Shein serves a different price ladder per storefront and ship-to country,
/// and picks both from the visitor's IP. From Iraq it lands on the global
/// storefront with Azerbaijan as the country — measurably the dearest option.
/// The shop buys as the United Arab Emirates, which is Shein's `ar-en`
/// storefront (`siteUid: pwaren`).
///
/// That storefront defaults to local money, and the shop prices Shein in USD —
/// a riyal figure read as dollars would be charged several times over. Two
/// ways to switch it were tried and Shein reverted both (a localStorage value
/// and a cookie); the one it honours is a `currency=USD` URL parameter, and
/// the choice then sticks for the rest of the session.
///
/// Measured on a real shared cart, same two items:
///
///     global, Azerbaijan, USD      $5.70   $3.70
///     ar-en,  UAE,        USD      $5.16   $2.66   ← this
///     Shein's own app (UAE, USD)   $5.03   $3.54
library;

/// The Middle-East storefront, with product names in ENGLISH so whoever places
/// the real order can read them. Use `ar` instead for Arabic names — same
/// region, same prices.
const sheinSite = 'ar-en';

/// Ship-to country the shop buys against.
const sheinCountry = 'AE';

/// Currency the Shein store row is priced in — must match it, or the server
/// charges the page's figures in the wrong money.
const sheinCurrency = 'USD';

/// A storefront path segment such as `us`, `ar`, `ar-en`, `uk`.
final _siteSegment = RegExp(r'^[a-z]{2}(-[a-z]{2})?$', caseSensitive: false);

/// A Shein STOREFRONT host. The share-link hosts (onelink.shein.com,
/// api-shein.shein.com) aren't pages: prefixing their path with /ar-en/ broke
/// the link before the server could resolve it (the home-screen paste did).
bool _isShein(Uri u) {
  final host = u.host.toLowerCase();
  if (!host.contains('shein.com')) return false;
  return !host.startsWith('onelink.') && !host.startsWith('api-shein.');
}

/// Rewrites a Shein URL onto [site]'s path. Returns null when nothing needs
/// changing — the URL isn't Shein's or already points at [site] — so callers
/// can treat null as "leave it alone". Used on every navigation, so it only
/// touches the path: the currency, once set, sticks on its own.
String? forceSheinRegion(String url, {String site = sheinSite}) {
  final u = Uri.tryParse(url);
  if (u == null || !_isShein(u)) return null;

  final segs = List<String>.from(u.pathSegments);
  if (segs.isNotEmpty && segs.first.toLowerCase() == site.toLowerCase()) {
    return null;
  }

  if (segs.isNotEmpty && _siteSegment.hasMatch(segs.first)) {
    segs[0] = site; // swap the wrong storefront for ours
  } else {
    segs.insert(0, site); // a bare path — prefix it
  }

  return u.replace(pathSegments: segs).toString();
}

/// The URL to OPEN a Shein page with: the storefront path plus the country and
/// the currency. The currency parameter is what actually switches Shein to
/// dollars, so every first load goes through this. Non-Shein URLs come back
/// unchanged.
String sheinStartUrl(String url) {
  final u = Uri.tryParse(url);
  if (u == null || !_isShein(u)) return url;

  final pinned = Uri.parse(forceSheinRegion(url) ?? url);
  return pinned.replace(queryParameters: {
    ...pinned.queryParameters,
    'countryCode': sheinCountry,
    'currency': sheinCurrency,
  }).toString();
}

/// Puts Shein's ship-to country on the UAE. Shein guesses one from the IP —
/// from Iraq it picks a Gulf neighbour (Bahrain) — and saves it in
/// localStorage `addressCookie`, which the `countryCode` parameter doesn't
/// touch; product pages then read "Shipping to: Bahrain". Rewriting the saved
/// value sticks across reloads (checked on a real device), so this runs after
/// each Shein page and reloads once when it had to change something. The
/// sessionStorage counter stops a reload loop should Shein ever put it back.
const sheinUaeAddressJs = r'''
(function(){
  try{
    if(!/shein/i.test(location.hostname) || location.pathname.indexOf('/ar-en')!==0) return;
    var raw=localStorage.getItem('addressCookie'), a={};
    try{ a=raw?JSON.parse(raw):{}; }catch(e){ a={}; }
    if(a && a.value==='AE') return;
    var n=+(sessionStorage.getItem('heamaAE')||0);
    if(n>=2) return;
    sessionStorage.setItem('heamaAE', String(n+1));
    a=a||{};
    a.countryName='United Arab Emirates'; a.value='AE'; a.countryId='224';
    a.siteUid=a.siteUid||'pwaren'; a.addrFromFlag=a.addrFromFlag||'2';
    a.displayAddress='United Arab Emirates'; a.displayAddressWithMinLevel='United Arab Emirates';
    a.addressId=''; a.state=''; a.stateId=''; a.city=''; a.cityId=''; a.district=''; a.districtId=''; a.postcode='';
    localStorage.setItem('addressCookie', JSON.stringify(a));
    location.reload();
  }catch(e){}
})();
''';
