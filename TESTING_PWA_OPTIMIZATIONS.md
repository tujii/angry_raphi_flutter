# Testing PWA Optimizations - AngryRaphi

This document provides instructions for testing and validating the PWA performance optimizations.

## Pre-Deployment Testing

### 1. Build Verification
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build with optimizations
flutter build web \
  --base-href / \
  --web-renderer canvaskit \
  --release \
  --dart-define=Dart2jsOptimization=O4 \
  --source-maps \
  --pwa-strategy=offline-first
```

### 2. Check Build Output Size
```bash
# Check total build size
du -sh build/web

# Check main.dart.js size (should be optimized)
ls -lh build/web/main.dart.js

# Verify icon sizes in build
ls -lh build/web/icons/
```

Expected Results:
- Icons should be ~664KB total (down from 4.5MB)
- Build should complete without errors
- Service worker should be generated/copied

### 3. Local Testing with Server

```bash
# Serve the built web app locally
cd build/web
python3 -m http.server 8000
```

Open in browser: http://localhost:8000

## Browser Testing

### Chrome DevTools Testing

1. **Network Tab Analysis**
   - Open DevTools (F12)
   - Go to Network tab
   - Disable cache (check "Disable cache")
   - Reload page (Ctrl+Shift+R)
   - Check:
     - Icon sizes (Icon-192.png should be ~152KB)
     - Total transfer size
     - Load time
     - Number of requests

2. **Application Tab - Service Worker**
   - Open DevTools → Application → Service Worker
   - Verify service worker is registered
   - Check: "angryraphi-cache-v2.3.0"
   - Click "Update" to force reload
   - Verify no errors in console

3. **Application Tab - Cache Storage**
   - Application → Cache Storage
   - Should see:
     - angryraphi-cache-v2.3.0
     - angryraphi-runtime-v2.3.0
   - Click on cache to see cached files
   - Verify critical resources are cached

4. **Lighthouse Audit**
   - Open DevTools → Lighthouse
   - Select "Progressive Web App" and "Performance"
   - Click "Generate report"
   
   Expected Scores:
   - Performance: 85-95+
   - PWA: 95-100
   - Best Practices: 90+

### Offline Testing

1. **Test Offline Functionality**
   - Load the app normally
   - Open DevTools → Network
   - Check "Offline" in Network tab
   - Reload the page
   - App should load from cache (except Firebase data)

2. **Service Worker Update Test**
   - Load app online
   - Make a change to HTML
   - Rebuild and redeploy
   - Reload page
   - New version should load after refresh

## Performance Metrics to Measure

### Before Optimizations (Baseline)
- First Load: ~6-8 seconds
- Icon transfer: ~4.5MB
- Asset transfer: ~1.4MB
- Total initial download: ~7-9MB
- Lighthouse Performance: 60-70

### After Optimizations (Expected)
- First Load: ~2-4 seconds (40-60% improvement)
- Icon transfer: ~664KB (85% reduction)
- Asset transfer: ~212KB (85% reduction)
- Total initial download: ~3-4MB (55-60% reduction)
- Lighthouse Performance: 85-95+

### Key Metrics to Track

1. **First Contentful Paint (FCP)**
   - Target: < 1.5s
   - Measure in Lighthouse

2. **Largest Contentful Paint (LCP)**
   - Target: < 2.5s
   - Measure in Lighthouse

3. **Time to Interactive (TTI)**
   - Target: < 3.5s
   - Measure in Lighthouse

4. **Total Blocking Time (TBT)**
   - Target: < 300ms
   - Measure in Lighthouse

5. **Cumulative Layout Shift (CLS)**
   - Target: < 0.1
   - Measure in Lighthouse

## Testing on Different Networks

### Fast 3G
```bash
# Chrome DevTools → Network → Throttling → Fast 3G
```
- Should load in < 5 seconds
- Service worker should cache properly

### Slow 3G
```bash
# Chrome DevTools → Network → Throttling → Slow 3G
```
- First load will be slow but acceptable
- Repeat visits should be fast from cache

## Firebase Hosting Verification

After deployment to Firebase:

### 1. Check Cache Headers
```bash
curl -I https://angryraphi.web.app/icons/Icon-192.png
```

Should see:
```
cache-control: public, max-age=31536000, immutable
```

### 2. Check Compression
```bash
curl -I -H "Accept-Encoding: gzip, deflate, br" https://angryraphi.web.app/main.dart.js
```

Should see:
```
content-encoding: br
```
or
```
content-encoding: gzip
```

### 3. Check Service Worker
```bash
curl https://angryraphi.web.app/flutter_service_worker.js
```

Should return the optimized service worker content.

## Mobile Device Testing

### iOS Safari
1. Open https://angryraphi.web.app
2. Check loading time
3. Add to Home Screen
4. Test as installed PWA
5. Verify offline functionality

### Android Chrome
1. Open https://angryraphi.web.app
2. Check loading time
3. Install prompt should appear
4. Install as PWA
5. Test as installed app
6. Verify offline functionality

## Troubleshooting

### Service Worker Not Updating

1. Unregister old service worker:
```javascript
// In browser console
navigator.serviceWorker.getRegistrations().then(registrations => {
  registrations.forEach(reg => reg.unregister())
})
```

2. Clear cache:
- DevTools → Application → Clear Storage → Clear site data

3. Hard reload:
- Ctrl+Shift+R (Windows/Linux)
- Cmd+Shift+R (Mac)

### Images Not Loading

1. Check image paths in build/web
2. Verify manifest.json is valid
3. Check browser console for 404 errors
4. Verify Firebase hosting configuration

### Performance Not Improved

1. Clear browser cache completely
2. Test in incognito mode
3. Run Lighthouse audit to identify bottlenecks
4. Check Network tab for large resources
5. Verify service worker is registered and caching

## Automated Testing Script

```bash
#!/bin/bash
# Quick PWA validation script

echo "🔍 Validating PWA Optimizations..."

# Check file sizes
echo "📦 Image Sizes:"
ls -lh web/icons/*.png | awk '{print $9, $5}'

# Validate JSON files
echo "✅ Validating JSON files:"
python3 -m json.tool firebase.json > /dev/null && echo "  - firebase.json: valid"
python3 -m json.tool web/manifest.json > /dev/null && echo "  - manifest.json: valid"

# Check JS syntax
echo "✅ Validating JavaScript:"
node --check web/flutter_service_worker.js && echo "  - flutter_service_worker.js: valid"

# Verify PNG files
echo "✅ Validating PNG files:"
file web/icons/*.png | grep -c "PNG image data"

echo "✨ Validation complete!"
```

## Success Criteria

✅ All JSON files are valid
✅ Service worker JS has no syntax errors
✅ All PNG files are valid and optimized
✅ Icons are < 200KB each
✅ Service worker caches critical resources
✅ Firebase headers are configured
✅ Lighthouse Performance > 85
✅ Lighthouse PWA > 95
✅ First load < 4 seconds on Fast 3G
✅ Repeat load < 1 second from cache
✅ Offline mode works for cached content

## Monitoring Post-Deployment

### Firebase Performance Monitoring
- Enable Firebase Performance in console
- Monitor real user metrics
- Track loading times across devices

### Analytics Events
- Track PWA install events
- Monitor page load times
- Track offline usage

### User Feedback
- Monitor user reports about loading times
- Check for any broken features
- Verify offline functionality works in production
