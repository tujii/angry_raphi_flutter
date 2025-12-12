# Testing Guide for PWA Auto-Update

This guide explains how to test the PWA auto-update mechanism in AngryRaphi.

## Prerequisites

- Flutter SDK installed
- Firebase CLI configured
- Access to the AngryRaphi Firebase project

## Test Scenario 1: New Deployment Auto-Update

### Setup
1. Ensure you have version 2.0.0+2 deployed
2. Open the app in a browser and let it fully load
3. Keep the browser tab open

### Steps
1. Update the version in `pubspec.yaml`:
   ```yaml
   version: 2.0.0+3
   ```

2. Update the version in `web/flutter_service_worker.js`:
   ```javascript
   const CACHE_VERSION = '2.0.0+3';
   ```

3. Build and deploy:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

4. Wait 30 seconds (or refresh the original browser tab)

### Expected Behavior
- Update banner should appear at the top: "🎉 Neue Version verfügbar!"
- Banner shows "Aktualisieren" button
- After 5 seconds, page auto-reloads
- Console logs show:
  ```
  [PWA] Checking for updates...
  [PWA] New version available, reloading...
  [ServiceWorker] Installing version 2.0.0+3
  ```

## Test Scenario 2: Manual Update Check

### Steps
1. Open Developer Console (F12)
2. Go to Application tab → Service Workers
3. Click "Update" button next to the service worker
4. Observe the update notification

### Expected Behavior
- Same update banner appears
- User can click "Aktualisieren" for immediate reload
- Auto-reload after 5 seconds if no action

## Test Scenario 3: App Startup Update Check

### Setup
1. Deploy a new version
2. Close all browser tabs
3. Wait 5+ minutes (to bypass check throttling)

### Steps
1. Open the app in a fresh browser tab
2. Watch the console logs

### Expected Behavior
- Console shows: `[PWA Update] Checking for service worker updates...`
- If new version available, update process starts
- Update banner appears automatically

## Test Scenario 4: Visibility Change Update Check

### Steps
1. Have the app open in a browser tab
2. Deploy a new version
3. Switch to another tab for a few seconds
4. Switch back to the app tab

### Expected Behavior
- Update check triggers on visibility change
- Update banner appears if new version detected

## Test Scenario 5: Cross-Platform Compatibility

### Mobile (iOS/Android)
1. Build the mobile app:
   ```bash
   flutter build ios --release
   # or
   flutter build apk --release
   ```

2. Run the app on a device

### Expected Behavior
- App compiles successfully (stub implementation used)
- No PWA update checks occur (mobile doesn't need them)
- No runtime errors related to service workers

## Test Scenario 6: Multiple Tabs

### Steps
1. Open the app in 3 different browser tabs
2. Deploy a new version
3. Wait or refresh one tab

### Expected Behavior
- Update banner appears in all tabs
- All tabs reload to the new version
- Service worker syncs across tabs

## Debugging

### Check Service Worker Status
1. Open DevTools (F12)
2. Go to Application → Service Workers
3. Verify:
   - Service worker is "activated and running"
   - Version number matches deployed version

### View Update Logs
In the browser console, filter for:
- `[PWA]` - JavaScript update handling
- `[ServiceWorker]` - Service worker lifecycle
- `[PWA Update]` - Flutter service logs

### Force Update
If automatic updates aren't working:
1. Open DevTools (F12)
2. Application → Service Workers
3. Check "Update on reload"
4. Refresh the page
5. Click "Unregister" then reload if needed

### Clear Cache
To completely reset:
1. DevTools → Application
2. Clear Storage → "Clear site data"
3. Close and reopen the browser

## Performance Testing

### Measure Update Check Impact
1. Open DevTools Performance tab
2. Start recording
3. Trigger an update check
4. Stop recording
5. Verify update check takes <50ms

### Network Impact
1. Open DevTools Network tab
2. Watch for requests to `/flutter_service_worker.js`
3. Should see HEAD/GET requests every 30 seconds
4. Each request should be <1KB

## Automated Testing (Future)

### Unit Tests
```dart
// Example test for PwaUpdateService
test('should check for updates on start', () async {
  final service = PwaUpdateService();
  await service.checkForUpdatesOnStart();
  // Verify update check was triggered
});
```

### Integration Tests
```dart
// Example integration test
testWidgets('app initializes with update check', (tester) async {
  await tester.pumpWidget(AngryRaphiApp());
  // Verify update service was called
});
```

## Troubleshooting Common Issues

### Issue: Update banner not appearing
**Possible causes:**
- Version numbers don't match between pubspec.yaml and service worker
- Service worker not registered properly
- Browser cache preventing new service worker registration

**Solutions:**
1. Verify version numbers match
2. Check browser console for errors
3. Clear site data and reload
4. Check if browser supports service workers

### Issue: Multiple reloads
**Cause:** Multiple tabs open when update triggers

**Solution:** This is expected behavior - all tabs reload to sync

### Issue: Update check too frequent
**Solution:** Increase check interval in:
- `web/pwa.js`: Change `setInterval` from 30000 (30s)
- `lib/services/pwa_update_service_web.dart`: Change `_checkIntervalMinutes` from 5

### Issue: Update banner in wrong language
**Solution:** Update text in `web/pwa.js` `showUpdateNotification()` function

## Version Compatibility

Ensure these browsers are tested:
- ✅ Chrome 88+ (desktop & mobile)
- ✅ Firefox 85+ (desktop & mobile)
- ✅ Safari 14+ (desktop & mobile)
- ✅ Edge 88+

## Monitoring in Production

### Key Metrics to Track
1. Update adoption rate (% users on latest version)
2. Time to update (how long until 90% of users updated)
3. Update failures (errors in console logs)
4. Service worker activation rate

### User Feedback
Monitor for:
- Users reporting old app behavior after deployment
- Users not seeing new features
- Excessive reload behavior

## Rollback Procedure

If update mechanism causes issues:

1. Revert to simple service worker:
   ```javascript
   self.addEventListener('install', () => self.skipWaiting());
   self.addEventListener('activate', () => self.clients.claim());
   ```

2. Remove update check from main.dart:
   ```dart
   // Comment out: await _checkPwaUpdates();
   ```

3. Deploy the rollback:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

## Success Criteria

The auto-update mechanism is working correctly if:
- ✅ Users get new version within 30 seconds of refresh
- ✅ Update banner appears and is user-friendly
- ✅ Auto-reload works after 5 seconds
- ✅ No errors in browser console
- ✅ Old caches are cleaned up automatically
- ✅ Mobile builds compile successfully
- ✅ Performance impact is minimal (<50ms)
