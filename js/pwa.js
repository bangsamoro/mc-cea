/* ---------------------------------------------------------------------------
   MC-CEA portal — install prompt
   Shows the "install / add to home screen" bar to a FIRST-TIME visitor only.
   Once it has been shown the flag lands in localStorage and it never returns.

   Three cases:
     Chrome / Edge / Android  -> real install prompt (beforeinstallprompt)
     iOS Safari               -> manual Share > Add to Home Screen steps
     plain http://            -> installing is impossible, so it says so once

   Requires HTTPS (or localhost): browsers refuse to install, and refuse to
   register a service worker, on an insecure origin.
   --------------------------------------------------------------------------- */
(function () {
  'use strict';

  var SEEN_KEY = 'mccea:install-prompt-seen';
  var PLACEHOLDERS = ['localhost', '127.0.0.1', '[::1]'];

  /* this file lives at <site>/js/pwa.js, so its own URL gives us the site root.
     That keeps the paths below correct on the home page and on services/*.html */
  var SRC = document.currentScript ? document.currentScript.src : '';
  var BASE = SRC.replace(/js\/pwa\.js.*$/, '');

  var standalone = window.matchMedia('(display-mode: standalone)').matches ||
                   window.navigator.standalone === true;
  var secure = location.protocol === 'https:' ||
               PLACEHOLDERS.indexOf(location.hostname) !== -1;
  var ua = navigator.userAgent;
  var isIOS = /iPad|iPhone|iPod/.test(ua) ||
              (ua.indexOf('Mac') === 0 && 'ontouchend' in document);
  var isSafari = isIOS && !/CriOS|FxiOS|EdgiOS|OPiOS/.test(ua);

  /* --- service worker: installability needs one, and it needs a secure origin --- */
  if ('serviceWorker' in navigator && secure) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register(BASE + 'sw.js').catch(function () { /* ignore */ });
    });
  }

  function seen() {
    try { return localStorage.getItem(SEEN_KEY) === '1'; } catch (e) { return true; }
  }
  function markSeen() {
    try { localStorage.setItem(SEEN_KEY, '1'); } catch (e) { /* ignore */ }
  }

  if (standalone || seen()) return;   /* already installed, or already asked */

  var bar = null;
  var deferred = null

  function build(title, message, actionLabel, onAction) {
    if (bar) return;

    bar = document.createElement('div');
    bar.className = 'install-bar';
    bar.setAttribute('role', 'dialog');
    bar.setAttribute('aria-label', title);

    var icon = document.createElement('img');
    icon.className = 'install-bar__icon';
    icon.src = BASE + 'img/icon-192.png';
    icon.alt = '';
    icon.setAttribute('aria-hidden', 'true');

    var text = document.createElement('div');
    text.className = 'install-bar__text';
    var strong = document.createElement('strong');
    strong.textContent = title;
    var span = document.createElement('span');
    span.textContent = message;
    text.appendChild(strong);
    text.appendChild(span);

    var actions = document.createElement('div');
    actions.className = 'install-bar__actions';

    if (actionLabel) {
      var go = document.createElement('button');
      go.type = 'button';
      go.className = 'btn btn-primary';
      go.textContent = actionLabel;
      go.addEventListener('click', onAction);
      actions.appendChild(go);
    }

    var no = document.createElement('button');
    no.type = 'button';
    no.className = 'btn btn-secondary';
    no.textContent = actionLabel ? 'Not now' : 'Got it';
    no.addEventListener('click', function () { bar.hidden = true; });
    actions.appendChild(no);

    bar.appendChild(icon);
    bar.appendChild(text);
    bar.appendChild(actions);
    document.body.appendChild(bar);

    markSeen();   /* first time only - never shown again on this device */
  }

  /* --- Chrome / Edge / Android: a real install prompt is available --- */
  window.addEventListener('beforeinstallprompt', function (event) {
    event.preventDefault();
    deferred = event;
    build(
      'Install the MC-CEA portal',
      'Add it to your home screen for one-tap access.',
      'Install',
      function () {
        if (!deferred) return;
        deferred.prompt();
        var choice = deferred.userChoice;
        if (choice && choice.then) {
          choice.then(function () { deferred = null; });
        }
        bar.hidden = true;
      }
    );
  });

  window.addEventListener('appinstalled', function () {
    markSeen();
    if (bar) bar.hidden = true;
  });

  /* --- iOS Safari never fires beforeinstallprompt: give the manual steps --- */
  if (isSafari) {
    window.addEventListener('load', function () {
      var msg = isIOS
        ? 'Tap Share, then "Add to Home Screen".'
        : 'Use your browser menu, then "Install app" or "Add to Home Screen".';
      build('Add the MC-CEA portal to your home screen', msg, null, null);
    });
  }

  /* --- plain http:// : browsers refuse to install; say so once, not silently --- */
  if (!secure && !isIOS) {
    window.addEventListener('load', function () {
      build(
        'Install the MC-CEA portal',
        'Installing needs a secure address - open the https:// version of this page.',
        null, null
      );
    });
  }
})();
