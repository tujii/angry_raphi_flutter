import 'package:flutter/foundation.dart';

import '../../../../core/routing/app_router.dart';

/// Builds shareable invite links.
class InviteLinks {
  /// Used outside the web, where the app has no origin of its own
  static const String defaultOrigin = 'https://angryraphi.web.app';

  static String build(String spaceId, String code, {String? origin}) {
    final base = origin ?? (kIsWeb ? Uri.base.origin : defaultOrigin);
    return '$base${AppRouter.join(spaceId, code)}';
  }
}
