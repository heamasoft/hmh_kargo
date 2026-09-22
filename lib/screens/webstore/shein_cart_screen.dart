import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/shell_controller.dart';
import '../../services/api_client.dart';
import '../../services/capture_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/debug_log.dart';
import '../../utils/format.dart';
import '../../utils/link_text.dart';
import '../../utils/store_region.dart';
import '../../utils/webview_ua.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/product_image.dart';

/// Imports a whole cart shared from a store's own app.
///
/// Shein's app "share" button on the cart produces an `onelink.shein.com` link.
/// The server turns it into the store's shared-cart landing page; that page
/// renders its items client-side, so we load it in a WebView and read the
/// rendered rows — the same trick the single-product capture uses, because the
/// server is never allowed to see a rendered Shein page.
///
/// The shopper reviews what we found, unticks anything they don't want, and
/// adds the rest to their Heama cart in one go.
class SheinCartScreen extends StatefulWidget {
  const SheinCartScreen({super.key, this.initialLink});

  /// A cart link pasted somewhere else (the store's link box) — loaded at once.
  final String? initialLink;

  @override
  State<SheinCartScreen> createState() => _SheinCartScreenState();
}

/// One row read off the shared-cart page.
class SharedCartItem {
  SharedCartItem({
    required this.title,
    required this.image,
    required this.price,
    required this.currency,
    required this.color,
    required this.size,
    required this.qty,
    required this.url,
    this.sizes = const [],
    this.sku,
  });

  final String title;
  final String image;

  /// The price read from the store's page, in [currency] — shown as-is.
  final double price;
  final String currency;
  final String color;

  /// The size to order. A Shein cart arrives with the one the shopper chose; a
  /// Trendyol collection saves only the product, so the shopper picks here.
  String size;
  final int qty;
  final String url;

  /// Sizes the store offers for this product — the choices for [size].
  final List<String> sizes;

  /// The store's product id, stored with the item so the admin orders the
  /// exact product.
  final String? sku;

  bool selected = true;

  /// A real choice of sizes exists and none is picked yet — the admin couldn't
  /// place this order.
  bool get needsSize => sizes.length >= 2 && size.isEmpty;

  static SharedCartItem? fromJson(Map<String, dynamic> j) {
    final title = ((j['title'] ?? '') as String).trim();
    final price = (j['price'] as num?)?.toDouble() ?? 0;
    // A row without a name or a price can't be priced or ordered — drop it
    // rather than showing the shopper a blank line they can't fix.
    if (title.isEmpty || price <= 0) return null;
    return SharedCartItem(
      title: title,
      image: ((j['image'] ?? '') as String).trim(),
      price: price,
      currency: ((j['currency'] ?? 'USD') as String).trim().toUpperCase(),
      color: ((j['color'] ?? '') as String).trim(),
      size: ((j['size'] ?? '') as String).trim(),
      qty: (j['qty'] as num?)?.toInt() ?? 1,
      url: ((j['url'] ?? '') as String).trim(),
      sizes: (j['sizes'] is List)
          ? (j['sizes'] as List).map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
          : const [],
      sku: j['sku']?.toString(),
    );
  }
}

class _SheinCartScreenState extends State<SheinCartScreen> {
  AppLocalizations get _l => AppLocalizations.of(context);

  late final WebViewController _controller;
  late final CaptureApi _capture;

  final _link = TextEditingController();

  /// null until the page has been read at least once.
  List<SharedCartItem>? _items;

  bool _adding = false;
  int _added = 0;
  String? _error;

  /// A load is running: the overlay covers the screen and back is blocked, so
  /// nothing can be half-started. Always ended by the rows arriving, an error,
  /// or [_deadline] — never left on.
  bool _busy = false;

  /// What the overlay says is happening right now.
  String _stage = '';

  /// Page-load progress 0..1, driving the overlay's bar while Shein loads.
  double _progress = 0;

  /// Shein put up its "verify you're human" page. The overlay lifts so the
  /// shopper can complete it; loading resumes by itself once they're through.
  bool _needsHuman = false;

  /// The in-page reader is running for the current page — started once, at
  /// ~70% loaded or at page-finish, whichever comes first.
  bool _readerStarted = false;

  /// The cart page itself has been requested. Until then the only page in the
  /// WebView is the pre-warm one, which has no rows to read.
  bool _cartRequested = false;

  /// Hard stop for a load, so a stuck page can never trap the shopper.
  Timer? _deadline;

  /// Whether the review list is covering the Shein page. The page opens on the
  /// UAE storefront in dollars (see [sheinStartUrl]), so the rows can go
  /// straight to the list; the currency check still refuses non-dollar rows.
  bool _showReview = false;

