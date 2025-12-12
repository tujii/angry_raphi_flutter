// Service Worker with version checking and auto-update support
// This ensures the PWA always loads the latest version

const CACHE_VERSION = '2.0.0+2'; // Match version from pubspec.yaml
const CACHE_NAME = `angry-raphi-cache-${CACHE_VERSION}`;
const RESOURCES = {}; // Will be populated by Flutter build

// Install event - activate immediately
self.addEventListener('install', (event) => {
  console.log(`[ServiceWorker] Installing version ${CACHE_VERSION}`);
  self.skipWaiting(); // Activate immediately without waiting
});

// Activate event - clean old caches and take control
self.addEventListener('activate', (event) => {
  console.log(`[ServiceWorker] Activating version ${CACHE_VERSION}`);
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          // Delete old caches that don't match current version
          if (cacheName !== CACHE_NAME && cacheName.startsWith('angry-raphi-cache-')) {
            console.log(`[ServiceWorker] Deleting old cache: ${cacheName}`);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      // Take control of all clients immediately
      return self.clients.claim();
    })
  );
});

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      // Return cached version or fetch from network
      return response || fetch(event.request);
    })
  );
});

// Message event - handle update checks from the app
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});