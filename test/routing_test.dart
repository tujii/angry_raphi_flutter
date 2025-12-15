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

    test('Routes are properly configured in GoRouter', () {
      final router = AppRouter.createRouter();

      // Test that we have the correct number of routes configured
      final routes = router.configuration.routes;
      expect(routes.length, equals(5));

      // Cast to GoRoute to access path property
      final goRoutes = routes.whereType<GoRoute>().toList();
      final routePaths = goRoutes.map((route) => route.path).toList();

      expect(routePaths, contains('/'));
      expect(routePaths, contains('/login'));
      expect(routePaths, contains('/terms'));
      expect(routePaths, contains('/privacy'));
      expect(routePaths, contains('/admin/settings'));
    });

    test('Route navigation works correctly', () {
      final router = AppRouter.createRouter();

      // Test navigation to each route
      router.go('/terms');
      expect(router.routeInformationProvider.value.uri.path, '/terms');

      router.go('/privacy');
      expect(router.routeInformationProvider.value.uri.path, '/privacy');

      router.go('/admin/settings');
      expect(router.routeInformationProvider.value.uri.path, '/admin/settings');

      router.go('/login');
      expect(router.routeInformationProvider.value.uri.path, '/login');

      // Navigate back to home
      router.go('/');
      expect(router.routeInformationProvider.value.uri.path, '/');
    });

    test('Invalid URL shows error page', () {
      final router = AppRouter.createRouter();

      // Test navigation to invalid URL
      router.go('/invalid-path');
      expect(router.routeInformationProvider.value.uri.path, '/invalid-path');
      // Note: GoRouter handles error pages internally, we just verify the path is set
    });
  });
}