  @override
  void initState() {
    super.initState();
    _capture = CaptureApi(context.read<ApiClient>());
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel('HeamaSharedCart', onMessageReceived: _onRows)
      // What Shein itself reports — storefront, currency, ship-to country.
      ..addJavaScriptChannel('HeamaDebug',
          onMessageReceived: (m) => dlog('cart', 'page state ${dcut(m.message)}'))
      ..setNavigationDelegate(NavigationDelegate(
        // The landing page tries to hand off to the store's own app; following
        // that scheme kills the WebView, so stay put.
        onNavigationRequest: (req) {
          final scheme = (Uri.tryParse(req.url)?.scheme ?? '').toLowerCase();
          final allowed = scheme == 'http' || scheme == 'https';
          if (!allowed) dlog('cart', 'blocked app hand-off ${dcut(req.url)}');
          return allowed ? NavigationDecision.navigate : NavigationDecision.prevent;
        },
        onPageStarted: (url) {
          dlog('cart', 'page start ${dcut(url)}');
          // A fresh document has no reader running in it yet.
          _readerStarted = false;
          // Catch Shein's cart data (it carries each item's SKU) as it arrives —
          // never on the human check: it wraps fetch/XHR, which bot checks spot.
          if (!_isChallenge(url)) _controller.runJavaScript(_shareDataHook);
          _checkChallenge(url);
        },
        onUrlChange: (c) {
          dlog('cart', 'url → ${dcut(c.url ?? '')}');
          _checkChallenge(c.url ?? '');
        },
        onProgress: (p) {
          if (!_busy || !mounted) return;
          setState(() => _progress = p / 100);
          // The rows can be on screen well before "finished", which waits for
          // every tracker and image — start reading early.
          if (p < 70 && !_needsHuman) _controller.runJavaScript(_shareDataHook);
          if (p >= 70) _startReading();
        },
        onWebResourceError: (e) => dlog('cart',
            'web error ${e.errorCode} ${e.description} (main frame: ${e.isForMainFrame})'),
        onPageFinished: (url) {
          dlog('cart', 'page done ${dcut(url)}');
          _controller.runJavaScript(pageDiagnosticsJs);
          // Ship to the UAE, not the Gulf country Shein guessed (reloads once).
          _controller.runJavaScript(sheinUaeAddressJs);
          _checkChallenge(url);
          _startReading();
        },
      ));

    // Warm Shein up while the shopper is still pasting: its scripts are large
    // and the first load is the slow one. This also puts the session on the
    // UAE storefront in dollars before the cart page is even requested.
    // The browser identity goes on before the first page (see webview_ua.dart).
    applyStoreUserAgent(_controller).then((_) {
      if (mounted) {
        _controller.loadRequest(Uri.parse(sheinStartUrl('https://m.shein.com/')));
      }
    });

    final link = widget.initialLink?.trim() ?? '';
    if (link.isNotEmpty) {
      _link.text = link;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open();
      });
    }
  }

  @override
  void dispose() {
    _deadline?.cancel();
    _link.dispose();
    super.dispose();
  }

  /// Lifts the overlay while Shein's human check is up — the shopper has to
  /// answer it — and brings it back, reader re-armed, once they're through.
  /// Shein's "verify you're human" page.
  static bool _isChallenge(String url) =>
      RegExp(r'/risk/|captcha|/challenge|geetest|/verify', caseSensitive: false).hasMatch(url);

  void _checkChallenge(String url) {
    if (!_busy || !mounted) return;
    final challenge = _isChallenge(url);
    if (challenge == _needsHuman) return;
    dlog('cart', challenge ? 'Shein human check — handing over' : 'human check passed');
    setState(() {
      _needsHuman = challenge;
      if (!challenge) {
        _readerStarted = false;
        _stage = _l.icReading;
      }
    });
  }

  /// Starts the in-page reader once per page. It waits inside the page for the
  /// rows to render and posts them the moment they're there.
  void _startReading() {
    if (!_busy || !_cartRequested || _needsHuman || _readerStarted || !mounted) {
      return;
    }
    _readerStarted = true;
    dlog('cart', 'reader started at ${(_progress * 100).round()}%');
    setState(() => _stage = _l.icReading);
    // Each store keeps its rows differently: Shein renders them, Trendyol
    // embeds them as data in the page.
    _controller.runJavaScript(_storeKey == 'trendyol' ? _trendyolReader : _scraper);
  }

  /// Ends a load in failure: shows why, and leaves the Shein page visible so
  /// the shopper can see what it's showing.
  void _fail(String message) {
    _deadline?.cancel();
    if (!mounted) return;
    dlog('cart', 'load failed: $message');
    setState(() {
      _busy = false;
      _needsHuman = false;
      _showReview = false;
      _error = message;
    });
  }

  /// Which store the current import belongs to — Shein unless the server says
  /// otherwise (a Trendyol collection comes back tagged `trendyol`).
  String _storeKey = 'shein';

  /// The rows came straight from the server (a collection), not from a page
  /// in the WebView — so "read again" has to fetch them again.
  bool _fromCollection = false;

  Store? get _store {
    final stores = context.read<CatalogProvider>().stores;
    for (final s in stores) {
      if (s.id.toLowerCase() == _storeKey) return s;
    }
    return null;
  }

  /// Resolve the pasted share link, then load the cart page it points at.
  Future<void> _open() async {
    final raw = _link.text.trim();
    if (raw.isEmpty || _busy) return;
    FocusScope.of(context).unfocus(); // drop the keyboard off the overlay
    // Shein's cart share copies a whole recommendation message with the link
    // stuck to the end of it — take the URL out of whatever was pasted.
    var u = linkFromPaste(raw);
    if (!u.startsWith('http')) u = 'https://$u';
    dlog('cart', 'pasted "${dcut(raw)}" → link $u');
    final uri = Uri.tryParse(u);
    if (uri == null || !uri.hasAuthority) {
      dlog('cart', 'rejected: not a link');
      setState(() => _error = 'That doesn\'t look like a link.');
      return;
    }

    setState(() {
      _busy = true;
      _stage = _l.icFinding;
      _progress = 0;
      _needsHuman = false;
      _readerStarted = false;
      _cartRequested = false;
      _error = null;
      _items = null;
      _showReview = false;
    });
    // Never leave the shopper locked out: a load that hasn't produced rows by
    // now isn't going to. Time spent on Shein's human check doesn't count.
    _deadline?.cancel();
    _deadline = Timer(const Duration(seconds: 35), () {
      if (_busy && !_needsHuman) {
        _fail(_l.icTooLong);
      }
    });

    final resolved = await _capture.resolve(uri.toString());
    dlog('cart', 'resolve → share=${resolved.isShare} cart=${resolved.isCart} '
        'url=${dcut(resolved.url)}');
    if (!mounted) return;

    // Tell the two failures apart: a link the server couldn't read at all is a
    // very different problem from a link that turned out to be one product, and
    // blaming the shopper for the former sends them hunting for a better link.
    if (!resolved.isShare) {
      _fail(_l.icServerCantRead);
      return;
    }
    _storeKey = (resolved.storeKey ?? 'shein').toLowerCase();
    // Rows read by the server can only be refreshed by asking it again; rows
    // read on the phone can be re-read from the page already loaded.
    _fromCollection = resolved.isCollection && !resolved.readOnDevice;

    // Trendyol refused the server (it blocks data-centre IPs) but serves the
    // phone normally — open the collection here and read it off the page.
    if (resolved.isCollection && resolved.readOnDevice) {
      dlog('cart', 'store refused the server — reading ${dcut(resolved.url)} on the phone');
      await _pinTurkey();
      if (!mounted) return;
      setState(() => _stage = _l.icOpening('Trendyol'));
      _cartRequested = true;
      _controller.loadRequest(Uri.parse(resolved.url));
      return;
    }

    // Trendyol shares collections, and the server has already read the rows —
    // no page to load, straight to the list.
    if (resolved.isCollection) {
      final rows = resolved.items
          .map(SharedCartItem.fromJson)
          .whereType<SharedCartItem>()
          .toList();
      dlog('cart', 'collection from $_storeKey: ${resolved.items.length} item(s), '
          'kept ${rows.length}');
      if (rows.isEmpty) {
        _fail(_l.icEmptyCollection);
        return;
      }
      _deadline?.cancel();
      setState(() {
        _items = rows;
        _busy = false;
        _showReview = true;
      });
      return;
    }

    if (!resolved.isCart) {
      _fail(_l.icSingleProduct);
      return;
    }

    // UAE storefront, priced in dollars — see store_region.dart for why.
    final start = sheinStartUrl(resolved.url);
    dlog('cart', 'opening $start');
    _cartRequested = true;
    setState(() => _stage = _l.icOpening('Shein'));
    _controller.loadRequest(Uri.parse(start));
  }

  /// Puts the WebView on Trendyol's Turkish storefront, priced in TL — the same
  /// cookies the store page uses. Without them Trendyol sends a visitor from
  /// Iraq to a country picker instead of the collection.
  Future<void> _pinTurkey() async {
    try {
      final cookies = WebViewCookieManager();
      const kv = {
        'storefrontId': '1',
        'countryCode': 'TR',
        'language': 'tr',
        'LanguageType': 'tr',
        'int_locale': 'tr-TR',
      };
      for (final domain in const ['.trendyol.com', 'www.trendyol.com']) {
        for (final e in kv.entries) {
          await cookies.setCookie(
            WebViewCookie(name: e.key, value: e.value, domain: domain, path: '/'),
          );
        }
      }
    } catch (e) {
      // Best effort — the page may still load; the reader reports if not.
      dlog('cart', 'could not set Turkey cookies: $e');
    }
  }

  /// Reads the current page again, e.g. after changing a quantity on Shein.
  void _reread() {
    if (_busy) return;
    dlog('cart', 'reread');
    setState(() {
      _busy = true;
      _stage = _l.icReading;
      _error = null;
    });
    _deadline?.cancel();
    _deadline = Timer(const Duration(seconds: 20), () {
      if (_busy && !_needsHuman) _fail(_l.icCouldNotRead);
    });
    _readerStarted = false;
    _startReading();
  }

  /// The currency the Shein store row is priced in.
  String get _storeCurrency =>
      (_store?.currency ?? (_storeKey == 'trendyol' ? 'TRY' : 'USD')).toUpperCase();

  /// The first currency on the page that isn't the store's, or null if all
  /// match. Such rows must never be added: the server prices every Shein item
  /// in the store's currency, so a Gulf-storefront figure like 26.00 AED would
  /// be charged as $26 — several times the real price.
  String? _foreignCurrency(List<SharedCartItem> items) {
    for (final i in items) {
      final c = i.currency.toUpperCase();
      if (c.isNotEmpty && c != _storeCurrency) return c;
    }
    return null;
  }

  void _onRows(JavaScriptMessage message) {
    if (!mounted) return;
    dlog('cart', 'scraper raw ${dcut(message.message)}');
    List<SharedCartItem> rows = [];
    try {
      final decoded = jsonDecode(message.message) as List<dynamic>;
      rows = decoded
          .map((e) => SharedCartItem.fromJson(e as Map<String, dynamic>))
          .whereType<SharedCartItem>()
          .toList();
      dlog('cart', 'scraper found ${decoded.length} row(s), kept ${rows.length}');
    } catch (e) {
      dlog('cart', 'scraper output unreadable: $e');
      rows = [];
    }
    for (final r in rows) {
      dlog('cart', '  row "${dcut(r.title)}" ${r.price} ${r.currency} '
          'colour="${r.color}" size="${r.size}" qty=${r.qty} sku="${r.sku ?? ''}"');
    }
    final foreign = _foreignCurrency(rows);
    if (foreign != null) {
      dlog('cart', 'BLOCKED: page currency $foreign ≠ store $_storeCurrency');
    }
    // The pre-warm load and stray reads can post while no load is running —
    // only a load the shopper started may change the screen.
    if (!_busy) return;
    if (rows.isEmpty) {
      // The in-page reader already waited for the rows to render, so empty
      // here means the page genuinely has none.
      _fail(_l.icNoItems);
      return;
    }
    _deadline?.cancel();
    setState(() {
      _items = rows;
      _busy = false;
      _showReview = true;
    });
  }

  /// Adds every ticked row to the Heama cart, pricing each one in IQD first.
  Future<void> _addSelected() async {
    final chosen = (_items ?? []).where((i) => i.selected).toList();
    if (chosen.isEmpty || _adding) return;
    // The button is already disabled for this; checked again here so no path
    // can price a foreign-currency figure as the store's currency.
    final foreign = _foreignCurrency(chosen);
    if (foreign != null) {
      setState(() => _error = _currencyAdvice(foreign));
      return;
    }
    // Without a size the admin can't place the order — ask now, not later.
    final unsized = chosen.where((i) => i.needsSize).toList();
    if (unsized.isNotEmpty) {
      setState(() => _error = unsized.length == 1
          ? _l.icPickSizeOne(unsized.first.title)
          : _l.icPickSizeMany(unsized.length));
      return;
    }
    final store = _store;
    if (store == null) {
      setState(() => _error = _l.icStoresLoading);
      return;
    }

    final cart = context.read<CartProvider>();
    setState(() {
      _adding = true;
      _added = 0;
      _error = null;
    });

    final failed = <String>[];
    for (final item in chosen) {
      try {
        final priced = await _capture.price(
          storeKey: store.id,
          sourceUrl: item.url.isEmpty ? store.url : item.url,
          title: item.title,
          imageUrl: item.image,
          sourcePrice: item.price,
          sourceCurrency: item.currency,
          color: item.color.isEmpty ? null : item.color,
          size: item.size.isEmpty ? null : item.size,
        );
        final ok = await cart.addCaptured(
          priced,
          color: item.color.isEmpty ? null : item.color,
          size: item.size.isEmpty ? null : item.size,
          sku: item.sku,
          qty: item.qty < 1 ? 1 : item.qty,
        );
        if (ok) {
          if (mounted) setState(() => _added++);
        } else {
          failed.add(item.title);
        }
      } on ApiException {
        failed.add(item.title);
      }
    }

    if (!mounted) return;
    setState(() => _adding = false);

    if (_added > 0) {
      showHeamaToast(context, _l.icAdded(_added));
      context.read<ShellController>().goToTab(ShellController.cart);
      Navigator.pop(context);
      return;
    }
    setState(() => _error = failed.isEmpty
        ? _l.icNothingAdded
        : _l.icCouldNotAdd(failed.first));
  }

  // Reads the rendered shared-cart rows.
  //
  // The selectors below were taken from Shein's live shared-cart page, not
  // guessed: each item is a `.bsc-cart-be-shared-goods-item_v1`, the colour and
  // size arrive as one "Black / M" string on the sale-attr element, and the
  // price must come from `__sale-price` — reading the whole price box yields
  // "$5.70$6.70", the sale and struck-through original run together.
  //
  // A generic "block with a product image and a price" scan is kept as a
  // fallback so a markup change degrades instead of breaking outright.
  // Keeps Shein's shared-cart data as the page fetches it. The rendered rows
  // show no SKU, but that reply names each item's goods_sn ("sm2601…") — the
  // code the admin orders by. Idempotent: safe to inject more than once.
  static const _shareDataHook = r'''
(function(){
  if(window.__heamaHooked) return; window.__heamaHooked=true;
  window.__heamaShare=window.__heamaShare||[];
  function keep(u,t){ try{ if(/share\/landing|cart\/share/i.test(String(u))) window.__heamaShare.push(JSON.parse(t)); }catch(e){} }
  try{
    var of=window.fetch;
    if(of) window.fetch=function(){ var a=arguments; return of.apply(this,a).then(function(r){
      try{ var u=a[0]&&a[0].url||a[0]; if(/share/i.test(String(u))) r.clone().text().then(function(t){keep(u,t);}); }catch(e){}
      return r; }); };
    var oo=XMLHttpRequest.prototype.open, os=XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.open=function(m,u){ this.__heamaU=u; return oo.apply(this,arguments); };
    XMLHttpRequest.prototype.send=function(){ var x=this;
      x.addEventListener('load',function(){ try{ keep(x.__heamaU,x.responseText); }catch(e){} });
      return os.apply(this,arguments); };
  }catch(e){}
})();
''';

  static const _scraper = r'''
(function(){
  function txt(el){ return el ? (el.textContent||'').replace(/\s+/g,' ').trim() : ''; }
  // Parses a price in any locale: "1.290,00" and "1,290.00" both -> 1290.
  function num(s){
    s=(''+s).replace(/[^0-9.,]/g,''); if(!s) return NaN;
    var c=s.lastIndexOf(','), d=s.lastIndexOf('.');
    if(c>-1&&d>-1){ s=(c>d)? s.replace(/\./g,'').replace(',','.') : s.replace(/,/g,''); }
    else if(c>-1){ s=/,\d{2}$/.test(s)? s.replace(',','.') : s.replace(/,/g,''); }
    else if(d>-1){ if(/\.\d{3}(\D|$)/.test(s)&&!/\.\d{1,2}$/.test(s)) s=s.replace(/\./g,''); }
    var n=parseFloat(s); return isNaN(n)?NaN:n;
  }
  // Shein's own record of the currency it is pricing in. Authoritative, unlike
  // the symbol: the Gulf storefronts use new glyphs no pattern here knows, and
  // a missed symbol silently defaulting to USD would charge riyals as dollars.
  var pageCur='';
  try{ if(typeof gbCommonInfo!=='undefined' && gbCommonInfo.currency) pageCur=String(gbCommonInfo.currency).toUpperCase(); }catch(e){}
  function currencyOf(s){
    if(pageCur) return pageCur;
    if(/€/.test(s)) return 'EUR';
    if(/£/.test(s)) return 'GBP';
    if(/AED|د\.إ/i.test(s)) return 'AED';
    if(/TRY|TL|₺/i.test(s)) return 'TRY';
    return 'USD';
  }
  // Shein serves protocol-relative image URLs; the WebView needs a scheme.
  function abs(u){ return !u ? '' : (u.indexOf('//')===0 ? 'https:'+u : u); }
  function isSize(t){
    return /^(xx?x?s|xx?x?l|[0-9]{1,3}(\.[05])?|one[\s-]?size|free[\s-]?size|[0-9]+xl)$/i.test(t);
  }
  // "Black / M" -> colour + size. One part alone is judged on its own shape.
  function splitAttr(s){
    var parts=(s||'').split('/').map(function(p){return p.trim();}).filter(Boolean);
    if(parts.length>=2) return { color:parts[0], size:parts.slice(1).join(' / ') };
    if(parts.length===1) return isSize(parts[0]) ? { color:'', size:parts[0] } : { color:parts[0], size:'' };
    return { color:'', size:'' };
  }
  function qtyOf(r){
    var q=r.querySelector('[class*="quantity" i], [class*="qty" i], [class*="number" i]');
    var m=txt(q).match(/(\d{1,3})/);
    return m ? parseInt(m[1],10) : 1;
  }

  // Each item's SKU (goods_sn). First from the row's own component data, which
  // describes that row alone (never climb to the list — it holds every item);
  // then from Shein's cart reply kept by the hook, matched by name.
  function snOf(o){ return o && (o.goods_sn||o.goodsSn||o.skc||o.sku_code||o.skuCode||''); }
  function findSn(root, depth){
    var seen=[], q=[[root,0]];
    while(q.length){ var p=q.shift(), x=p[0];
      if(!x||typeof x!=='object'||seen.indexOf(x)>=0||p[1]>depth||seen.length>400) continue;
      seen.push(x); var s=snOf(x); if(s && typeof s!=='object') return String(s);
      var ks; try{ks=Object.keys(x);}catch(e){continue;}
      for(var i=0;i<ks.length&&i<80;i++){ var v; try{v=x[ks[i]];}catch(e){continue;} if(v&&typeof v==='object') q.push([v,p[1]+1]); }
    }
    return '';
  }
  function rowSku(r){
    var els=[r].concat([].slice.call(r.querySelectorAll('*'),0,40));
    for(var i=0;i<els.length;i++){ var e=els[i];
      try{ if(e.__vueParentComponent){ var c=e.__vueParentComponent; var s=findSn(c.props,4)||findSn(c.setupState,3); if(s) return s; } }catch(x){}
      try{ if(e.__vue__){ var s2=findSn(e.__vue__.$props,4); if(s2) return s2; } }catch(x){}
    }
    return '';
  }
  var shareGoods=null;
  function hookedSku(title){
    if(!shareGoods){ shareGoods=[];
      var all=window.__heamaShare||[], q=all.slice(), n=0;
      while(q.length&&n<50000){ n++; var x=q.pop(); if(!x||typeof x!=='object') continue;
        var s=snOf(x), nm=x.goods_name||x.goodsName||'';
        if(s&&nm) shareGoods.push({sn:String(s),name:String(nm)});
        for(var k in x){ var v=x[k]; if(v&&typeof v==='object') q.push(v); } }
    }
    var t=(title||'').toLowerCase().replace(/\s+/g,' ').trim();
    for(var i=0;i<shareGoods.length;i++){ var g=shareGoods[i].name.toLowerCase().replace(/\s+/g,' ').trim();
      if(g && t && (g===t || g.indexOf(t)===0 || t.indexOf(g)===0)) return shareGoods[i].sn; }
    return '';
  }

  function rows(){
    var list=document.querySelectorAll('.bsc-cart-be-shared-goods-item_v1'), out=[];
    for(var i=0;i<list.length;i++){
      var r=list[i];
      var a=r.querySelector('.bsc-cart-item-goods-title__content');
      var img=r.querySelector('.bsc-cart-item-goods-img__content img');
      var attr=r.querySelector('.bsc-cart-item-goods-sale-attr');
      // The sale price only — the whole price box concatenates it with the
      // struck-through original, which would parse as one huge number.
      var sale=r.querySelector('.bsc-cart-item-goods-price__sale-price')
            || r.querySelector('.bsc-cart-item-goods-price__main')
            || r.querySelector('[class*="sale-price" i]');
      var priceText=txt(sale);
      var v=splitAttr((attr&&attr.getAttribute('aria-label'))||txt(attr));
      out.push({
        title:(a&&a.getAttribute('title'))||txt(a),
        image:abs(img?(img.getAttribute('data-src')||img.getAttribute('src')):''),
        price:num(priceText),
        currency:currencyOf(priceText),
        color:v.color, size:v.size, qty:qtyOf(r),
        url:(a&&a.getAttribute('href'))?a.href:'',
        sku:rowSku(r)||hookedSku((a&&a.getAttribute('title'))||txt(a))
      });
    }
    return out;
  }

  // Debug aid: every piece of price-looking text in each row, with its class,
  // so a promotion shown outside the sale-price element (e.g. "Extra Savings")
  // can be spotted in the phone's log. Only logged in debug builds.
  function pricesToLog(){
    try{
      if(typeof HeamaDebug==='undefined') return;
      // Where the SKUs came from — the hook caught Shein's cart reply or not.
      HeamaDebug.postMessage('share replies caught: '+((window.__heamaShare||[]).length)+' sample: '+JSON.stringify(window.__heamaShare||[]).slice(0,600));
      var list=document.querySelectorAll('.bsc-cart-be-shared-goods-item_v1');
      for(var i=0;i<list.length;i++){
        var bits=[], els=list[i].querySelectorAll('*');
        for(var j=0;j<els.length;j++){
          var e=els[j];
          if(e.children.length) continue;               // leaf text only
          var t=txt(e);
          if(!t || t.length>60) continue;
          var cls=String(e.className&&e.className.baseVal!==undefined?e.className.baseVal:e.className||'');
          if(/\d/.test(t) && (/[$%€£]|off|save|coupon|price|extra/i.test(t) || /price|discount|promo|coupon|save/i.test(cls)))
            bits.push(cls.split(' ')[0]+'='+t);
        }
        HeamaDebug.postMessage('row '+i+' prices: '+bits.join(' | '));
        // The whole row as the shopper sees it — prices split across spans
        // ("$" "13" ".29") slip past the leaf scan above.
        HeamaDebug.postMessage('row '+i+' text: '+String(list[i].innerText||'').replace(/\s+/g,' ').slice(0,700));
      }
    }catch(e){}
  }

  // Fallback: any block holding a product image AND a price.
  function generic(){
    var out=[], imgs=document.querySelectorAll('img[src*="ltwebstatic"], img[data-src*="ltwebstatic"]');
    for(var i=0;i<imgs.length;i++){
      var n=imgs[i], hops=0, box=null;
      while(n && hops<6){
        n=n.parentElement; hops++; if(!n) break;
        var s=txt(n);
        if(/(US?\$|\$|€|£|AED)\s?\d/.test(s) && s.length<400){ box=n; break; }
      }
      if(!box) continue;
      var s2=txt(box), pm=s2.match(/(US?\$|\$|€|£|AED)\s?[\d.,]+/);
      var price=pm?num(pm[0]):NaN;
      if(isNaN(price)||price<=0) continue;
      out.push({
        title:(imgs[i].getAttribute('alt')||s2).slice(0,160),
        image:abs(imgs[i].getAttribute('data-src')||imgs[i].getAttribute('src')||''),
        price:price, currency:currencyOf(pm?pm[0]:''), color:'', size:'', qty:1, url:''
      });
    }
    return out;
  }

  // The rows arrive by XHR after the page says it's loaded. Rather than guess a
  // moment from outside, wait here and post the instant real rows exist — a
  // row counts once it has a title AND a price, since Shein renders the frame
  // before the numbers. The generic scan is kept to the very end: it can match
  // page furniture, so Shein's own rows get every chance first.
  if(window.__heamaReading) return;   // one reader per page
  window.__heamaReading=true;
  var tries=0;
  (function wait(){
    var found=rows().filter(function(r){ return r.title && r.price>0; });
    if(!found.length && tries>=45) found=generic();
    if(found.length || tries>=50){
      window.__heamaReading=false;      // allow a later re-read
      pricesToLog();
      HeamaSharedCart.postMessage(JSON.stringify(found));
      return;
    }
    tries++;
    setTimeout(wait, 300);              // ~15s at most
  })();
})();
''';

  // Reads a Trendyol collection on the phone. Trendyol refuses the server
  // (HTTP 403 for data-centre IPs), but the page it serves the phone embeds
  // every product as data — a `"products":[…]` array in an inline script —
  // which is read here exactly as the server's TrendyolLinkResolver reads it:
  // same array, same fields, same TL→TRY and size rules.
  static const _trendyolReader = r'''
(function(){
  if(window.__heamaReading) return;   // one reader per page
  window.__heamaReading=true;

  // Returns the balanced [...] starting at i, skipping string contents so a
  // bracket inside a product name can't end it early.
  function balanced(s, i){
    var depth=0, inStr=false, esc=false;
    for(var k=i;k<s.length;k++){
      var c=s[k];
      if(inStr){ if(esc) esc=false; else if(c==='\\') esc=true; else if(c==='"') inStr=false; continue; }
      if(c==='"') inStr=true;
      else if(c==='[') depth++;
      else if(c===']'){ depth--; if(depth===0) return s.substring(i,k+1); }
    }
    return null;
  }
  function products(){
    var h=document.documentElement.innerHTML;
    var at=h.indexOf('"products":[');
    if(at<0) return null;
    var raw=balanced(h, at+'"products":'.length);
    if(!raw) return null;
    try{ return JSON.parse(raw); }catch(e){ return null; }
  }
  function sizes(p){
    var seen={}, out=[];
    (p.merchantListings||[]).forEach(function(l){
      (l.variants||[]).forEach(function(v){
        (v.variantAttributes||[]).forEach(function(a){
          var s=String(a.attributeValue||a.value||'').trim();
          if(s && !seen[s]){ seen[s]=1; out.push(s); }
        });
      });
    });
    return out;
  }
  function row(p){
    var sp=p.sanitizedPrice||{}, fp=sp.finalPrice||{};
    var cur=String(sp.currency||'').toUpperCase();
    return {
      title:String(p.name||'').trim(),
      image:p.imageUrl||((p.images||[])[0])||'',
      price:Number(fp.value)||0,
      currency:(!cur||cur==='TL')?'TRY':cur,
      color:'', size:'', qty:1,
      url:p.url?('https://www.trendyol.com'+p.url):'',
      sku:p.id!=null?String(p.id):null,
      sizes:sizes(p)
    };
  }

  var tries=0;
  (function wait(){
    var list=products();
    var rows=list?list.map(row).filter(function(r){ return r.title && r.price>0; }):[];
    if(rows.length || tries>=40){
      window.__heamaReading=false;   // allow a later re-read
      HeamaSharedCart.postMessage(JSON.stringify(rows));
      return;
    }
    tries++;
    setTimeout(wait, 300);           // ~12s at most
  })();
})();
''';

  @override
  Widget build(BuildContext context) {
    final items = _items;
    // Locked while loading — except during Shein's human check, which the
    // shopper must be able to answer (or back out of).
    final locked = _busy && !_needsHuman;
    return PopScope(
      canPop: !locked,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: AppColors.ink,
          title: Text(_l.icTitle, style: AppFonts.display(fontSize: 17)),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _linkBar(),
                  if (_error != null) _errorBar(_error!),
                  if (_needsHuman) _humanCheckBar(),
                  Expanded(
                    child: Stack(
                      children: [
                        // The page stays in the tree so it keeps its state and
                        // can load behind the overlay.
                        Offstage(
                          offstage: _showReview,
                          child: WebViewWidget(controller: _controller),
                        ),
                        if (_showReview && items != null) _review(items),
                        // The store page loads underneath but stays out of
                        // sight — a Shein page appearing on an import screen,
                        // before any link, just confuses. It stays laid out
                        // (not hidden) because Shein only renders the cart rows
                        // for a page with real size on screen. Only Shein's
                        // human check, which needs the shopper, is shown.
                        if (!_showReview && !_needsHuman) Positioned.fill(child: _emptyState()),
                      ],
                    ),
                  ),
                  if (_showReview && items != null) _footer(items),
                ],
              ),
              if (locked) _loadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Covers the whole screen during a load and swallows every tap, with a bar
  /// that tracks the real page load and a line saying which step it's on.
  Widget _loadingOverlay() {
    // The bar follows page progress while Shein loads; before and after that
    // there's no real figure to show, so it runs indeterminate.
    final determinate = (_stage == _l.icOpening('Shein') || _stage == _l.icOpening('Trendyol')) && _progress > 0;
    return Positioned.fill(
      child: Stack(
        children: [
          const ModalBarrier(dismissible: false, color: Color(0xCCFFFFFF)),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_stage,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: determinate ? _progress : null,
                      minHeight: 6,
                      color: AppColors.pomegranate,
                      backgroundColor: AppColors.cloud,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(_l.icPleaseWait,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// What sits over the store page before anything is imported: which links
  /// work and where to find them.
  Widget _emptyState() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(28, 10, 28, 40),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.saffron, AppColors.pomegranate]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            Text(_l.icBringOver,
                textAlign: TextAlign.center, style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              _l.icBringOverSub,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _hintChip('Shein', _l.icShareCart),
                _hintChip('Trendyol', _l.icShareCollection),
              ],
            ),
          ],
        ),
      );

  Widget _hintChip(String store, String how) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cloud,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Text(store, style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(how, style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      );

  /// Shown instead of the overlay while Shein's human check is up.
  Widget _humanCheckBar() => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cloud,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _l.icHumanCheck,
          style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w600, height: 1.35),
        ),
      );

  Widget _linkBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_l.icLinkLabel,
                    style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted)),
                const SizedBox(height: 5),
                TextField(
                  controller: _link,
                  keyboardType: TextInputType.url,
                  style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                      isDense: true, hintText: _l.icLinkHint),
                  onSubmitted: (_) => _open(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _open,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                  color: AppColors.ink, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_l.icLoad,
                      style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBar(String message) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.pomegranate.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.pomegranate.withValues(alpha: 0.35)),
        ),
        child: Text(message,
            style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.pomegranate,
                height: 1.35)),
      );

  Widget _review(List<SharedCartItem> items) {
    // Only a currency problem earns a line above the rows — it blocks adding,
    // so the shopper must see why.
    final foreign = _foreignCurrency(items);
    final head = foreign == null ? 0 : 1;
    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        itemCount: items.length + head,
        separatorBuilder: (_, __) => const Divider(height: 18, color: AppColors.line),
        itemBuilder: (_, i) => (head == 1 && i == 0)
            ? _errorBar(_currencyAdvice(foreign!))
            : _row(items[i - head]),
      ),
    );
  }

  /// What to do when Shein is pricing in something other than the store's
  /// currency. The page opens with `currency=USD`, so this only appears if
  /// Shein ever stops honouring that — and then adding stays refused.
  String _currencyAdvice(String foreign) => _l.icCurrencyAdvice(foreign, _storeCurrency);

  Widget _row(SharedCartItem item) {
    // Where the store offers a choice of sizes, the size gets its own picker
    // below instead of sitting in this line.
    final picksSize = item.sizes.length >= 2;
    final bits = [
      if (item.color.isNotEmpty) item.color,
      if (item.size.isNotEmpty && !picksSize) item.size,
      if (item.qty > 1) '× ${item.qty}',
    ].join(' · ');

    return InkWell(
      onTap: () => setState(() => item.selected = !item.selected),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.selected,
            activeColor: AppColors.pomegranate,
            onChanged: (v) => setState(() => item.selected = v ?? false),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 52,
              height: 62,
              child: ProductImage(
                url: item.image,
                gradient: const [Color(0xFFC9B6E8), Color(0xFFE9C7D6)],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
                if (bits.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(bits,
                      style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
                ],
                if (picksSize) ...[
                  const SizedBox(height: 6),
                  _sizeChip(item),
                ],
                const SizedBox(height: 4),
                // The store's own price, as the shopper saw it in the app.
                Text(formatMoney(item.price, item.currency),
                    style: AppFonts.display(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The size picker's trigger: "Choose size" until one is picked, then the
  /// size itself. Red while a selected row still needs one, so the reason
  /// adding is refused is on screen.
  Widget _sizeChip(SharedCartItem item) {
    final missing = item.needsSize && item.selected;
    final color = missing ? AppColors.pomegranate : AppColors.ink;
    return GestureDetector(
      onTap: () => _pickSize(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: missing ? AppColors.pomegranate.withValues(alpha: 0.08) : AppColors.cloud,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: missing ? AppColors.pomegranate : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.size.isEmpty ? _l.icChooseSize : _l.icSizeValue(item.size),
                style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  /// Lets the shopper pick from the sizes the store offers for this product.
  Future<void> _pickSize(SharedCartItem item) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_l.icChooseSize, style: AppFonts.display(fontSize: 16)),
              const SizedBox(height: 4),
              Text(item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in item.sizes)
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: s == item.size ? AppColors.pomegranate : AppColors.cloud,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: s == item.size ? AppColors.pomegranate : AppColors.line),
                        ),
                        child: Text(s,
                            style: AppFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: s == item.size ? Colors.white : AppColors.ink)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      item.size = picked;
      // Clear a "pick a size" error once nothing is left without one.
      if ((_items ?? []).where((i) => i.selected).every((i) => !i.needsSize)) {
        _error = null;
      }
    });
  }

  Widget _footer(List<SharedCartItem> items) {
    final chosen = items.where((i) => i.selected).length;
    // A foreign currency blocks adding outright — see [_foreignCurrency].
    final blocked = chosen == 0 || _foreignCurrency(items) != null;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          // Read the cart again from the page already loaded.
          GestureDetector(
            onTap: _fromCollection ? _open : _reread,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: AppColors.cloud, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: const Icon(Icons.refresh, size: 20, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: (blocked || _adding) ? null : _addSelected,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: blocked ? AppColors.line : AppColors.pomegranate,
                    borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: _adding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_l.icAddChosen(chosen),
                        style: AppFonts.body(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: blocked ? AppColors.muted : Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
