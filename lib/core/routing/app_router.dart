import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/user/presentation/widgets/public_user_list_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/terms_of_service_page.dart';
import '../../features/authentication/presentation/pages/privacy_policy_page.dart';
import '../../features/admin/presentation/pages/admin_settings_page.dart';
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

  /// Creates and configures the GoRouter instance
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: home,
      debugLogDiagnostics: true,
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
              child: const LoginPage(isDialog: false),
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
}
