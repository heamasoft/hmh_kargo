// "Add to HMH Kargo cart" on shopping websites in Safari.
//
// One button, fixed at the bottom of the page. Tapping it hands the page the
// shopper is on to the HMH Kargo app (hmhkargo://add?url=…), which reads the
// product and opens its add sheet there. Nothing is read from the page and
// nothing is sent anywhere else; the button only passes the address along.
(function () {
  if (window.top !== window.self) return; // not inside the site's own frames
  if (document.getElementById('hmh-kargo-add')) return;

  var lang = (navigator.language || 'en').toLowerCase();
  var label = 'Add to HMH Kargo cart';
  if (lang.indexOf('ar') === 0) label = 'أضف إلى سلة HMH Kargo';
  else if (lang.indexOf('ku') === 0 || lang.indexOf('ckb') === 0) label = 'زیادکردن بۆ سەبەتەی HMH Kargo';

  var button = document.createElement('button');
  button.id = 'hmh-kargo-add';
  button.type = 'button';
  button.setAttribute('dir', 'auto');
  button.textContent = label;
  button.addEventListener('click', function (e) {
    e.preventDefault();
    e.stopPropagation();
    window.location.href = 'hmhkargo://add?url=' + encodeURIComponent(window.location.href);
  }, true);

  function mount() {
    if (document.body && !document.getElementById('hmh-kargo-add')) {
      document.body.appendChild(button);
    }
  }
  mount();
  // Shop pages redraw themselves as the shopper browses; put the button back
  // if a redraw drops it.
  new MutationObserver(mount).observe(document.documentElement, { childList: true, subtree: true });
})();
