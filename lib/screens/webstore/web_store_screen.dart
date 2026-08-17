import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../models/captured_product.dart';
import '../../models/favorite_item.dart';
import '../../models/store.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/shell_controller.dart';
import '../../services/api_client.dart';
import '../../services/capture_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/launcher.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/heama_toast.dart';
import 'open_store.dart';

/// Opens a real store website inside the app. The "Add to Heama" button reads
/// the product straight from the rendered page (JS already ran, so SPA prices
/// are present) and hands it to the capture sheet.
class WebStoreScreen extends StatefulWidget {
  final Store store;

  /// Optional product URL to open directly (e.g. a trending item). Falls back to
  /// the store's home page.
  final String? initialUrl;
  const WebStoreScreen({super.key, required this.store, this.initialUrl});

  @override
  State<WebStoreScreen> createState() => _WebStoreScreenState();
}

/// Route argument for [WebStoreScreen] — a store, optionally opened at a URL.
class WebStoreArgs {
  final Store store;
  final String? url;
  const WebStoreArgs(this.store, {this.url});
}

class _WebStoreScreenState extends State<WebStoreScreen> {
  late final WebViewController _controller;
  double _progress = 0;
  String _url = '';
  bool _capturing = false;
  // Set when the user pastes a link: once the page finishes loading we capture it.
  bool _pendingCapture = false;
  // Set when the heart is tapped: the next scrape result is saved as a favourite.
  bool _pendingFavorite = false;

  // Stable id for the current page (host + path, ignoring query) so the heart
  // reflects whether this product is already saved.
  String _favIdFor(String url) {
    final u = Uri.tryParse(url);
    final base = u == null ? url : '${u.host}${u.path}';
    return 'web-${base.hashCode}';
  }

  String get _favId => _favIdFor(_url);

  // A single product page (not a listing/category/home). Capture only makes
  // sense here, so the button is disabled elsewhere. URL shapes vary a lot
  // between stores, so this is broad; the content probe below is the reliable
  // signal that flips [_isProduct] on real product pages of any store.
  static final _productUrl = RegExp(
    r'-p-?\d{3,}'                 // shein/trendyol -p-123456, zara/inditex -p05644320
    r'|/product|/products/|/item|/dp/|/goods|/pd/|/ip/'
    r'|/urun|/urun-'              // Turkish "ürün" (product)
    r'|-p-[a-z]{1,4}\d+'          // hepsiburada -p-HBC00001234
    r'|productpage\.\d+'          // h&m productpage.1234567890.html
    r'|_\d{6,}\.html'             // mango / others _12345678.html
    r'|p\d{6,}\.html',            // inditex p108340541.html
    caseSensitive: false,
  );

  // Set true once the rendered page shows product signals (og:type=product,
  // JSON-LD Product, or an add-to-cart button). Reliable across stores where
  // the URL alone isn't obvious.
  bool _isProduct = false;
  // Re-probes periodically so SPA navigation (Mango/Zara change page without a
  // full reload) is caught even when no page/URL event fires.
  Timer? _probeTimer;
  // Last URL we rewrote to force the Turkey store, so a geo-redirect can't loop.
  String? _forcedUrl;

  /// Zara (Inditex) puts the country in the first path segment and prices by it.
  /// From Iraq it geo-redirects to /iq/ (IQD); rewrite the country to /tr/ so the
  /// page shows TL, matching the store's configured currency. Returns the fixed
  /// URL, or null if no change is needed.
  String? _forceTurkey(String url) {
    final u = Uri.tryParse(url);
    if (u == null || !u.host.toLowerCase().contains('zara.com')) return null;
    final segs = List<String>.from(u.pathSegments);
    if (segs.isNotEmpty &&
        RegExp(r'^[a-z]{2}$').hasMatch(segs.first.toLowerCase()) &&
        segs.first.toLowerCase() != 'tr') {
      segs[0] = 'tr';
      return u.replace(pathSegments: segs).toString();
    }
    return null;
  }

  bool get _isProductPage => _isProduct || _productUrl.hasMatch(_url);

