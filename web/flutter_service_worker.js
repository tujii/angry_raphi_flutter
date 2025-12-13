// AngryRaphi Service Worker with optimized caching strategy
// Version: 2.3.0

const CACHE_NAME = 'angryraphi-cache-v2.3.0';
const RUNTIME_CACHE = 'angryraphi-runtime-v2.3.0';

// Critical resources to cache on install
const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png'
];

// Install event - cache critical resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        // Cache critical resources, but don't fail if any fail
        return Promise.allSettled(
          PRECACHE_URLS.map(url => 
            cache.add(url).catch(err => {
              console.warn(`Failed to cache ${url}:`, err);
            })
          )
        );
      })
      .then(() => self.skipWaiting())
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME && cacheName !== RUNTIME_CACHE) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event - network first with cache fallback for better fresh content
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Skip cross-origin requests (let browser handle them)
  if (url.origin !== location.origin) {
    event.respondWith(fetch(request));
    return;
  }
  
  // Skip Firebase and API requests from caching (but still fetch them)
  if (url.pathname.includes('/firebase/') || 
      url.pathname.includes('/api/') ||
      url.hostname === 'firestore.googleapis.com' ||
      url.hostname === 'firebase.googleapis.com' ||
      url.hostname.endsWith('.firebaseio.com') ||
      url.hostname.endsWith('.cloudfunctions.net')) {
    event.respondWith(fetch(request));
    return;
  }
  
  event.respondWith(
    // Network first strategy for HTML, cache for other assets
    (request.destination === 'document' || request.url.endsWith('.html'))
      ? networkFirstStrategy(request)
      : cacheFirstStrategy(request)
  );
});

// Network first, fallback to cache
async function networkFirstStrategy(request) {
  try {
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      const cache = await caches.open(RUNTIME_CACHE);
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch (error) {
    const cachedResponse = await caches.match(request);
    return cachedResponse || new Response('Offline', { status: 503 });
  }
}

// Cache first, fallback to network
async function cacheFirstStrategy(request) {
  const cachedResponse = await caches.match(request);
  if (cachedResponse) {
    return cachedResponse;
  }
  
  try {
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      const cache = await caches.open(RUNTIME_CACHE);
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch (error) {
    return new Response('Network error', { status: 503 });
  }
}