# Routing Guide - GoRouter Implementation

This guide explains how to use and extend the routing system in the AngryRaphi Flutter application using [go_router](https://pub.dev/packages/go_router).

## Overview

The application uses `go_router` for declarative routing with named URL paths. This provides:
- Clean, readable URLs for web navigation
- Easy deep linking support
- Shareable URLs for users
- SEO-friendly paths
- Type-safe navigation

## Current Routes

The following routes are currently configured:

| Route Name | Path | Description |
|------------|------|-------------|
| `home` | `/` | Main page with user list |
| `login` | `/login` | Login page |
| `terms` | `/terms` | Terms of Service page |
| `privacy` | `/privacy` | Privacy Policy page |
| `admin-settings` | `/admin/settings` | Admin settings page (requires authentication) |

## Router Configuration

The router is configured in `lib/core/routing/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';
import '../../core/routing/app_router.dart';

// Access route paths via constants
AppRouter.home          // '/'
AppRouter.login         // '/login'
AppRouter.terms         // '/terms'
AppRouter.privacy       // '/privacy'
AppRouter.adminSettings // '/admin/settings'
```

## Navigation Methods

### Basic Navigation

#### Push (adds to navigation stack)
```dart
import 'package:go_router/go_router.dart';
import '../../core/routing/app_router.dart';

// Navigate to a route
context.push(AppRouter.login);

// Navigate with query parameters
context.push('${AppRouter.login}?redirect=/admin/settings');
```

#### Go (replaces current route)
```dart
// Replace current route (doesn't add to stack)
context.go(AppRouter.home);
```

#### Pop (go back)
```dart
// Go back to previous route
context.pop();

// Go back with a result
context.pop('result_data');
```

### Named Navigation

You can also use named routes:

```dart
// Using named route
context.pushNamed('login');
context.goNamed('home');
```

## Adding a New Route

To add a new route to the application, follow these steps:

### 1. Define the Route Path Constant

In `lib/core/routing/app_router.dart`, add a new constant:

```dart
class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  // Add your new route constant
  static const String myNewPage = '/my-new-page';
  
  // ... rest of the code
}
```

### 2. Add the Route Configuration

In the same file, add the route to the `GoRouter` configuration:

```dart
static GoRouter createRouter() {
  return GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // ... existing routes
      
      // Add your new route
      GoRoute(
        path: myNewPage,
        name: 'my-new-page',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const MyNewPage(),
          );
        },
      ),
    ],
    // ... error builder
  );
}
```

### 3. Import Your Page Widget

Make sure to import the page widget at the top of `app_router.dart`:

```dart
import '../../features/my_feature/presentation/pages/my_new_page.dart';
```

### 4. Navigate to Your New Route

In your application code, navigate to the new route:

```dart
import 'package:go_router/go_router.dart';
import '../../core/routing/app_router.dart';

// In your widget
ElevatedButton(
  onPressed: () => context.push(AppRouter.myNewPage),
  child: Text('Go to My New Page'),
)
```

## Advanced Features

### Route with Parameters

For routes with path parameters:

```dart
// In app_router.dart
GoRoute(
  path: '/user/:userId',
  name: 'user-detail',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return UserDetailPage(userId: userId);
  },
),

// Navigate with parameter
context.push('/user/123');
```

### Query Parameters

```dart
// Navigate with query parameters
context.push('/search?query=flutter&filter=popular');

// Access query parameters in the page
final query = state.uri.queryParameters['query'];
final filter = state.uri.queryParameters['filter'];
```

### Nested Routes

For nested navigation (e.g., tabs within a page):

```dart
GoRoute(
  path: '/admin',
  builder: (context, state) => const AdminPage(),
  routes: [
    GoRoute(
      path: 'settings',
      builder: (context, state) => const AdminSettingsPage(),
    ),
    GoRoute(
      path: 'users',
      builder: (context, state) => const AdminUsersPage(),
    ),
  ],
),
```

### Redirects and Guards

For authentication guards or redirects:

```dart
GoRouter(
  redirect: (context, state) {
    final isAuthenticated = /* check auth status */;
    final isGoingToLogin = state.matchedLocation == '/login';
    
    if (!isAuthenticated && !isGoingToLogin) {
      return '/login';
    }
    return null; // No redirect
  },
  // ... routes
)
```

## Best Practices

1. **Use Constants**: Always use the route path constants from `AppRouter` instead of hardcoding strings.
   ```dart
   // Good
   context.push(AppRouter.login);
   
   // Bad
   context.push('/login');
   ```

2. **Use Meaningful Paths**: Choose paths that describe the content and are SEO-friendly.
   ```dart
   // Good
   static const String userProfile = '/users/:id/profile';
   
   // Bad
   static const String page2 = '/p2';
   ```

3. **Group Related Routes**: Keep related routes together and use nested routes when appropriate.

4. **Handle Errors**: The router has a built-in error page for invalid routes. Make sure to test edge cases.

5. **Deep Linking**: Design your URLs with deep linking in mind - users should be able to bookmark and share any page.

## Testing Routes

To test routes in your application:

1. Run the app in debug mode with `debugLogDiagnostics: true` (already enabled)
2. Check the console for navigation logs
3. Test URLs directly in the browser address bar (for web)
4. Verify that the back button works correctly

## Migration from MaterialPageRoute

If you're updating existing code that uses `Navigator.push` with `MaterialPageRoute`:

### Before:
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const SettingsPage(),
  ),
);
```

### After:
```dart
context.push(AppRouter.settings);
```

## Resources

- [go_router documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation and Routing](https://docs.flutter.dev/development/ui/navigation)
- [Deep Linking in Flutter](https://docs.flutter.dev/development/ui/navigation/deep-linking)

## Support

For questions or issues with routing, please refer to:
- This guide
- The `app_router.dart` implementation
- The go_router package documentation
