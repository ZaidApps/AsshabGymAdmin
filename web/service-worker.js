// Custom service worker to handle caching properly for localization
const CACHE_NAME = 'ashhab-gym-admin-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/assets/',
];

// Install event - cache resources
self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch event - serve from cache, but allow network for dynamic content
self.addEventListener('fetch', function(event) {
  // Don't cache API calls or language preference changes
  if (event.request.url.includes('firestore') || 
      event.request.url.includes('language') ||
      event.request.method !== 'GET') {
    event.respondWith(fetch(event.request));
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        // Cache hit - return response
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
