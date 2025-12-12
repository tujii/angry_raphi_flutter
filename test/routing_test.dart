// Basic routing test for GoRouter implementation

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:angry_raphi/core/routing/app_router.dart';

void main() {
  group('AppRouter', () {
    test('Route constants are defined correctly', () {
      // Verify all route paths are defined
      expect(AppRouter.home, '/');
      expect(AppRouter.login, '/login');
      expect(AppRouter.terms, '/terms');
      expect(AppRouter.privacy, '/privacy');
      expect(AppRouter.adminSettings, '/admin/settings');
    });

    test('Router instance can be created', () {
      // Verify the router can be instantiated
      final router = AppRouter.createRouter();
      expect(router, isNotNull);
    });

    test('Router has correct initial location', () {
      final router = AppRouter.createRouter();
      expect(router.routeInformationProvider.value.uri.path, '/');
    });

    test('Router has all required routes configured', () {
      final router = AppRouter.createRouter();

      // Verify router is configured and has routes
      expect(router, isA<GoRouter>());
      expect(router.configuration.routes, isNotEmpty);
      expect(router.configuration.routes.length,
          equals(5)); // home, login, terms, privacy, admin
    });
  });
}
