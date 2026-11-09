/// Turns down a website's cookie banner on the shopper's behalf.
///
/// The in-app browser shows other companies' public websites. Many of them ask
/// for consent to advertising cookies, and App Review read that banner as this
/// app asking to track (guideline 5.1.1(iv)). HMH KARGO tracks nobody, so the
/// answer is always no: the script presses the site's own "Reject all" /
/// "Only necessary" button and hides whatever banner is left, leaving the site
/// on the strictly necessary cookies it needs to show a page and keep a cart.
///
/// It runs several times per page, because consent banners load late. Every
/// step is wrapped, so a site it doesn't recognise is simply left alone.
const cookieDeclineJs = r'''
(function(){
  try{
    // Buttons that decline: site-specific first, then by their words.
    var ids=['#onetrust-reject-all-handler','.ot-pc-refuse-all-handler',
      '#CybotCookiebotDialogBodyButtonDecline','#didomi-notice-disagree-button',
      '.cmpboxbtnno','[data-testid="uc-deny-all-button"]','.sp_choice_type_REJECT_ALL',
      '[data-cookiefirst-action="reject"]','.cky-btn-reject','#truste-consent-required'];
    var clicked=false;
    ids.forEach(function(s){ try{ var b=document.querySelector(s); if(b&&b.offsetParent!==null){ b.click(); clicked=true; } }catch(e){} });
    var words=/^(reject all|reject|decline|decline all|deny|only necessary|necessary only|use necessary cookies only|refuse|tümünü reddet|reddet|sadece zorunlu|yalnızca zorunlu|zorunlu çerezler|rechazar|ablehnen|alle ablehnen|refuser|tout refuser|رفض|رفض الكل)$/i;
    var box=/cookie|consent|gdpr|kvkk|privacy|cerez|çerez|onetrust|cmp/i;
    if(!clicked){
      var nodes=document.querySelectorAll('button,a[role="button"],[role="button"],input[type="button"]');
      for(var i=0;i<nodes.length;i++){
        var n=nodes[i]; var t=(n.innerText||n.value||'').trim();
        if(!t||t.length>40||!words.test(t)) continue;
        var p=n, inBanner=false;
        for(var d=0;p&&d<8;d++,p=p.parentElement){
          if(box.test((p.id||'')+' '+(typeof p.className==='string'?p.className:''))){ inBanner=true; break; }
        }
        if(inBanner){ try{ n.click(); clicked=true; break; }catch(e){} }
      }
    }
    // Whatever banner is still up is hidden, and the page scrolls again.
    if(!document.getElementById('heama-no-consent')){
      var st=document.createElement('style'); st.id='heama-no-consent';
      st.textContent='#onetrust-consent-sdk,#onetrust-banner-sdk,.onetrust-pc-dark-filter,#CybotCookiebotDialog,#didomi-host,#usercentrics-root,.cookie-banner,.cookie-consent,.cookieConsent,.cookie-notice,#cookie-notice,#cookie-banner,.cc-window,.cky-consent-container,[class*="CookieBanner"],[class*="cookie-policy"],[id*="cookie-policy"],[class*="cookieBar"]{display:none!important;visibility:hidden!important}';
      (document.head||document.documentElement).appendChild(st);
    }
    try{ document.documentElement.style.overflow=''; if(document.body) document.body.style.overflow=''; }catch(e){}
  }catch(e){}
})();
''';

/// When to run [cookieDeclineJs] after a page finishes loading, in ms.
const cookieDeclineDelays = [0, 900, 2200, 4500];