  // Reads the RENDERED product page. Prefers JSON-LD Product (best product image
  // + price), then OG tags, then the largest on-screen image (avoids logos), and
  // finally a light price heuristic.
  static const _scraper = r'''
(function(){
  function m(p){var e=document.querySelector('meta[property="'+p+'"]')||document.querySelector('meta[name="'+p+'"]');return e?(e.getAttribute('content')||''):'';}
  function txt(el){return (el.getAttribute('aria-label')||el.getAttribute('title')||el.textContent||'').replace(/\s+/g,' ').trim();}
  function classWord(el,kw){var c=(el.getAttribute&&el.getAttribute('class')||'').toLowerCase().split(/[^a-z]+/);return c.indexOf(kw)>=0||c.indexOf(kw+'s')>=0;}
  // Parses a price in ANY locale: "1.290,00" (EU) and "1,290.00" (US) both -> 1290.
  // The LAST of , or . is the decimal separator; a lone thousands separator is dropped.
  function parseNum(s){s=(''+s).replace(/[^0-9.,]/g,'');if(!s)return NaN;
    var c=s.lastIndexOf(','),d=s.lastIndexOf('.');
    if(c>-1&&d>-1){s=(c>d)?s.replace(/\./g,'').replace(',','.'):s.replace(/,/g,'');}
    else if(c>-1){s=/,\d{2}$/.test(s)?s.replace(',','.'):s.replace(/,/g,'');}
    else if(d>-1){if(/\.\d{3}(\D|$)/.test(s)&&!/\.\d{1,2}$/.test(s))s=s.replace(/\./g,'');}
    var n=parseFloat(s);return isNaN(n)?NaN:n;}
  // True if a price node is the crossed-out ORIGINAL price — a <del>/<s> tag, a
  // line-through style, or an "old/was/original" class on it or a near ancestor.
  function isStruck(el){
    for(var n=el,up=0;n&&n.getAttribute&&up<4;up++,n=n.parentElement){
      var tag=(n.tagName||'').toLowerCase();
      if(tag==='del'||tag==='s'||tag==='strike')return true;
      var c=(n.getAttribute('class')||'').toLowerCase();
      if(/old|origin|was|strike|through|crossed|delete/.test(c))return true;
      try{var st=getComputedStyle(n);if((((st.textDecorationLine||'')+' '+(st.textDecoration||'')).indexOf('line-through'))>=0)return true;}catch(e){}
    }
    return false;
  }
  // Reads a selected colour NAME from common "color name/label" containers.
  function colorFromClass(){
    var sel=document.querySelectorAll('[class*="colorname" i],[class*="color-name" i],[class*="colorlabel" i],[class*="color-label" i],[class*="selectedcolor" i],[class*="selected-color" i],[class*="colortitle" i]');
    for(var i=0;i<sel.length && i<25;i++){var t=(sel[i].textContent||'').replace(/\s+/g,' ').trim();
      if(t && t.length<=24 && /[a-zçğışöü]/i.test(t) && !/^(colou?r|renk|select|choose|seç)/i.test(t))return t;}
    return '';
  }
  // Reads the colour NAME Bershka shows next to the product ref: either
  // "<name> RENGİ / RENK / colour" or "<name>  REF.. 2628/710/802" (name before
  // the REF code). Returns the clean colour word.
  function colorFromLabel(){
    var els=document.querySelectorAll('span,div,p,h1,h2,h3,strong,b,label,dt,dd');
    for(var i=0;i<els.length && i<2500;i++){var el=els[i];
      if(el.children && el.children.length>3)continue;
      var raw=(el.textContent||'').replace(/\s+/g,' ').trim();
      if(!raw||raw.length>60)continue;
      var v='';
      var mr=raw.match(/^(.{2,30}?)\s+ref\.?\s*\.?/i);            // "<name> REF.. <code>"
      if(mr)v=mr[1].trim();
      if(!v){var m2=raw.match(/^(.{2,30}?)\s+(renk|reng\S{0,3}|colou?r|color)\s*$/i);if(m2)v=m2[1].trim();} // "<name> RENK"
      v=v.replace(/\s+(renk|reng\S{0,3}|colou?r|color)\s*$/i,'').replace(/\s+/g,' ').trim(); // drop trailing "RENGİ"
      if(v.length>=2 && v.length<=30 && /[a-zA-ZçğışöüÇĞİŞÖÜ]/.test(v) && !/\d/.test(v))return v;
    }
    return '';
  }
  // Many stores (Mango, Zara…) show the selected colour NAME as a short,
  // right-aligned label just ABOVE the product title, with no "Colour:" prefix.
  // Find the title, then read the closest short right-side word sitting above it.
  function colorFromPosition(titleText){
    if(!titleText)return '';
    var tl=titleText.toLowerCase(),titleEl=null;
    var cands=document.querySelectorAll('h1,h2,[class*="title" i],[class*="name" i]');
    for(var i=0;i<cands.length && i<200;i++){var t=(cands[i].textContent||'').replace(/\s+/g,' ').trim();
      if(t.length>=6 && t.length<=90 && tl.indexOf(t.toLowerCase())>=0){titleEl=cands[i];break;}}
    if(!titleEl)return '';
    var tr;try{tr=titleEl.getBoundingClientRect();}catch(e){return '';}
    var vw=window.innerWidth||400;if(tr.width<=0)return '';
    var els=document.querySelectorAll('span,div,p,strong,b,label,h3');
    var best='',bestBottom=-1e9;
    for(var j=0;j<els.length && j<3500;j++){var el=els[j];
      if(el.children && el.children.length>0)continue;                 // leaf text only
      var tx=(el.textContent||'').replace(/\s+/g,' ').trim();
      if(!tx||tx.length>28||tx.split(' ').length>3)continue;
      if(/[0-9%₺$€]/.test(tx))continue;                                // not a price/discount
      if(/^(new|now|yeni|evaze|midi|mini|maxi|slim|regular|oversize|plus|görünümü|görüntüle|ekle|add|mağazaya|ücretsiz|gönderim|beden|renk|size|colou?r)$/i.test(tx))continue;
      var r;try{r=el.getBoundingClientRect();}catch(e){continue;}
      if(r.width<=0||r.height<=0)continue;
      if(r.bottom>tr.top+8)continue;                                   // above the title
      if(r.top<tr.top-220)continue;                                    // but close above
      if(r.left<vw*0.45)continue;                                      // right side
      if(r.bottom>bestBottom){bestBottom=r.bottom;best=tx;}            // closest above title
    }
    return best;
  }
  var title='',ldImage='',price='',currency='',color='';
  // 1) JSON-LD Product
  var ss=document.querySelectorAll('script[type="application/ld+json"]');
  for(var i=0;i<ss.length;i++){try{
    var d=JSON.parse(ss[i].textContent);var a=Array.isArray(d)?d:(d['@graph']||[d]);
    for(var j=0;j<a.length;j++){var x=a[j];if(!x)continue;var t=x['@type'];
      if(t==='Product'||(Array.isArray(t)&&t.indexOf('Product')>=0)){
        title=title||x.name||'';
        if(x.color)color=color||(typeof x.color==='string'?x.color:'');
        if(!ldImage&&x.image)ldImage=(typeof x.image==='string'?x.image:(x.image.url||x.image[0]||''));
        var o=x.offers;if(o){var of=Array.isArray(o)?o[0]:o;if(of){price=price||of.price||of.lowPrice||'';currency=currency||of.priceCurrency||'';}}
      }
    }
  }catch(e){}}
  title=title||m('og:title')||document.title||'';
  price=price||m('product:price:amount')||m('og:price:amount')||'';
  currency=currency||m('product:price:currency')||m('og:price:currency')||'';
  // 1b) TRENDYOL: read the exact selling price straight from its global product
  //     state. On-page heuristics miss it (Trendyol prices use "prc-*" classes,
  //     not "price") and can grab the "3x 383,67 TL" installment by mistake, so
  //     this authoritative source OVERRIDES whatever else was found.
  if(/trendyol/i.test(location.hostname)){try{
    var TS=window.__PRODUCT_DETAIL_APP_INITIAL_STATE__||window.__NEXT_DATA__||window.__INITIAL_STATE__;
    var TP=TS&&(TS.product||(TS.props&&TS.props.pageProps&&TS.props.pageProps.product)||(TS.productDetail&&TS.productDetail.product));
    var TPR=TP&&TP.price;
    if(TPR){
      var cand=TPR.discountedPrice||TPR.sellingPrice||TPR.originalPrice||TPR;
      var pv=(cand&&cand.value!=null)?cand.value:cand;
      var pn=parseNum(''+pv);
      if(!isNaN(pn)&&pn>0){price=String(pn);currency='TRY';}
    }
  }catch(e){}}
  // 2) IMAGE: the big photo ACTUALLY ON SCREEN wins (stores like Shein set
  //    og:image to a logo, so metadata is only a fallback).
  var image='';
  var vw=window.innerWidth||400,vh=window.innerHeight||800,best='',bv=0,imgs=document.images;
  for(var k=0;k<imgs.length;k++){var im=imgs[k];if((im.naturalWidth||0)<200)continue;if(!im.src||im.src.indexOf('data:')===0)continue;
    var r=im.getBoundingClientRect();var xx=Math.max(0,Math.min(r.right,vw)-Math.max(r.left,0));var yy=Math.max(0,Math.min(r.bottom,vh)-Math.max(r.top,0));var va=xx*yy;
    if(va>bv){bv=va;best=im.src;}}
  if(best && bv>(vw*vh*0.12))image=best; // must fill a real chunk of the screen
  if(!image){
    var gsel=['[class*="swiper-slide-active"] img','[class*="slick-active"] img','[class*="gallery"] img','[class*="main"] img','[class*="crop"] img'];
    for(var s=0;s<gsel.length && !image;s++){var e=document.querySelector(gsel[s]);if(e&&e.src&&(e.naturalWidth||0)>=200)image=e.src;}
  }
  if(!image)image=ldImage||m('og:image')||m('twitter:image')||'';
  // 3) price heuristic. Collect each SINGLE-number price cell (skip containers
  //    that glue both prices together, and "-%16" badges), remembering if a value
  //    ever appears crossed-out. Then pick the price the customer PAYS: the live
  //    one when a struck original exists, else the lower of an original/sale pair
  //    (Mango/Zara "5.699,99 TL  4.799,99 TL"), guarding against installments.
  if(!price){var pels=document.querySelectorAll('[itemprop="price"],[class*="price" i],[class*="Price"]');
    var seen={};
    for(var q=0;q<pels.length&&q<120;q++){var el=pels[q];
      var tx=(el.getAttribute('content')||el.textContent||'').replace(/\s+/g,' ').trim();
      if(!tx||tx.indexOf('%')>=0)continue;
      var nums=tx.match(/[0-9][0-9.,]*[0-9]|[0-9]/g);
      if(!nums||nums.length!==1)continue;                            // one price per cell
      var n=parseNum(nums[0]);if(isNaN(n)||n<=0)continue;
      var key=n.toFixed(2),live=!isStruck(el);
      if(!(key in seen))seen[key]=live; else if(live)seen[key]=true;}
    var liveV=[],crossV=[];for(var k in seen){(seen[k]?liveV:crossV).push(parseFloat(k));}
    var chosen=NaN;
    if(liveV.length){
      if(crossV.length){chosen=Math.min.apply(null,liveV);}          // sale = the live price
      else if(liveV.length>=2){liveV.sort(function(a,b){return b-a;});
        chosen=(liveV[1]>=liveV[0]*0.35)?liveV[1]:liveV[0];}         // orig/sale pair -> sale
      else chosen=liveV[0];
    } else if(crossV.length){chosen=Math.min.apply(null,crossV);}
    if(!isNaN(chosen)&&chosen>0)price=String(chosen);}
  // 3b) Currency fallback for stores that don't use a "price" class (H&M): the
  //     TOPMOST short leaf whose text carries a currency mark is the product price.
  if(!price){
    var money=/(?:₺|\bTL\b|\bTRY\b|\$|\bUSD\b|€|\bEUR\b|£|\bGBP\b|\bSAR\b|\bAED\b)/i;
    var vh=window.innerHeight||800;
    var mels=document.querySelectorAll('span,div,p,strong,b,h1,h2,h3');
    var bestP='',bestTop=1e9;
    for(var mq=0;mq<mels.length && mq<4000;mq++){var mel=mels[mq];
      if(mel.children && mel.children.length>0)continue;              // leaf text only
      var mtx=(mel.textContent||'').replace(/\s+/g,' ').trim();
      if(!mtx||mtx.length>24||mtx.indexOf('%')>=0||!money.test(mtx))continue;
      var mnums=mtx.match(/[0-9][0-9.,]*[0-9]|[0-9]/g);if(!mnums||mnums.length!==1)continue;
      var mn=parseNum(mnums[0]);if(isNaN(mn)||mn<=0)continue;
      var mr;try{mr=mel.getBoundingClientRect();}catch(e){continue;}
      if(mr.width<=0||mr.top<-80||mr.top>vh*1.6)continue;             // in the product area
      if(mr.top<bestTop){bestTop=mr.top;bestP=String(mn);}           // topmost = product price
    }
    if(bestP)price=bestP;
  }
  // Normalise whatever source gave the price into a clean numeric string.
  if(price){var pn=parseNum(price);if(!isNaN(pn)&&pn>0)price=String(pn);}
  // 4) Detect SIZE options by their text values (S/M/L/… or numbers) and COLOR
  //    options by real swatches (small elements with an inline background colour).
  //    A container "offers" the attribute when most of its direct children match.
  // Pulls the size out of an option's text, ignoring trailing noise like
  // "3 left", "-20%", "Almost sold out". Handles letter, numeric and kids-age
  // formats. Returns '' when the text doesn't start with a size.
  function sizeToken(raw){
    var t=(raw||'').replace(/\s+/g,' ').trim();
    if(!t||t.length>60)return '';
    // Strip stock/discount badges glued onto the size ("L3 left", "3 left L", "-20%").
    t=t.replace(/\b\d{1,3}\s*(left|remaining|in\s?stock)\b/ig,' ')
       .replace(/almost sold out|sold out|out of stock/ig,' ')
       .replace(/-?\d{1,3}\s*%(\s*off)?/ig,' ')
       .replace(/\bhot\b|\bnew\b/ig,' ')
       .replace(/\s+/g,' ').trim();
    if(!t)return '';
    var m;
    // kids age range: 3-6 Years, 6-12M, 18-24 Months, 0-3M
    m=t.match(/^\d{1,2}\s?[-–]\s?\d{1,2}\s?(years?|yrs?|y|months?|mos?|m|t)(?=$|[^a-z])/i);
    if(m)return m[0].replace(/\s+/g,' ').trim();
    // single age: 5Y, 2T, 24M, 5 Years
    m=t.match(/^\d{1,3}\s?(years?|yrs?|y|months?|mos?|t)(?=$|[^a-z])/i);
    if(m)return m[0].replace(/\s+/g,' ').trim();
    // region-prefixed numeric: CN36, EU38, US 8, UK10, JP 24 (any 2-3 letter code)
    m=t.match(/^[a-z]{2,3}\s?\d{1,3}(\.\d)?(?=$|[^0-9a-z])/i);
    if(m)return m[0].replace(/\s+/g,' ').trim().toUpperCase();
    // letter / word sizes (longest first so "Small" beats "S"). The lookahead
    // lets a badge glued to the size still match: "L3 left" -> "L".
    m=t.match(/^(one\s?size|free\s?size|os|xxxx-?large|xxx-?large|xx-?large|x-?large|large|x-?small|small|medium|xxxxl|xxxl|xxl|[2-9]\s?xl|xl|xs|s|m|l)(?=$|[^a-z])/i);
    if(m){var v=m[0].replace(/\s+/g,'');return v.length<=4?v.toUpperCase():m[0].replace(/\s+/g,' ').trim();}
    // pure numeric size (waist / shoe / EU), short only
    m=t.match(/^\d{1,3}(\.\d)?(\/\d{1,3})?(?=$|[^0-9a-z])/i);
    if(m && t.length<=12)return m[0];
    return '';
  }
  function marked(el){
    var cn=(el.getAttribute&&el.getAttribute('class')||'')+' '+(el.getAttribute&&el.getAttribute('data-selected')||'')+' '+(el.getAttribute&&el.getAttribute('data-active')||'');
    if(/(^|[^a-z])(active|selected|checked|current|cur|on)([^a-z]|$)/i.test(cn))return true;
    var a=(el.getAttribute&&el.getAttribute('aria-checked')||'')+(el.getAttribute&&el.getAttribute('aria-selected')||'')+(el.getAttribute&&el.getAttribute('aria-pressed')||'');
    return /true|selected/i.test(a);
  }
  function lumOf(str){var m=(str||'').match(/rgba?\(([^)]+)\)/);if(!m)return null;
    var p=m[1].split(',');var a=p.length>3?parseFloat(p[3]):1;if(!(a>0.3))return null;
    return 0.2126*+p[0]+0.7152*+p[1]+0.0722*+p[2];}
  // Perceived brightness (0=black .. 255=white) of an element's own background,
  // or null when it's transparent.
  function bgLum(el){try{return lumOf(getComputedStyle(el).backgroundColor);}catch(e){return null;}}
  // Darkness of a VISIBLE border (>=1px), or null. H&M/Zara highlight the selected
  // size with a dark border rather than a fill.
  function borderLum(el){try{var cs=getComputedStyle(el);
    var w=parseFloat(cs.borderTopWidth||cs.borderWidth||'0')||parseFloat(cs.borderBottomWidth||'0')||parseFloat(cs.outlineWidth||'0');
    if(!(w>=1))return null;
    return lumOf(cs.borderTopColor||cs.borderColor||cs.outlineColor);
  }catch(e){return null;}}
  // How "picked" a button looks: the darkest fill or border on it OR a nested
  // child (lower = more prominent). Covers fill-highlight (Shein) and border-
  // highlight (H&M/Zara), whether the border is on the cell or an inner button.
  function markLum(el){var best=null;
    function consider(node){if(!node)return;var a=bgLum(node);if(a!=null&&(best==null||a<best))best=a;
      var b=borderLum(node);if(b!=null&&(best==null||b<best))best=b;}
    consider(el);var ch=el.children||[];for(var i=0;i<ch.length&&i<3;i++)consider(ch[i]);
    return best;}
  // Given a row of option buttons, returns the label of the ONE that's visually
  // selected (a dark fill or dark border) among light siblings. Returns '' when
  // ambiguous — 0 or 2+ dark buttons, or a dark theme — so callers fall back.
  function darkSelectedLabel(kids,labelFn){
    if(!kids||kids.length<2)return '';
    var min=999,minI=-1,darkCount=0;
    for(var i=0;i<kids.length;i++){var L=markLum(kids[i]);if(L==null)continue;
      if(L<90)darkCount++;if(L<min){min=L;minI=i;}}
    if(minI<0||min>90||darkCount!==1)return ''; // need exactly one dark button
    return labelFn(kids[minI])||'';
  }
  // True when the element sits inside a size-guide / measurement chart. Those
  // blocks are full of "Size" headings and S/M/L cells that must NEVER be mistaken
  // for the shopper's selected size.
  function inGuide(el){
    var n=el;
    for(var up=0;up<6 && n && n.getAttribute;up++){
      var c=((n.getAttribute('class')||'')+' '+(n.getAttribute('id')||'')).toLowerCase();
      if(/guide|chart|measure|conversion|sizetable|size-table|size_table|how-?to-?measure/.test(c))return true;
      n=n.parentElement;
    }
    return false;
  }
  // Reads the "Size: L" / "Beden: M" / "المقاس: L" readout shown once a size is
  // picked. Requires an explicit COLON so headings ("Size Guide", "Size Chart")
  // and bare chart cells never match, and ignores anything inside a size guide.
  function selectedFromSummary(){
    var els=document.querySelectorAll('div,span,p,label,dt,dd,strong,b,h2,h3');
    for(var i=0;i<els.length && i<1800;i++){var el=els[i];var t=(el.textContent||'').replace(/\s+/g,' ').trim();
      if(t.length>28||inGuide(el))continue;
      var m=t.match(/^(size|beden|numara|talla|taille|المقاس|مقاس|قياس)\s*[:：]\s*(.+)$/i);
      if(m){var tok=sizeToken(m[2]);if(tok)return tok;}}
    return '';
  }
  // Reads a "Color: White" / "Renk: Siyah" / "اللون: أسود" label — reliable even
  // when the colour options are photos rather than colour swatches.
  // Strips a size fragment that a store glues onto a colour value, e.g.
  // Shein's "Multicolor / Size: L" -> "Multicolor".
  function dropSize(s){return (s||'')
    .replace(/\s*[\/|,]?\s*(size|beden|numara|talla|taille|المقاس|مقاس|قياس|القياس)\s*[:：].*$/i,'')
    .trim();}
  function colorFromSummary(){
    function clean(s){return dropSize((s||'').replace(/\s+/g,' ').replace(/\s*[>›»].*$/,'').trim());}
    function ok(v){return v && v.length<=24 && !/^(select|choose|pick|seç|seçin|اختر)/i.test(v);}
    var bestV='',bestLen=1e9;
    var els=document.querySelectorAll('div,span,p,label,dt,dd,strong,b,h1,h2,h3');
    for(var i=0;i<els.length && i<2200;i++){var el=els[i];var t=(el.textContent||'').replace(/\s+/g,' ').trim();
      if(t.length>44||inGuide(el))continue;
      // "Renk: Siyah" in one element
      var m=t.match(/^(colou?r|renk|اللون|لون)\s*[:：]\s*(.+)$/i);
      if(m){var v=clean(m[2]);if(ok(v)&&t.length<bestLen){bestV=v;bestLen=t.length;}continue;}
      // A bare "Renk"/"Color" label — the value is in the next element or the parent.
      if(/^(colou?r|renk|اللون|لون)\s*[:：]?$/i.test(t)){
        var sib=el.nextElementSibling;var sv=sib?clean(sib.textContent):'';
        if(!ok(sv)&&el.parentElement){
          sv=clean(el.parentElement.textContent).replace(/^(colou?r|renk|اللون|لون)\s*[:：]?\s*/i,'').trim();}
        if(ok(sv)&&sv.length<bestLen){bestV=sv;bestLen=sv.length;}
      }
    }
    return bestV;
  }
  // Removes stock/discount badges from an option label so "CN36 9 left" -> "CN36".
  // No word boundaries around the badge, so one GLUED to the size on either side
  // ("L3 left", "5 leftEUR38") still strips cleanly.
  function cleanLabel(s){
    s=(s||'').replace(/\s+/g,' ').trim();
    return s.replace(/\d{1,3}\s*(left|remaining|in\s?stock|pcs?|piece|pieces)/ig,' ')
            .replace(/almost sold out|sold out|out of stock/ig,' ')
            .replace(/-?\d{1,3}\s*%(\s*off)?/ig,' ')
            .replace(/(^|[^a-z])(hot|new|sale|trends?)([^a-z]|$)/ig,' ')
            .replace(/\s+/g,' ').trim();
  }
  // A stock/discount badge shown ON a size button ("5 left", "Sold out", "-20%",
  // "HOT") — a separate child element we must drop so it doesn't glue to the size.
  function isBadge(t){
    t=(t||'').replace(/\s+/g,' ').trim();
    return /^(\d{1,3}\s*(left|remaining|in\s?stock|pcs?|pieces?)|almost sold out|sold out|out of stock|-?\d{1,3}\s*%(\s*off)?|hot|new|sale)$/i.test(t);
  }
  // Reads an option button's label from its OWN text + non-badge children, so a
  // "5 left" badge element sitting inside the button is excluded rather than glued
  // onto the size (which is why badge-tagged sizes used to go missing).
  function optionLabel(el){
    if(!el)return '';
    var parts=[],ch=el.childNodes||[];
    for(var i=0;i<ch.length;i++){var n=ch[i];
      if(n.nodeType===3){parts.push(n.nodeValue||'');continue;}      // text node
      if(n.nodeType===1){var t=(n.textContent||'').replace(/\s+/g,' ').trim();
        if(isBadge(t))continue;                                       // skip badge child
        parts.push(t);}
    }
    var s=parts.join(' ').replace(/\s+/g,' ').trim();
    return cleanLabel(s||(el.textContent||''));                       // fallback + final strip
  }
  // A real size LOOKS like a size: a letter size (S/M/L/XL/One Size/Small…) or a
  // label containing a number (30, CN36, EU38, "9-12M (74-80 cm)", "2-3Y"). This
  // keeps the store's own labels VERBATIM while rejecting stray words scraped from
  // reviews or descriptions ("niece", "birthday", "true") that have no size shape.
  function sizeLike(t){
    t=(t||'').replace(/\s+/g,' ').trim();
    if(!t||t.length>24)return false;
    if(/[a-z][A-Z]/.test(t))return false; // glued words, e.g. "SizeDefault"
    if(/^(size|colou?r|guide|chart|select|choose|add|buy|cart|default|regular|curve|plus|petite|tall)$/i.test(t))return false;
    if(/^(os|one ?size|free ?size|xxs|xs|s|m|l|xl|xxl|xxxl|xxxxl|[2-6]xl|small|medium|large|x-?small|x-?large|xx-?large|xxx-?large)$/i.test(t.replace(/\s+/g,'')))return true;
    return /\d/.test(t); // has a number → size-shaped (waist / EU / age / cm)
  }
  // True only when a set of tokens really looks like a SIZE list — letter sizes
  // (S/M/L…), region sizes (EUR38/CN36), age ranges, or a numeric RUN of 3+ in a
  // sane range. Rejects stray single numbers ("1","5" = a cart badge / colour
  // count) so we never show junk; the field is then left empty to type.
  function coherentSizes(opts){
    if(!opts||opts.length<2)return false;
    var good=0,nums=[];
    for(var i=0;i<opts.length;i++){var c=(opts[i]||'').replace(/\s*\(.*\)$/,'').replace(/\s+/g,'').toLowerCase();
      if(/^(xxs|xs|s|m|l|xl|xxl|xxxl|xxxxl|[2-6]xl|os|onesize|freesize|small|medium|large|x-?small|x-?large)$/.test(c))good++;
      else if(/^[a-z]{2,3}\d{1,3}(\.\d)?$/.test(c))good++;                                   // EUR38, CN36, UK10
      else if(/^\d{1,2}[-–]\d{1,2}(y|years?|m|months?|t)?$|^\d{1,3}(y|years?|m|months?|t)$/.test(c))good++; // ages
      else if(/^\d{1,3}(\.\d)?$/.test(c))nums.push(parseFloat(c));
    }
    if(nums.length>=3){var mn=Math.min.apply(null,nums),mx=Math.max.apply(null,nums);if(mn>=1&&mx<=60)good+=nums.length;} // numeric run
    return good>=2 && good>=opts.length*0.6;
  }
  // BEST way to read sizes: find the "Size" (Beden/المقاس) label, then grab the
  // option buttons sitting under it VERBATIM — so the chip shows exactly what the
  // store shows ("9-12M (74-80 cm)"), for any sizing system the product uses.
  function looksLikeOption(t){return sizeLike(t);}
  function buttonsIn(scope){
    var conts=scope.querySelectorAll('ul,ol,div,section,fieldset');
    var arr=[scope]; for(var c=0;c<conts.length&&c<600;c++)arr.push(conts[c]);
    var best=null;
    for(var i=0;i<arr.length;i++){var kids=arr[i].children;if(!kids||kids.length<2||kids.length>30)continue;
      var opts=[],sel='',good=0;
      for(var j=0;j<kids.length;j++){var raw=optionLabel(kids[j]);
        if(looksLikeOption(raw)){good++;if(opts.indexOf(raw)<0)opts.push(raw);if(marked(kids[j]))sel=raw;}}
      // The black-filled button is the strongest signal on Shein, so it wins over a
      // class guess. 'dark' marks the selection as visually confirmed (→ trusted).
      var dark=false,dl=darkSelectedLabel(kids,optionLabel);
      if(dl&&looksLikeOption(dl)){sel=dl;dark=true;}
      // Prefer the level exposing the MOST individual options — that's the leaf
      // row of buttons (XS,S,M,L…), not an outer wrapper that concatenates them.
      if(good>=2 && good>=kids.length*0.6 && opts.length>=2 && (!best||opts.length>best.options.length))
        best={options:opts,selected:sel,dark:dark};}
    return best;
  }
  function optionGroup(kwRe){
    var labels=document.querySelectorAll('div,span,p,label,dt,dd,h2,h3,strong,b,legend');
    for(var i=0;i<labels.length && i<2500;i++){var lab=labels[i];
      var lt=(lab.textContent||'').replace(/\s+/g,' ').trim();
      if(lt.length>36||!kwRe.test(lt)||inGuide(lab))continue;
      var node=lab.parentElement;
      for(var up=0;up<4 && node;up++){var g=buttonsIn(node);if(g)return g;node=node.parentElement;}}
    return null;
  }
  function detectSize(){
    var best=null;
    var conts=document.querySelectorAll('ul,ol,div,section,fieldset');
    for(var i=0;i<conts.length && i<1200;i++){if(inGuide(conts[i]))continue;var kids=conts[i].children;if(!kids||kids.length<2||kids.length>24)continue;
      var cnt=0,sel='',opts=[];for(var j=0;j<kids.length;j++){var tok=sizeToken(optionLabel(kids[j]));
        if(tok){cnt++;if(opts.indexOf(tok)<0)opts.push(tok);if(marked(kids[j]))sel=tok;}}
      // Black-filled = selected on Shein; overrides the class guess and is trusted.
      var dark=false,dl=darkSelectedLabel(kids,function(k){return sizeToken(optionLabel(k));});
      if(dl){sel=dl;dark=true;}
      if(cnt>=2 && cnt>=kids.length*0.5 && (!best||cnt>best.cnt))best={cnt:cnt,sel:sel,opts:opts,dark:dark};}
    var summary=selectedFromSummary();
    if(best){if(!best.sel&&summary){best.sel=summary;best.dark=true;}return {has:true,sel:best.sel,opts:best.opts,sure:!!best.dark};}
    if(summary)return {has:true,sel:summary,opts:[summary],sure:true};
    return {has:false,sel:'',opts:[],sure:false};
  }
  function drawerVis(el){try{var r=el.getBoundingClientRect();if(r.width<=0||r.height<=0)return false;
    var cs=getComputedStyle(el);return cs.visibility!=='hidden'&&cs.display!=='none'&&(+cs.opacity||1)>0.05;}catch(e){return false;}}
  // Stores like Bershka/Inditex DON'T render sizes on the page — they only build
  // the list when you tap EKLE, which opens an overlay/drawer. We auto-tap it, then
  // read the sizes straight out of that opened dialog. sizeToken() ignores headers
  // ("ÖLÇÜLERİ GÖR") and stock badges, so only real size cells survive.
  function drawerSizes(){
    var boxes=document.querySelectorAll('[role="dialog"],[aria-modal="true"],[class*="drawer" i],[class*="modal" i],[class*="sheet" i],[class*="overlay" i],[class*="dialog" i],[class*="flyout" i],[class*="popup" i]');
    var best=null;
    for(var i=0;i<boxes.length && i<160;i++){var box=boxes[i];if(!drawerVis(box)||inGuide(box))continue;
      var cells=box.querySelectorAll('li,button,a,div,span,[role="button"],[role="option"],[role="radio"],[role="menuitem"],[role="menuitemradio"],label');
      var opts=[],hits=[],selTok='';
      for(var j=0;j<cells.length && j<250;j++){var el=cells[j];if(!drawerVis(el))continue;
        var tok=sizeToken((el.textContent||'').replace(/\s+/g,' ').trim());
        if(!tok)continue;
        if(opts.indexOf(tok)<0)opts.push(tok);
        hits.push(el);
        if(marked(el))selTok=tok;}
      if(opts.length>=2 && (!best||opts.length>best.opts.length)){
        if(!selTok)selTok=darkSelectedLabel(hits,function(k){return sizeToken((k.textContent||'').replace(/\s+/g,' ').trim());});
        best={opts:opts,sel:selTok};}}
    return best;
  }
  // A colour swatch's NAME can sit on the element, a nested node, or an <img>
  // alt (Zara puts "Siyah"/"Black" in an aria-label on an inner element, not the
  // wrapper). Strips "Select …"/"… colour" wrappers.
  function swatchLabel(el){
    var lab=(el.getAttribute&&(el.getAttribute('aria-label')||el.getAttribute('title'))||'').trim();
    if(!lab && el.querySelector){var q=el.querySelector('[aria-label],[title],img[alt]');
      if(q)lab=(q.getAttribute('aria-label')||q.getAttribute('title')||q.getAttribute('alt')||'').trim();}
    lab=lab.replace(/^(select|choose|seç|seçin|pick|renk|colou?r)\s+/i,'')
           .replace(/\s+(colou?r|renk|seçildi|selected|is\s+selected)\s*$/i,'')
           .replace(/\s+/g,' ').trim();
    return (lab && lab.length<=24 && /[a-zA-ZçğışöüÇĞİŞÖÜ]/.test(lab))?lab:'';
  }
  function detectColor(){
    var conts=document.querySelectorAll('ul,ol,div,section');
    for(var i=0;i<conts.length && i<900;i++){if(inGuide(conts[i]))continue;var kids=conts[i].children;if(!kids||kids.length<2||kids.length>20)continue;
      var sw=0,sel='',opts=[];for(var j=0;j<kids.length;j++){var el=kids[j];
        // A swatch is a small element with a background colour OR a small <img>
        // thumbnail (Shein/Trendyol show colour options as tiny product photos).
        var isSw=false;
        var node=/background(-color)?\s*:/.test(el.getAttribute('style')||'')?el:el.querySelector('[style*="background-color"],[style*="background:"]');
        if(node){var r=node.getBoundingClientRect();if(r.width>0&&r.width<70&&r.height>0)isSw=true;}
        var img=el.querySelector&&el.querySelector('img');
        if(!isSw&&img){var ri=img.getBoundingClientRect();if(ri.width>0&&ri.width<96&&ri.height>0&&ri.height<130)isSw=true;}
        if(isSw){sw++;var lab=swatchLabel(el);
          if(lab&&opts.indexOf(lab)<0)opts.push(lab);
          if(marked(el))sel=lab;}}
      if(sw>=2 && sw>=kids.length*0.6){
        // Class-based "selected" often fails; fall back to the visually-marked
        // swatch (border/dot). We do NOT read a nearby colour-name text — on Zara
        // that's stale relative to the tapped colour and gives the wrong value.
        if(!sel)sel=darkSelectedLabel(kids,swatchLabel);
        return {has:true,sel:sel,opts:opts};}}
    return {has:false,sel:'',opts:[]};
  }
  // OPTION 1 (best): read the COMPLETE colour + size lists straight from the
  // store's own embedded product JSON (Shein's gbRawData / __NEXT_DATA__ etc.),
  // including out-of-stock options — not just the rendered buttons.
  function collectRoots(){
    var roots=[];
    try{if(window.gbRawData)roots.push(window.gbRawData);}catch(e){}
    try{if(window.__NEXT_DATA__)roots.push(window.__NEXT_DATA__);}catch(e){}
    try{if(window.__INITIAL_STATE__)roots.push(window.__INITIAL_STATE__);}catch(e){}
    var ss=document.querySelectorAll('script');
    for(var i=0;i<ss.length && i<80;i++){var tx=ss[i].textContent||'';
      if(tx.length<120||tx.length>6000000)continue;
      if(!/attr_value_name|multiLevelSaleAttribute|saleAttr/.test(tx))continue;
      var m=tx.match(/[=:]\s*(\{[\s\S]*\})\s*;?\s*$/);
      if(m){try{roots.push(JSON.parse(m[1]));}catch(e){}}}
    return roots;
  }
  function jsonVariants(){
    var out={colors:[],sizes:[]},seenC={},seenS={};
    function add(list,seen,name,max){name=(name==null?'':(''+name)).replace(/\s+/g,' ').trim();
      if(name && name.length<=max && !seen[name]){seen[name]=1;list.push(name);}}
    function isValArr(a){return a&&a.length&&typeof a[0]==='object'&&(a[0].attr_value_name!=null||a[0].attr_value_name_en!=null);}
    var roots,stack;try{roots=collectRoots();}catch(e){return out;}
    stack=roots.slice();var guard=0,visited=(typeof WeakSet!=='undefined')?new WeakSet():null;
    while(stack.length && guard<300000){guard++;var node=stack.pop();
      if(!node||typeof node!=='object')continue;
      if(visited){if(visited.has(node))continue;visited.add(node);}
      if(node.attr_name!=null||node.attr_name_en!=null){
        var an=((node.attr_name_en||node.attr_name||'')+'').toLowerCase();
        var vals=node.attr_value_list||node.attrValueList;
        if(isValArr(vals)){for(var k=0;k<vals.length;k++){var vn=vals[k].attr_value_name||vals[k].attr_value_name_en;
          if(/colou?r/.test(an))add(out.colors,seenC,vn,40);
          else if(/size/.test(an))add(out.sizes,seenS,vn,24);}}
      }
      for(var key in node){var v=node[key];if(v&&typeof v==='object'&&stack.length<150000)stack.push(v);}}
    return out;
  }
  // Inditex stores (Bershka/Zara/Pull&Bear/Stradivarius) DON'T render the size
  // buttons on the page — they build them from the product JSON only when EKLE is
  // tapped. That JSON is already embedded on load, so we read the sizes straight
  // from it (any `sizes`/`availableSizes` array of objects) — no drawer to open.
  function jsonRoots(){
    var roots=[];
    var G=['__INITIAL_STATE__','__PRELOADED_STATE__','__NEXT_DATA__','__NUXT__','__APP_INITIAL_STATE__','__APOLLO_STATE__','__data','gbRawData'];
    for(var g=0;g<G.length;g++){try{if(window[G[g]])roots.push(window[G[g]]);}catch(e){}}
    var ss=document.querySelectorAll('script');
    for(var i=0;i<ss.length && i<160;i++){var s=ss[i];var tx=s.textContent||'';
      if(tx.length<60||tx.length>9000000)continue;
      var ty=(s.getAttribute('type')||'').toLowerCase();
      if(ty.indexOf('json')>=0){try{roots.push(JSON.parse(tx));}catch(e){}continue;}
      if(/["']sizes?["']\s*:/.test(tx)){var m=tx.match(/[=:]\s*(\{[\s\S]*\})\s*;?\s*$/);
        if(m){try{roots.push(JSON.parse(m[1]));}catch(e){}}}}
    return roots;
  }
  function jsonSizes(){
    var roots;try{roots=jsonRoots();}catch(e){return [];}
    // Never descend into OTHER products (recommendations / related / carousels),
    // whose sizes would otherwise be merged into THIS product's list.
    var SKIP=/relat|recomm|recomend|similar|carousel|cross|upsell|up_?sell|bundle|accessor|youmay|also_?like|alsolike|viewed|bought|suggest|lookbook|outfit|combine|complementary|matching_?product|more_?product/i;
    // The current product's id (Inditex URLs carry it) — lets us keep only sizes
    // that belong to THIS product, not a global size catalogue on the page.
    var pid='';var mm=location.href.match(/p0*(\d{5,})\.html/i)||location.href.match(/-p-?(\d{5,})/i)||location.href.match(/(\d{6,})\.html/i);
    if(mm)pid=mm[1];
    function sysOf(t){t=(t||'').replace(/\s+/g,'').toLowerCase();
      if(/^(xxs|xs|s|m|l|xl|xxl|xxxl|xxxxl|[2-6]xl|os|onesize|freesize|small|medium|large)$/.test(t))return 'L';
      if(/^\d/.test(t))return 'N';return 'O';}
    function harvest(arr){var got=[];
      for(var i=0;i<arr.length;i++){var it=arr[i];if(it==null)continue;var nm;
        if(typeof it==='string'||typeof it==='number')nm=''+it;
        else if(typeof it==='object')nm=(it.name!=null?it.name:(it.label!=null?it.label:(it.value!=null?it.value:(it.size!=null?it.size:(it.text!=null?it.text:(it.description!=null?it.description:''))))));
        else continue;
        var tok=sizeToken((''+nm).replace(/\s+/g,' ').trim());
        if(tok)got.push(tok);}
      return got;}
    function idMatch(node){if(!pid)return false;
      try{var f=['id','productId','productCode','reference','partNumber','detailId','code','catentryId'];
        for(var i=0;i<f.length;i++){var v=node[f[i]];if(v!=null&&(''+v).indexOf(pid)>=0)return true;}}catch(e){}
      return false;}
    // Collect each size array as its OWN candidate group (don't merge blindly).
    var groups=[],stack=[];
    for(var r=0;r<roots.length;r++)stack.push({n:roots[r],pid:false});
    var guard=0,visited=(typeof WeakSet!=='undefined')?new WeakSet():null;
    var KEYS=['sizes','availableSizes','sizeList','allSizes','sizesList','sizeOptions'];
    while(stack.length && guard<400000){guard++;var fr=stack.pop();var node=fr.n;
      if(!node||typeof node!=='object')continue;
      if(visited){if(visited.has(node))continue;visited.add(node);}
      var here=fr.pid||idMatch(node);
      for(var ki=0;ki<KEYS.length;ki++){var arr=node[KEYS[ki]];
        if(arr&&typeof arr.length==='number'&&arr.length>=2){var got=harvest(arr);
          if(got.length>=2&&got.length>=arr.length*0.6)groups.push({sizes:got,pid:here});}}
      for(var key in node){if(SKIP.test(key))continue;var v=node[key];
        if(v&&typeof v==='object'&&stack.length<200000)stack.push({n:v,pid:here});}}
    if(!groups.length)return [];
    // Prefer groups that belong to THIS product; else fall back to all of them.
    var pool=[];for(var i=0;i<groups.length;i++)if(groups[i].pid)pool.push(groups[i]);
    if(!pool.length)pool=groups;
    // A product's real size list repeats across its colour variants, so pick the
    // size-set that occurs MOST often — not a one-off global catalogue / stray list.
    var freq={},rep={};
    for(var i=0;i<pool.length;i++){var sig=pool[i].sizes.slice().sort().join('');
      freq[sig]=(freq[sig]||0)+1;if(!rep[sig])rep[sig]=pool[i].sizes;}
    var bestSig=null,bestN=-1;
    for(var s in freq){if(freq[s]>bestN){bestN=freq[s];bestSig=s;}}
    var chosen=rep[bestSig]||[];
    // NEVER mix size systems (letters like L/XL vs numbers like 34/36). A single
    // garment uses one system, so keep the dominant one — that's the product's.
    var L=[],N=[],O=[];
    for(var i=0;i<chosen.length;i++){var sy=sysOf(chosen[i]);
      if(sy==='L')L.push(chosen[i]);else if(sy==='N')N.push(chosen[i]);else O.push(chosen[i]);}
    var keep=chosen;
    if(L.length&&N.length)keep=(L.length>=N.length?L:N).concat(O);
    var seen={},outp=[];
    for(var i=0;i<keep.length;i++){if(!seen[keep[i]]){seen[keep[i]]=1;outp.push(keep[i]);}}
    return outp;
  }
  // COLOUR names from the embedded product JSON — for Inditex stores (Stradivarius/
  // Zara/Bershka…) the swatches show no text, but each colour variant carries its
  // NAME (+ its own sizes) in the page data. Scoped to THIS product like jsonSizes.
  function jsonColors(){
    var roots;try{roots=jsonRoots();}catch(e){return [];}
    var SKIP=/relat|recomm|recomend|similar|carousel|cross|upsell|up_?sell|bundle|accessor|youmay|also_?like|alsolike|viewed|bought|suggest|lookbook|outfit|combine|complementary|matching_?product|more_?product/i;
    var pid='';var mm=location.href.match(/p0*(\d{5,})\.html/i)||location.href.match(/-p-?(\d{5,})/i)||location.href.match(/(\d{6,})\.html/i);
    if(mm)pid=mm[1];
    function idMatch(node){if(!pid)return false;
      try{var f=['id','productId','productCode','reference','partNumber','detailId','code','catentryId'];
        for(var i=0;i<f.length;i++){var v=node[f[i]];if(v!=null&&(''+v).indexOf(pid)>=0)return true;}}catch(e){}
      return false;}
    function clean(nm){nm=(''+(nm==null?'':nm)).replace(/\s+/g,' ').trim();
      return (nm&&nm.length<=40&&/[a-zA-ZçğışöüâîûÇĞİŞÖÜ]/.test(nm)&&!/^https?:/i.test(nm))?nm:'';}
    var groups=[],stack=[];
    for(var r=0;r<roots.length;r++)stack.push({n:roots[r],pid:false});
    var guard=0,visited=(typeof WeakSet!=='undefined')?new WeakSet():null;
    var KEYS=['colors','colours','productColors','colorList','colorsInfo'];
    while(stack.length && guard<400000){guard++;var fr=stack.pop();var node=fr.n;
      if(!node||typeof node!=='object')continue;
      if(visited){if(visited.has(node))continue;visited.add(node);}
      var here=fr.pid||idMatch(node);
      for(var ki=0;ki<KEYS.length;ki++){var arr=node[KEYS[ki]];
        if(arr&&typeof arr.length==='number'&&arr.length>=1&&typeof arr[0]==='object'){
          // A product colour variant carries a NAME plus its own sizes / id.
          var variants=0,names=[];
          for(var i=0;i<arr.length;i++){var it=arr[i];if(!it||typeof it!=='object')continue;
            if(it.sizes||it.productSizes||it.sizeList||it.id!=null||it.colorId!=null||it.image)variants++;
            var nm=clean(it.name||it.colorName||it.label||it.description||it.styleName);
            if(nm)names.push(nm);}
          if(names.length>=1&&variants>=Math.max(1,Math.floor(arr.length*0.5)))
            groups.push({names:names,pid:here});}}
      for(var key in node){if(SKIP.test(key))continue;var v=node[key];
        if(v&&typeof v==='object'&&stack.length<200000)stack.push({n:v,pid:here});}}
    if(!groups.length)return [];
    var pool=[];for(var i=0;i<groups.length;i++)if(groups[i].pid)pool.push(groups[i]);
    if(!pool.length)pool=groups;
    var best=pool[0];for(var i=1;i<pool.length;i++)if(pool[i].names.length>best.names.length)best=pool[i];
    var seen={},out=[];
    for(var i=0;i<best.names.length;i++){var k=best.names[i].toLowerCase();if(!seen[k]){seen[k]=1;out.push(best.names[i]);}}
    return out;
  }
  // Trendyol keeps the product (with its size variants + colour) in a global
  // state object. Read it directly and scope to THIS product so we don't pull in
  // sizes from "recommended" products. Turkish labels are handled either way.
  // Deep-search a product object for a "Renk"/"Color" attribute value.
  function deepColor(root){
    var stack=[root],guard=0,visited=(typeof WeakSet!=='undefined')?new WeakSet():null;
    while(stack.length && guard<50000){guard++;var n=stack.pop();if(!n||typeof n!=='object')continue;
      if(visited){if(visited.has(n))continue;visited.add(n);}
      var k=((n.key||n.name||n.attributeName||'')+'').toLowerCase();
      if(/^renk$|^colou?r$/.test(k)){var v=n.value||n.attributeValue||n.beautifiedValue;
        if(v!=null){v=(''+v).trim();if(v&&v.length<=40&&!/^\d+$/.test(v))return v;}}
      for(var key in n){var v2=n[key];if(v2&&typeof v2==='object'&&stack.length<25000)stack.push(v2);}}
    return '';
  }
  function trendyolVariants(){
    var out={colors:[],sizes:[]};
    try{
      var s=window.__PRODUCT_DETAIL_APP_INITIAL_STATE__||window.__NEXT_DATA__||window.__INITIAL_STATE__;
      if(!s)return out;
      var p=s.product||(s.props&&s.props.pageProps&&s.props.pageProps.product)||(s.productDetail&&s.productDetail.product)||s;
      var vs=p.allVariants||p.variants||[];
      for(var i=0;i<vs.length;i++){var v=vs[i];if(!v)continue;
        var val=(v.value!=null)?v.value:v.attributeValue;
        if(val!=null){val=(''+val).replace(/\s+/g,' ').trim();
          if(val && val.length<=24 && val.split(' ').length<=4 && out.sizes.indexOf(val)<0)out.sizes.push(val);}}
      var col=p.color||p.colorName||p.productColor||p.mainColor||'';
      if(!col)col=deepColor(p);
      if(col){col=(''+col).replace(/\s+/g,' ').trim();if(col&&col.length<=40)out.colors.push(col);}
    }catch(e){}
    return out;
  }
  var dc=detectColor();
  var jv=trendyolVariants();
  if(jv.sizes.length<2 && jv.colors.length<1)jv=jsonVariants();
  // SIZE options: embedded JSON first (complete), then buttons under the "Size"
  // label, then the heuristic scan.
  var sizeKw=/^(size|beden|numara|المقاس|مقاس|قياس)\b/i;
  var sg=optionGroup(sizeKw);
  var ds=detectSize();
  var jsz=[];try{jsz=jsonSizes();}catch(e){} // sizes from embedded product JSON (Inditex)
  var dw=drawerSizes(); // sizes read from an OPENED size drawer, if one happens to be open
  // Options list, most reliable first: sizes read straight from the store's own
  // embedded product JSON (complete, incl. Bershka/Inditex that hide the buttons),
  // then an open size drawer, then the RENDERED size buttons when we confidently
  // read the selected one, then the Shein-style JSON list, then the heuristic scan.
  var sizeOptions;
  if(jsz.length>=2)sizeOptions=jsz;
  else if(dw&&dw.opts.length>=2)sizeOptions=dw.opts;
  else if(sg&&sg.dark&&sg.options.length>=2)sizeOptions=sg.options;
  else if(jv.sizes.length>=2)sizeOptions=jv.sizes;
  else if(sg&&sg.options.length>=2)sizeOptions=sg.options;
  else sizeOptions=ds.opts;
  // Selected size, most-reliable first: (1) the store's own "Size: X" readout,
  // (2) the black-filled button Shein highlights (visually confirmed), then (3) a
  // class-based guess — which is fragile on obfuscated stores, so it's flagged
  // unsure and the shopper confirms it with a tap.
  var sizeSummary=selectedFromSummary();
  var sgDark=(sg&&sg.dark)?sg.selected:'';
  var dsDark=ds.sure?ds.sel:'';
  var size=sizeSummary||sgDark||dsDark||(dw&&dw.sel)||(sg&&sg.selected)||ds.sel||'';
  var sizeSure=!!sizeSummary||!!sgDark||!!dsDark;
  // Never rewrite a real option; only normalise a STRAY value (a badge left on it,
  // e.g. "L3 left" -> "L") and only drop it when it's junk that isn't an option.
  if(size && sizeOptions.indexOf(size)<0){var stok=sizeToken(size); if(stok)size=stok;}
  if(size && sizeOptions.indexOf(size)<0 && size.length>16){size='';sizeSure=false;}
  // Guarantee the selected value is one of the chips the shopper can tap.
  if(size && sizeOptions.indexOf(size)<0 && sizeLike(size))sizeOptions=sizeOptions.concat([size]);
  // Only keep the size chips if they truly look like a size list — otherwise
  // leave it empty for the shopper to type, rather than showing junk ("1"/"5").
  if(!coherentSizes(sizeOptions)){sizeOptions=[];size='';sizeSure=false;}
  var hasSize=sizeOptions.length>=2;
  // COLOUR: real colour NAMES from the JSON make a safe picker; else prefill only.
  // Shein's own JSON first, then the Inditex colour list (Stradivarius/Zara…).
  var jcz=[];try{jcz=jsonColors();}catch(e){}
  var colorOptions=(jv.colors.length>=2)?jv.colors:(jcz.length>=2?jcz:[]);
  // Selected colour: prefer the store's "Colour: X" readout / JSON-LD page colour /
  // highlighted swatch — the LIVE selection. Only fall back to the first catalogue
  // colour when the product has a SINGLE colour; never guess it when several exist,
  // as that ignores the user's pick.
  var colorSummary=colorFromSummary();
  var ldColor=color; // colour from JSON-LD Product — often the DEFAULT variant,
  // not the one the shopper picked, so it's the LAST resort (Zara/Mango update
  // the swatch client-side without changing the JSON-LD).
  var colorClass=colorFromClass();
  var colorPos=colorFromPosition(title); // short colour label above the title
  // Confident selected-colour signals (the store's own "Renk: X" readout or the
  // visually-selected swatch). JSON-LD colour is the DEFAULT variant, so when a
  // product HAS a colour picker (dc.has) but we can't confidently read the pick,
  // leave it blank for the shopper to type — never auto-fill the wrong default.
  var confident=colorSummary||colorFromLabel()||dc.sel;
  color=confident||colorClass||colorPos||(dc.has?'':ldColor)||'';
  var colorSure=!!confident||!!colorClass||!!colorPos;
  if(!color && jv.colors.length===1){color=jv.colors[0];colorSure=true;}
  else if(!color && jcz.length===1){color=jcz[0];colorSure=true;}
  color=dropSize(color); // never let a size fragment ride along in the colour
  if(color.length>24){color='';colorSure=false;}
  var hasColor=dc.has||!!color||colorOptions.length>=2;
  // Compact context for the AI fallback (used only when detection is weak). It
  // lists the options we found, marks the selected one, and includes any label.
  // The product's SKU, so the admin can find the exact item to order. Prefer the
  // "SKU: …" value the store prints on the page (Shein shows "SKU: sa25101…"),
  // then the embedded goods_sn / sku code, then JSON-LD sku, then — only as a last
  // resort — the numeric product id from the URL.
  function detectSku(){
    // Only Shein needs a SKU for now — skip it on every other store.
    if(!/shein/i.test(location.hostname||''))return '';
    var html='';try{html=(document.documentElement&&document.documentElement.outerHTML)||'';}catch(e){}
    var txt='';try{txt=(document.body&&document.body.innerText)||'';}catch(e){}
    var m;
    // 1) A visible "SKU: sa2510…" label (desktop). Value starts with a LETTER so we
    //    get the real SKU ("sa…"), never the numeric product id.
    m=txt.match(/\bSKU\b\s*[:#]?\s*([A-Za-z][A-Za-z0-9._\-]{5,40})/i);
    if(m)return m[1].trim();
    // 2) The SKU code straight from the page SOURCE — the value is in the mobile
    //    page's data even though m.shein.com doesn't render the "SKU:" label. The
    //    char-class gap tolerates quotes/backslashes/colons in the embedded JSON.
    m=html.match(/(?:goods_sn|goodsSn|sku_?code|skuCode|productSn|productRelationID)[\\"'\s:=]{1,8}([A-Za-z0-9._\-]{6,40})/i);
    if(m)return m[1];
    // 3) A "SKU" label that's in the markup but collapsed/hidden on mobile.
    m=html.match(/>\s*SKU\s*[:#]?\s*(?:<[^>]*>\s*)*([A-Za-z][A-Za-z0-9._\-]{5,40})/i);
    if(m)return m[1];
    // 4) embedded product JSON via globals (goods_sn / sku code).
    try{var roots=collectRoots(),stack=roots.slice(),g=0,seen=(typeof WeakSet!=='undefined')?new WeakSet():null;
      while(stack.length&&g<60000){g++;var n=stack.pop();if(!n||typeof n!=='object')continue;if(seen){if(seen.has(n))continue;seen.add(n);}
        var v=n.goods_sn||n.goodsSn||n.sku_code||n.skuCode||n.productSn;if(v){v=(''+v).trim();if(v&&v.length<=64)return v;}
        for(var k in n){var val=n[k];if(val&&typeof val==='object'&&stack.length<30000)stack.push(val);}}
    }catch(e){}
    // 5) JSON-LD sku / mpn (NOT productID — that's the numeric goods id).
    try{var sc=document.querySelectorAll('script[type="application/ld+json"]');
      for(var i=0;i<sc.length&&i<20;i++){var d;try{d=JSON.parse(sc[i].textContent||'null');}catch(e){continue;}
        var arr=Array.isArray(d)?d:[d];
        for(var j=0;j<arr.length;j++){var x=arr[j];if(x&&typeof x==='object'&&/product/i.test(''+(x['@type']||''))){
          var s=x.sku||x.mpn||x.gtin13||x.gtin;if(s){s=(''+s).trim();if(s&&s.length<=64)return s;}}}}
    }catch(e){}
    // 6) last resort: numeric product id from the URL.
    var mm=(location.href||'').match(/[-\/]p-?(\d{5,})/i)||(location.href||'').match(/\/(\d{6,})\.html/);
    return mm?mm[1]:'';
  }
  function aiBlob(){
    function mark(opts,sel){return opts.map(function(o){return o+(sel&&o===sel?' [SELECTED]':'');}).join(' | ');}
    var p=[];
    if(title)p.push('TITLE: '+title.slice(0,120));
    var ss=selectedFromSummary(); if(ss)p.push('SIZE LABEL: '+ss);
    var cs=colorFromSummary(); if(cs)p.push('COLOR LABEL: '+cs);
    // Only mark a selection the heuristic is confident about; an unsure guess must
    // not tell the AI the wrong option is already picked.
    if(sizeOptions.length)p.push('SIZE OPTIONS: '+mark(sizeOptions,sizeSure?size:'')); else if(size)p.push('SIZE: '+size);
    if(colorOptions.length)p.push('COLOR OPTIONS: '+mark(colorOptions,colorSure?color:'')); else if(color)p.push('COLOR: '+color);
    return p.join('\n');
  }
  // Stradivarius keeps its data in a Redux store we can't read reliably (it
  // returned another product's colours/sizes), so don't guess — the shopper types
  // the colour and size themselves (size required, colour optional free text).
  if(/stradivarius/i.test(location.hostname||'')){
    sizeOptions=[];colorOptions=[];size='';color='';sizeSure=false;colorSure=false;
    hasSize=true;hasColor=false;
  }
  HeamaCapture.postMessage(JSON.stringify({url:location.href,title:title,image:image,price:price,currency:currency,color:color,size:size,sku:detectSku(),sizeSure:sizeSure,colorSure:colorSure,hasColor:hasColor,hasSize:hasSize,sizeOptions:sizeOptions,colorOptions:colorOptions,ai:aiBlob()}));
})();
''';

