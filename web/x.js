const CACHE_NAME = 'puvi-cache-v1';

self.addEventListener('install', event => {
  self.skipWaiting(); // Immediately activate
});

self.addEventListener('activate', event => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request) // 🔁 Try live network request first
      .then(networkResponse => {
        // ✅ If response is valid, update the cache
        if (
          networkResponse &&
          networkResponse.status === 200 &&
          event.request.method === 'GET' &&
          event.request.url.startsWith(self.location.origin)
        ) {
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, networkResponse.clone());
          });
        }
        return networkResponse;
      })
      .catch(() => {
        // ❌ If network fails (offline), fallback to cache
        return caches.match(event.request);
      })
  );
});
