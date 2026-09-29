import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_settings_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/privacy_policy_page.dart';
import '../../features/authentication/presentation/pages/terms_of_service_page.dart';
import '../../features/spaces/presentation/pages/create_space_page.dart';
import '../../features/spaces/presentation/pages/space_home_page.dart';
import '../../features/spaces/presentation/pages/spaces_page.dart';
import '../../shared/widgets/app_wrapper.dart';

/// Application router configuration using GoRouter
///
/// This class defines all the named routes for the application.
/// Routes are organized hierarchically with meaningful URL paths.
class AppRouter {
  // Route path constants
  static const String home = '/';
  static const String login = '/login';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String adminSettings = '/admin/settings';
  static const String spaces = '/spaces';
  static const String createSpace = '/spaces/new';
  static const String spaceHome = '/s/:spaceId';

  /// Location of the home page of the space with [spaceId]
  static String space(String spaceId) => '/s/${Uri.encodeComponent(spaceId)}';

  /// Query parameter on [login] holding the location to return to
  static const String fromParam = 'from';

  /// Creates and configures the GoRouter instance
  ///
  /// [isSignedIn] and [refreshListenable] default to Firebase Auth; tests can
  /// pass their own. Space routes require a signed-in user; others are
  /// redirected to [login] and brought back after signing in.
  static GoRouter createRouter({
    bool Function()? isSignedIn,
    Listenable? refreshListenable,
  }) {
    final signedIn = isSignedIn ?? _firebaseSignedIn;
    return GoRouter(
      initialLocation: home,
      debugLogDiagnostics: true,
      refreshListenable: refreshListenable,
      redirect: (context, state) => redirect(state.uri, signedIn()),
      routes: [
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const AppWrapper(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: const LoginPage(),
            );
          },
        ),
        GoRoute(
          path: terms,
          name: 'terms',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: const TermsOfServicePage(),
            );
          },
        ),
        GoRoute(
          path: privacy,
          name: 'privacy',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: const PrivacyPolicyPage(),
            );
          },
        ),
        GoRoute(
          path: spaces,
          name: 'spaces',
          builder: (context, state) => const SpacesPage(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'create-space',
              builder: (context, state) => const CreateSpacePage(),
            ),
          ],
        ),
        GoRoute(
          path: spaceHome,
          name: 'space',
          builder: (context, state) => SpaceHomePage(
            key: ValueKey(state.pathParameters['spaceId']),
            spaceId: state.pathParameters['spaceId']!,
          ),
        ),
        GoRoute(
          path: adminSettings,
          name: 'admin-settings',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: const AdminSettingsPage(),
            );
          },
        ),
      ],
      // Error page for invalid routes
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.uri.path}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _firebaseSignedIn() {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } on Exception {
      // Firebase not initialized (e.g. in tests): treat as signed out
      return false;
    }
  }

  /// Redirect logic, separated for testing. Returns `null` to stay on [uri].
  static String? redirect(Uri uri, bool signedIn) {
    final path = uri.path;
    final needsAuth =
        path == spaces || path.startsWith('$spaces/') || path.startsWith('/s/');
    if (needsAuth && !signedIn) {
      return Uri(path: login, queryParameters: {fromParam: uri.toString()})
          .toString();
    }
    if (path == login && signedIn) {
      final from = uri.queryParameters[fromParam];
      // Only allow local targets (no open redirect)
      if (from != null && from.startsWith('/') && !from.startsWith('//')) {
        return from;
      }
      return home;
    }
    return null;
  }
}

/// Notifies GoRouter whenever [stream] emits (e.g. auth state changes).
class StreamListenable extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
