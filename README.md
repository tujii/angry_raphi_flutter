# angry_raphi

AngryRaphi - Person rating app with Raphcons and Chaos Gamification System.

## Features

### 🎯 User Management
- Rate people with Raphcons (hardware fail incidents)
- Track user statistics and rankings
- Admin management interface

### ⚡ Chaos Gamification System
The Raphcon Chaos System tracks hardware failures and awards chaos points to users:

- **Hardware Fail Tracking**: Report failures for Webcam, Headset, Mouse, Keyboard
- **Chaos Points**: Earn points for each hardware failure
- **Rank System**: Progress from "Chaos Beginner" to "Chaos Master"
- **Story Generation**: Automatic humorous stories based on recent failures
- **Real-time Dashboard**: Live updates of chaos points and rankings
- **In-App Notifications**: Toast notifications for new fails and stories

Access the Chaos Dashboard via the menu (three dots) when logged in.

See [Gamification README](lib/features/gamification/README.md) for detailed documentation.

## Getting Started

This project is a Flutter application with Firebase backend.

### Prerequisites
- Flutter SDK (^3.6.1)
- Firebase CLI
- Dart SDK

### Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Configure Firebase:
```bash
firebase login
flutterfire configure
```

3. Run the app:
```bash
flutter run -d chrome  # For web
flutter run            # For mobile
```

### Deployment

Deploy to Firebase Hosting:
```bash
flutter build web
firebase deploy --only hosting
```

Deploy Firestore rules and indexes:
```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## Architecture

This project follows Clean Architecture principles:
- **Domain Layer**: Business logic and entities
- **Data Layer**: Repositories and data sources
- **Presentation Layer**: UI and state management (BLoC)

## Resources

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
