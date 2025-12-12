// Ultra-minimal service worker - resolves instantly
// No functionality, just exists to prevent Flutter timeout

const CACHE_NAME = 'empty-cache';
const RESOURCES = {};

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', () => self.clients.claim());