// Basic routing test for GoRouter implementation

import 'package:angry_raphi/core/routing/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
          equals(8)); // home, login, terms, privacy, spaces, space, join, admin
    });

    test('Routes are properly configured in GoRouter', () {
      final router = AppRouter.createRouter();

      // Test that we have the correct number of routes configured
      final routes = router.configuration.routes;
      expect(routes.length, equals(8));

      // Cast to GoRoute to access path property
      final goRoutes = routes.whereType<GoRoute>().toList();
      final routePaths = goRoutes.map((route) => route.path).toList();

      expect(routePaths, contains('/'));
      expect(routePaths, contains('/login'));
      expect(routePaths, contains('/terms'));
      expect(routePaths, contains('/privacy'));
      expect(routePaths, contains('/admin/settings'));
      expect(routePaths, contains('/spaces'));
      expect(routePaths, contains('/s/:spaceId'));
      expect(routePaths, contains('/join/:spaceId/:code'));
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

      // Navigate back to home (redirects are covered by the tests below)
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

  group('AppRouter.redirect', () {
    test('space routes require sign-in and remember the target', () {
      expect(
        AppRouter.redirect(Uri.parse('/spaces'), false),
        '/login?from=%2Fspaces',
      );
      expect(
        AppRouter.redirect(Uri.parse('/s/abc'), false),
        '/login?from=%2Fs%2Fabc',
      );
      expect(
        AppRouter.redirect(Uri.parse('/spaces/new'), false),
        '/login?from=%2Fspaces%2Fnew',
      );
      expect(
        AppRouter.redirect(Uri.parse('/join/abc/code123'), false),
        '/login?from=%2Fjoin%2Fabc%2Fcode123',
      );
    });

    test('home leads to the spaces or the login page', () {
      expect(AppRouter.redirect(Uri.parse('/'), true), '/spaces');
      expect(AppRouter.redirect(Uri.parse('/'), false), '/login');
    });

    test('signed-in users can open space routes', () {
      expect(AppRouter.redirect(Uri.parse('/spaces'), true), isNull);
      expect(AppRouter.redirect(Uri.parse('/s/abc'), true), isNull);
    });

    test('public routes stay accessible without sign-in', () {
      for (final path in ['/login', '/terms', '/privacy']) {
        expect(AppRouter.redirect(Uri.parse(path), false), isNull);
      }
    });

    test('login returns to the remembered target after sign-in', () {
      expect(
        AppRouter.redirect(Uri.parse('/login?from=%2Fs%2Fabc'), true),
        '/s/abc',
      );
      expect(AppRouter.redirect(Uri.parse('/login'), true), '/spaces');
    });

    test('login ignores external targets', () {
      expect(
        AppRouter.redirect(
            Uri.parse('/login?from=https%3A%2F%2Fevil.example'), true),
        '/spaces',
      );
      expect(
        AppRouter.redirect(Uri.parse('/login?from=%2F%2Fevil.example'), true),
        '/spaces',
      );
    });

    test('space locations encode their parameters', () {
      expect(AppRouter.space('abc'), '/s/abc');
      expect(AppRouter.spaceMembers('abc'), '/s/abc/members');
      expect(AppRouter.join('abc', 'x/y'), '/join/abc/x%2Fy');
    });
  });
}
