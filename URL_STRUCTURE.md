# URL Structure - AngryRaphi Flutter Web App

## Route Tree
```
https://yourapp.com/
├── /                       → Home (Public User List)
├── /login                  → Login Page
├── /terms                  → Terms of Service
├── /privacy                → Privacy Policy
└── /admin/
    └── settings            → Admin Settings

[404 Error Page]            → Any invalid URL
```

## Navigation Flow
```
1. User visits https://yourapp.com/
   ↓
   [Home Page - User List]
   
2. User clicks Login
   ↓
   https://yourapp.com/login
   ↓
   [Login Page]
   
3. After login, admin user accesses settings
   ↓
   https://yourapp.com/admin/settings
   ↓
   [Admin Settings Page]
   
4. User clicks Terms link
   ↓
   https://yourapp.com/terms
   ↓
   [Terms of Service Page]
```

## Code Structure
```
lib/
├── core/
│   └── routing/
│       └── app_router.dart          ← Router configuration
├── features/
│   ├── user/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── public_user_list_page.dart (/)
│   ├── authentication/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── login_page.dart        (/login)
│   │           ├── terms_of_service_page.dart  (/terms)
│   │           └── privacy_policy_page.dart    (/privacy)
│   └── admin/
│       └── presentation/
│           └── pages/
│               └── admin_settings_page.dart  (/admin/settings)
└── main.dart                        ← MaterialApp.router setup

test/
└── routing_test.dart                ← Routing tests

Documentation/
├── ROUTING_GUIDE.md                 ← Developer guide
└── ROUTING_EXAMPLES.md              ← Usage examples
```

## Key Implementation Details

### Route Constants (app_router.dart)
```dart
class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String adminSettings = '/admin/settings';
}
```

### Navigation Examples
```dart
// Navigate to login
context.push(AppRouter.login);

// Navigate to admin settings
context.push(AppRouter.adminSettings);

// Go back
context.pop();

// Replace current route (no back button)
context.go(AppRouter.home);
```

## Browser Behavior

### URL Bar
✅ Shows meaningful URLs: /login, /admin/settings, etc.
✅ Can be bookmarked
✅ Can be shared
✅ Can be edited directly

### Back/Forward Buttons
✅ Browser back works correctly
✅ Browser forward works correctly
✅ Full navigation history maintained

### Refresh
✅ Page refresh maintains current page
✅ Deep links work on first load