  // Injects a stylesheet that hides store clutter (app-download banners, promo
  // popups, the store's own bottom action bar, and "you may also like" sections).
  // A persistent <style> also applies to elements the SPA adds later.
  static const _declutter = r'''
(function(){
  // 1) hide known banners/popups/recommendation sections by class
  var sel=[
   '[class*="download" i]','[class*="gotoApp" i]','[class*="openApp" i]','[class*="open-app" i]','[class*="landing-app" i]','[class*="app-banner" i]','[class*="appBanner" i]','[class*="downloadBar" i]','[class*="download-bar" i]','[class*="back-to-app" i]',
   '[class*="coupon-pop" i]','[class*="newcomer" i]','[class*="new-user" i]','[class*="lure" i]','[class*="j-push" i]','[class*="float-icon" i]','[class*="floatIcon" i]',
   '[class*="recommend" i]','[class*="you-may" i]','[class*="youmay" i]','[class*="also-like" i]','[class*="also_like" i]','[class*="similar-items" i]','[class*="get-the-look" i]'
  ];
  // 2) On Shein: also hide its own cart + wishlist(favourite) icons and its ads,
  //    for a clean capture-only view. Cart/bag use EXACT aria-labels + href so the
  //    product's "Add to bag" button (label "Add to cart") is never hidden.
  var host=location.hostname||'';
  var isShein=/shein/i.test(host);
  var isTrendyol=/trendyol/i.test(host);
  if(isShein){
    sel=sel.concat([
     'a[href*="/cart" i]','a[href*="wishlist" i]','a[href*="/wishlist" i]','a[href*="save-list" i]','a[href*="/user/wishlist" i]',
     '[aria-label="Cart" i]','[aria-label="Bag" i]','[aria-label="Shopping Bag" i]','[aria-label="Shopping Cart" i]','[aria-label="السلة"]','[aria-label="الحقيبة"]','[aria-label="عربة التسوق"]',
     '[aria-label*="wishlist" i]','[aria-label*="favourite" i]','[aria-label*="favorite" i]','[aria-label="المفضلة"]','[aria-label*="save for later" i]',
     '[class*="cart-icon" i]','[class*="cartIcon" i]','[class*="header-cart" i]','[class*="cart-num" i]','[class*="cartNum" i]','[class*="bag-icon" i]','[class*="bagIcon" i]','[class*="bag-num" i]',
     '[class*="wishlist" i]','[class*="save-icon" i]','[class*="saveIcon" i]','[class*="collect-icon" i]',
     '[class*="coupon" i]','[class*="flash-sale" i]','[class*="flashSale" i]','[class*="countdown" i]','[class*="promotion" i]','[class*="promo-" i]','[class*="activity-banner" i]','[class*="activityBanner" i]','[class*="ad-banner" i]','[class*="adBanner" i]','[class*="advertise" i]','[class*="free-ship" i]','[class*="freeShip" i]','[class*="bottom-banner" i]'
    ]);
  }
  if(isTrendyol){
    // NOTE: do NOT use broad class matches like [class*="basket"] or
    // [class*="campaign"] here — Trendyol's price + sticky bar containers use
    // those words, so they would hide the PRICE. We hide the favourite/cart
    // icons + ads only, and hide the "Sepete Ekle" BUTTON surgically below.
    sel=sel.concat([
     'a[href*="/sepet" i]','a[href*="/favoriler" i]','a[href*="favori-urunler" i]','a[href*="hesabim/favori" i]',
     '[aria-label*="favori" i]','[aria-label*="beğen" i]','[title*="favori" i]',
     '[class*="favorite-icon" i]','[class*="favoriteIcon" i]','[class*="fav-icon" i]','[class*="wishlist" i]',
     '[class*="ad-banner" i]','[class*="adBanner" i]','[class*="advertise" i]','[class*="app-download" i]','[class*="coupon" i]','[class*="countdown" i]'
    ]);
  }
  var rule=sel.join(',')+'{display:none !important;visibility:hidden !important;height:0 !important;width:0 !important;overflow:hidden !important;}';
  var ex=document.getElementById('heama-declutter');
  if(ex){ex.textContent=rule;}
  else{var s=document.createElement('style');s.id='heama-declutter';s.textContent=rule;(document.head||document.documentElement).appendChild(s);}
  // On Shein ONLY, hide the store's sticky product footer — the fixed "Add to
  // Cart" bar carrying the heart(favourite)/store icons. We capture Shein from
  // its embedded data, so the bar is redundant. Find the add label, walk up to
  // its fixed/sticky container, hide it.
  //
  // Trendyol is DELIBERATELY excluded: its sticky bottom bar also holds the
  // PRICE (and size), so hiding it would hide the price from the shopper. Same
  // reason we never hide Zara/Mango's bar.
  if(isShein){
    var nodes=document.querySelectorAll('button,a,div,span,[role="button"]');
    for(var i=0;i<nodes.length && i<2000;i++){
      var t=(nodes[i].textContent||'').replace(/\s+/g,' ').trim().toLowerCase();
      if(t.length===0 || t.length>44)continue;
      if(!/(add to cart|add to bag|add to basket|أضف|أضيفي|加入购物车)/.test(t))continue;
      var el=nodes[i];
      for(var up=0;up<7 && el;up++){
        var cs;try{cs=getComputedStyle(el);}catch(e){cs=null;}
        if(cs&&(cs.position==='fixed'||cs.position==='sticky')){el.style.setProperty('display','none','important');break;}
        el=el.parentElement;
      }
    }
  }
  // Trendyol: hide ONLY the "Sepete Ekle" (add to basket) BUTTON itself, leaving
  // the price (its sibling in the sticky bar) fully visible.
  if(isTrendyol){
    var btns=document.querySelectorAll('button,a,[role="button"]');
    for(var i=0;i<btns.length && i<2500;i++){
      var t=(btns[i].textContent||'').replace(/\s+/g,' ').trim().toLowerCase();
      if(t.length===0 || t.length>28)continue;
      if(/(sepete ekle|sepete at|hemen al)/.test(t)){
        btns[i].style.setProperty('display','none','important');
        btns[i].style.setProperty('visibility','hidden','important');
      }
    }
  }
})();
''';


