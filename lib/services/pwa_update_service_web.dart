// Web implementation for PWA update service
// This file is only used when running on web platforms

import 'dart:html' as html;
import 'package:flutter/foundation.dart';

const String _storageKey = 'angry_raphi_last_version_check';
const int _checkIntervalMinutes = 5;

/// Check for PWA updates when the app starts (web implementation)
Future<void> checkForUpdatesOnStartImpl() async {
  try {
    // Only check if running in a web browser with service worker support
    if (html.window.navigator.serviceWorker != null) {
      final lastCheck = _getLastCheckTime();
      final now = DateTime.now();

      // Check if we should perform an update check
      if (lastCheck == null ||
          now.difference(lastCheck).inMinutes >= _checkIntervalMinutes) {
        await _performUpdateCheck();
        _saveLastCheckTime(now);
      }
    }
  } catch (e) {
    debugPrint('[PWA Update] Error checking for updates: $e');
  }
}

/// Force an update check immediately (web implementation)
Future<void> forceUpdateCheckImpl() async {
  try {
    if (html.window.navigator.serviceWorker != null) {
      await _performUpdateCheck();
      _saveLastCheckTime(DateTime.now());
    }
  } catch (e) {
    debugPrint('[PWA Update] Error forcing update check: $e');
  }
}

/// Clear the stored check time (web implementation)
void clearCheckTimeImpl() {
  try {
    html.window.localStorage.remove(_storageKey);
  } catch (e) {
    debugPrint('[PWA Update] Error clearing check time: $e');
  }
}

/// Perform the actual update check
Future<void> _performUpdateCheck() async {
  try {
    final registration = await html.window.navigator.serviceWorker?.ready;
    if (registration != null) {
      debugPrint('[PWA Update] Checking for service worker updates...');
      await registration.update();
    }
  } catch (e) {
    debugPrint('[PWA Update] Update check failed: $e');
  }
}

/// Get the last time we checked for updates
DateTime? _getLastCheckTime() {
  try {
    final stored = html.window.localStorage[_storageKey];
    if (stored != null) {
      return DateTime.parse(stored);
    }
  } catch (e) {
    debugPrint('[PWA Update] Error reading last check time: $e');
  }
  return null;
}

/// Save the last check time
void _saveLastCheckTime(DateTime time) {
  try {
    html.window.localStorage[_storageKey] = time.toIso8601String();
  } catch (e) {
    debugPrint('[PWA Update] Error saving last check time: $e');
  }
}
