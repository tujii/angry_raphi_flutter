// Stub implementation for non-web platforms
// This file is used when the app is not running on web

/// Check for PWA updates on start (stub - does nothing on non-web platforms)
Future<void> checkForUpdatesOnStartImpl() async {
  // No-op on non-web platforms
}

/// Force update check (stub - does nothing on non-web platforms)
Future<void> forceUpdateCheckImpl() async {
  // No-op on non-web platforms
}

/// Clear check time (stub - does nothing on non-web platforms)
void clearCheckTimeImpl() {
  // No-op on non-web platforms
}