  // A real Android Chrome MOBILE user-agent. It must match the WebView's actual
  // engine (Chrome), or bot-protection (Akamai on H&M) sees an iPhone-UA-on-Chrome
  // mismatch and returns "Access Denied". The "Mobile" token still gets the mobile
  // layout, and dropping the WebView "wv" marker avoids app-only walls.
  static const _mobileUa =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36';

  // Detects a product page by its content (works on any store): the OpenGraph
  // product type or a JSON-LD Product block. Posts '1'/'0' back to Flutter.
  static const _probe = r'''
(function(){
  var isP=false;
  var og=document.querySelector('meta[property="og:type"]');
  if(og && /product/i.test(og.getAttribute('content')||''))isP=true;
  if(!isP){var ss=document.querySelectorAll('script[type="application/ld+json"]');
    for(var i=0;i<ss.length && i<25;i++){var t=ss[i].textContent||'';
      if(/"@type"\s*:\s*("?Product"?|\[[^\]]*"Product")/i.test(t)){isP=true;break;}}}
  // The store's own add-to-cart control is a strong product-page signal.
  if(!isP && document.querySelector('[class*="add-to-cart" i],[class*="addtocart" i],[class*="add-to-bag" i],[class*="addtobag" i],[class*="add-to-basket" i],[id*="addtocart" i],[id*="add-to-cart" i],[data-testid*="add-to-cart" i],[data-testid*="addToCart" i]'))isP=true;
  if(!isP){var btns=document.querySelectorAll('button,a,[role="button"]');
    for(var b=0;b<btns.length && b<500;b++){var bt=(btns[b].textContent||'').replace(/\s+/g,' ').trim().toLowerCase();
      if(bt && bt.length<=22 && /^(sepete ekle|ekle|add to cart|add to bag|add to basket|add to my cart|añadir|agregar|ajouter au panier|in den warenkorb|aggiungi al carrello)$/.test(bt)){isP=true;break;}}}
  try{HeamaProbe.postMessage(isP?'1':'0');}catch(e){}
})();
''';

