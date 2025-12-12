import 'package:flutter/foundation.dart';

// Conditional import for web-only functionality
import 'pwa_update_service_stub.dart'
    if (dart.library.html) 'pwa_update_service_web.dart';

/// Service to handle PWA updates and version checking
/// This ensures the app automatically loads the latest version
class PwaUpdateService {
  /// Check if we're running as a web app
  bool get isWeb => kIsWeb;

  /// Check for PWA updates when the app starts
  Future<void> checkForUpdatesOnStart() async {
    if (!isWeb) return;
    await checkForUpdatesOnStartImpl();
  }

  /// Force an update check immediately
  Future<void> forceUpdateCheck() async {
    if (!isWeb) return;
    await forceUpdateCheckImpl();
  }

  /// Clear the stored check time (for testing)
  void clearCheckTime() {
    if (!isWeb) return;
    clearCheckTimeImpl();
  }
}

