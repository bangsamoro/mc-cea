/* ---------------------------------------------------------------------------
   MC-CEA portal — service worker
   Required for the PWA install prompt, and makes the portal usable offline.

   Strategy: network-first, cache as fallback. The portal is updated by
   copying files to the server, so serving fresh content whenever the network
   is available matters more than instant loads. Bump CACHE when you want to
   discard everything clients have cached.
   --------------------------------------------------------------------------- */

var CACHE = 'mc-cea-v1';

var SHELL = [
  './',
  './index.html',
  './favicon.ico',
  './manifest.json',
  './css/style.css',
  './css/service.css',
  './img/ksumc-logo.png',
  './img/icon-192.png',
  './img/icon-512.png'
];

self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(CACHE)
      .then(function (cache) { return cache.addAll(SHELL); })
      .then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys()
      .then(function (keys) {
        return Promise.all(keys.filter(function (k) { return k !== CACHE; })
                               .map(function (k) { return caches.delete(k); }));
      })
      .then(function () { return self.clients.claim(); })
  );
});

self.addEventListener('fetch', function (event) {
  var request = event.request;

  if (request.method !== 'GET') return;
  if (new URL(request.url).origin !== self.location.origin) return;

  event.respondWith(
    fetch(request)
      .then(function (response) {
        var copy = response.clone();
        caches.open(CACHE)
          .then(function (cache) { cache.put(request, copy); })
          .catch(function () {});
        return response;
      })
      .catch(function () {
        return caches.match(request).then(function (hit) {
          if (hit) return hit;
          if (request.mode === 'navigate') return caches.match('./index.html');
          return Response.error();
        });
      })
  );
});