  @override
  void initState() {
    super.initState();
    final rawStart = (widget.initialUrl != null && widget.initialUrl!.isNotEmpty)
        ? widget.initialUrl!
        : widget.store.url;
    final start = _forceTurkey(rawStart) ?? rawStart;
    _url = start;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      // Identify as a mobile Safari browser so stores serve their responsive
      // MOBILE layout (Zara, Mango, H&M… switch layout by user-agent, and the
      // default WebView UA can get the desktop or a WebView-flagged page).
      ..setUserAgent(_mobileUa)
      ..addJavaScriptChannel('HeamaCapture', onMessageReceived: _onScrape)
      ..addJavaScriptChannel('HeamaProbe', onMessageReceived: (m) {
        final p = m.message == '1';
        if (p != _isProduct && mounted) setState(() => _isProduct = p);
      })
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          // Force Zara onto the Turkey store (TL). Guard against a redirect loop
          // by not re-forcing a URL we just forced.
          final fixed = _forceTurkey(req.url);
          if (fixed != null && fixed != _forcedUrl) {
            _forcedUrl = fixed;
            _controller.loadRequest(Uri.parse(fixed));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onProgress: (p) => setState(() => _progress = p / 100),
        onUrlChange: (c) {
          final url = c.url ?? _url;
          // New page — assume not a product until the probe says otherwise.
          setState(() {
            _url = url;
            _isProduct = false;
          });
          // Once we've landed on a Turkey URL, clear the guard so a later
          // geo-redirect to /iq/ gets forced again.
          if (_forceTurkey(url) == null) _forcedUrl = null;
          _runDeclutter(); // SPA navigation re-renders the store's bars
          _runProbe();
        },
        onPageStarted: (_) => setState(() => _progress = 0.05),
        onPageFinished: (_) => _onPageFinished(),
      ));

    // Load after any store-specific prep (e.g. forcing Shein to price in USD).
    _bootstrapLoad(start);

    // SPA sites (Mango, Zara) change page without a reload/URL event, so keep
    // re-checking whether the current page is a product to drive the button.
    _probeTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) _controller.runJavaScript(_probe);
    });
  }

  /// Sets Shein's currency cookie to USD before loading, so every Shein site
  /// (incl. ar.shein.com, which otherwise shows a local/Gulf currency) renders
  /// prices in USD — matching the store's configured USD source currency.
  Future<void> _bootstrapLoad(String start) async {
    final host = (Uri.tryParse(start)?.host ?? '').toLowerCase();
    if (host.contains('shein')) {
      try {
        final cookies = WebViewCookieManager();
        for (final domain in const ['.shein.com', 'ar.shein.com', 'm.shein.com']) {
          await cookies.setCookie(
            WebViewCookie(name: 'currency', value: 'USD', domain: domain, path: '/'),
          );
        }
      } catch (_) {
        // best-effort — still load the page below
      }
    }
    if (host.contains('trendyol')) {
      // From Iraq, Trendyol switches to its international storefront (other
      // currency/catalogue). Pin the cookies to the Turkey store (storefront 1,
      // TR, Turkish → prices in TL) so it always opens the Turkey region.
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
      } catch (_) {
        // best-effort — still load the page below
      }
    }
    if (mounted) _controller.loadRequest(Uri.parse(start));
  }

  @override
  void dispose() {
    _probeTimer?.cancel();
    super.dispose();
  }

  /// Re-checks product signals a few times as the SPA renders.
  void _runProbe() {
    for (final ms in [300, 1200, 2600]) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (mounted) _controller.runJavaScript(_probe);
      });
    }
  }

  void _onPageFinished() {
    if (mounted) setState(() => _progress = 1);
    _runDeclutter();
    _runProbe();
    if (_pendingCapture) {
      _pendingCapture = false;
      // Give the SPA a moment to render price/variants, then capture like the
      // Add-to-Heama button (reads the rendered page, works where the server can't).
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _capture();
      });
    }
  }

  /// Runs the declutter script a few times to catch elements that load or
  /// re-render a moment after navigation.
  void _runDeclutter() {
    for (final ms in [0, 800, 1800, 3500]) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (mounted) _controller.runJavaScript(_declutter);
      });
    }
  }

  void _capture() {
    setState(() => _capturing = true);
    // Scroll to the top so the product photo is visible, THEN scrape.
    _controller.runJavaScript('window.scrollTo(0,0);');
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _controller.runJavaScript(_scraper);
    });
    // Safety: clear the spinner if the channel never replies.
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _capturing = false);
    });
  }

  /// Heart tap: toggle the current product in favourites. Removing needs no
  /// scrape; adding scrapes the page (like Add to Heama) to grab its details.
  void _favorite() {
    final favs = context.read<FavoritesProvider>();
    if (favs.isFavorite(_favId)) {
      favs.removeById(_favId);
      return;
    }
    _pendingFavorite = true;
    _controller.runJavaScript('window.scrollTo(0,0);');
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _controller.runJavaScript(_scraper);
    });
  }

  Future<void> _saveFavorite(ScrapeResult r) async {
    final favs = context.read<FavoritesProvider>();
    final l = AppLocalizations.of(context);
    final url = r.url.isNotEmpty ? r.url : _url;
    int iqd = 0;
    try {
      if (r.price != null && r.price! > 0) {
        final priced = await CaptureApi(context.read<ApiClient>()).price(
          storeKey: widget.store.id,
          sourceUrl: url,
          title: r.title,
          imageUrl: r.image,
          sourcePrice: r.price!,
          sourceCurrency: r.currency,
        );
        iqd = priced.iqdPrice.round();
      }
    } catch (_) {
      // pricing is best-effort — still save the favourite
    }
    if (!mounted) return;
    favs.toggle(FavoriteItem(
      id: _favIdFor(url),
      name: r.title.isNotEmpty ? r.title : widget.store.name,
      store: widget.store.name,
      storeId: widget.store.storeId,
      sourceUrl: url,
      priceIqd: iqd,
      imageUrl: r.image,
    ));
    if (mounted) showHeamaToast(context, l.savedToFav);
  }

  void _onScrape(JavaScriptMessage message) {
    if (!mounted) return;
    ScrapeResult r;
    try {
      r = ScrapeResult.fromJson(jsonDecode(message.message) as Map<String, dynamic>);
    } catch (_) {
      r = ScrapeResult(url: _url, title: '', image: '');
    }

    // Heart flow: save this product to favourites, don't open the sheet.
    if (_pendingFavorite) {
      _pendingFavorite = false;
      _saveFavorite(r);
      return;
    }

    if (r.title.isEmpty && !r.hasPrice) {
      // The page gave us nothing — let the server try the URL as a fallback.
      setState(() => _capturing = false);
      showCaptureSheet(context, initialUrl: _url, storeKey: widget.store.id, autoServerFetch: true);
      return;
    }
    _openCaptureSheet(r);
  }

  /// Opens the capture sheet with the sizes/colours read straight off the page.
  /// The full option list comes from the product's own size buttons + embedded
  /// JSON, and the shopper confirms the pick with a tap — no AI in the loop.
  void _openCaptureSheet(ScrapeResult r) {
    if (!mounted) return;
    setState(() => _capturing = false);
    showCaptureSheet(
      context,
      initialUrl: r.url.isNotEmpty ? r.url : _url,
      initialTitle: r.title,
      initialImage: r.image,
      initialPrice: r.price,
      initialCurrency: (r.currency != null && r.currency!.isNotEmpty)
          ? r.currency
          : widget.store.currency,
      initialColor: r.color,
      initialSize: r.size,
      initialSku: r.sku,
      offersColor: r.hasColor,
      offersSize: r.hasSize,
      colorOptions: r.colorOptions,
      sizeOptions: r.sizeOptions,
      storeKey: widget.store.id,
    );
  }

  void _openCart() {
    final shell = context.read<ShellController>();
    shell.goToTab(ShellController.cart);
    Navigator.pop(context);
  }

  /// Ask for a product link, load it in the WebView, then auto-capture it — so a
  /// pasted link is read exactly like the Add-to-Heama button (which can see the
  /// rendered page, unlike the server that Shein blocks).
  Future<void> _pasteLink() async {
    final l = AppLocalizations.of(context);
    final field = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.productLink, style: AppFonts.display(fontSize: 17)),
        content: TextField(
          controller: field,
          autofocus: true,
          keyboardType: TextInputType.url,
          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(hintText: 'https://…', isDense: true),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel,
                style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, field.text.trim()),
            child: Text(l.fetchDetails,
                style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
          ),
        ],
      ),
    );
    if (!mounted || url == null || url.isEmpty) return;
    var u = url;
    if (!u.startsWith('http')) u = 'https://$u';
    final uri = Uri.tryParse(u);
    if (uri == null || !uri.hasAuthority) return;
    // A pasted Zara /iq/ link → force it to the Turkey store (TL).
    final forced = _forceTurkey(uri.toString());
    setState(() => _pendingCapture = true);
    _controller.loadRequest(Uri.parse(forced ?? uri.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final host = Uri.tryParse(_url)?.host.replaceFirst('www.', '') ?? widget.store.name;

    return Scaffold(
      backgroundColor: AppColors.cloud,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(host),
            if (_progress < 1)
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                minHeight: 2.5,
                backgroundColor: AppColors.cloud,
                color: AppColors.pomegranate,
              ),
            Expanded(child: WebViewWidget(controller: _controller)),
            _footer(l),
          ],
        ),
      ),
    );
  }

  // ---- Top browser bar ----
  Widget _topBar(String host) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          BackChip(onTap: () => Navigator.pop(context), size: 34),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => openUrl(_url),
              child: Container(
                height: 40,
                padding: const EdgeInsetsDirectional.only(start: 6, end: 10),
                decoration: BoxDecoration(
                  color: AppColors.cloud,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // store glyph
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.store.glyphColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(widget.store.glyph,
                          style: AppFonts.display(fontSize: 11, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.lock, size: 11, color: AppColors.green),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(host,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                    const Icon(Icons.open_in_new, size: 14, color: AppColors.muted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _round(Icons.refresh, () => _controller.reload()),
        ],
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 19, color: AppColors.ink),
        ),
      );

  // ---- Sticky footer: [Cart] [Paste link] [Add to Heama] ----
  Widget _footer(AppLocalizations l) {
    final cartCount = context.watch<CartProvider>().count;
    final canCapture = _isProductPage && !_capturing;
    final isFav = context.watch<FavoritesProvider>().isFavorite(_favId);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [BoxShadow(color: Color(0x14211B3E), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            // My Cart (icon + badge)
            _pill(
              onTap: _openCart,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 23, color: AppColors.ink),
                  if (cartCount > 0)
                    PositionedDirectional(
                      end: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: const BoxDecoration(
                            color: AppColors.pomegranate, shape: BoxShape.circle),
                        child: Text('$cartCount',
                            textAlign: TextAlign.center,
                            style: AppFonts.body(
                                fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Paste a link
            _pill(
              onTap: _pasteLink,
              child: const Icon(Icons.link_rounded, size: 23, color: AppColors.ink),
            ),
            const SizedBox(width: 8),
            // Save to favourites (heart) — only on a product page, like Add to
            // Cart. Off a product page there's nothing to save, so it's disabled.
            _pill(
              onTap: _isProductPage ? _favorite : null,
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 23,
                color: !_isProductPage
                    ? AppColors.line
                    : (isFav ? AppColors.pomegranate : AppColors.ink),
              ),
            ),
            const SizedBox(width: 8),
            // Add to Heama (primary, product pages only)
            Expanded(
              child: GestureDetector(
                onTap: canCapture ? _capture : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isProductPage ? AppColors.pomegranate : AppColors.line,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: _isProductPage
                        ? [BoxShadow(color: AppColors.pomegranate.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5))]
                        : null,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_capturing)
                          const SizedBox(
                              width: 17, height: 17,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        else
                          Icon(Icons.add_shopping_cart,
                              size: 18, color: _isProductPage ? Colors.white : AppColors.muted),
                        const SizedBox(width: 9),
                        Text(l.addToCart,
                            style: AppFonts.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _isProductPage ? Colors.white : AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({required VoidCallback? onTap, required Widget child}) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(15)),
          alignment: Alignment.center,
          child: child,
        ),
      );
}
