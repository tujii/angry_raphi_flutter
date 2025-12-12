# Raphcon Mini-Gamification System

## Overview
The Raphcon gamification system tracks hardware failures (peripherals) and awards "Chaos Points" to users. It generates humorous stories based on recent failures and displays them in an interactive dashboard.

## Features

### 1. Hardware Fail Tracking
- Tracks failures for: Webcam, Headset, Mouse, Keyboard
- Each failure adds 1 Chaos Point to the user
- Failures are timestamped and stored in Firestore

### 2. Chaos Points & Ranking
Users earn ranks based on their total chaos points:
- **Chaos Beginner**: 0-9 points
- **Chaos Novice**: 10-19 points
- **Chaos Enthusiast**: 20-49 points
- **Chaos Expert**: 50-99 points
- **Chaos Master**: 100+ points

### 3. Story Generation
Automatically generates humorous German stories based on recent hardware failures (last 7 days):
- Example: "Webcam hat 3× aufgegeben. Zeit für ein Upgrade? 🔧"
- Example: "Headset macht wieder Ferien – 5× in 7 Tagen! 🏖️"

### 4. In-App Notifications
Uses `fluttertoast` to show notifications when:
- A hardware fail is reported
- A new story is generated
- Chaos points are updated

### 5. Dashboard
Interactive dashboard showing:
- Current chaos points
- User rank with color coding
- Latest story
- Quick action buttons to report hardware failures

## Architecture

Following Clean Architecture pattern with three layers:

### Domain Layer
- **Entities**: `HardwareFailEntity`, `StoryEntity`, `ChaosUserEntity`
- **Repository Interface**: `GamificationRepository`
- **Use Cases**: 
  - `AddHardwareFail`
  - `GenerateUserStory`
  - `GetUserChaosPoints`
  - `GetUserChaosPointsStream`
  - `GetLatestStoryStream`

### Data Layer
- **Models**: Firestore serialization models
- **Data Sources**: `GamificationRemoteDataSource`
- **Repository Implementation**: `GamificationRepositoryImpl`

### Presentation Layer
- **BLoC**: `GamificationBloc` for state management
- **Pages**: `ChaosDashboardPage`
- **Widgets**: `ChaosDashboard`, `NotificationService`

## Firestore Collections

### `hardwareFails`
```
{
  "userId": "string",
  "type": "webcam|headset|mouse|keyboard",
  "timestamp": "Timestamp"
}
```

### `stories`
```
{
  "userId": "string",
  "text": "string",
  "timestamp": "Timestamp"
}
```

### `users` (extended fields)
```
{
  // ... existing fields
  "totalChaosPoints": "number",
  "rank": "string"
}
```

## Usage

### Accessing the Dashboard
1. Login to the app
2. Click the menu icon (three dots) in the app bar
3. Select "Chaos Dashboard"

### Reporting Hardware Fails
In the dashboard, click one of the hardware buttons:
- Webcam
- Headset
- Mouse
- Keyboard

This will:
1. Add the failure to Firestore
2. Increment chaos points
3. Generate a new story
4. Show a notification

### Real-time Updates
The dashboard uses Firestore streams to update in real-time:
- Chaos points update automatically
- New stories appear immediately
- Rank changes are reflected instantly

## Security Rules

Firestore rules ensure:
- Authenticated users can read/write their own data
- Chaos points can be updated by the system
- Admins have full access

## Future Enhancements

### PWA Push Notifications
To enable push notifications outside the app:
1. Configure Firebase Cloud Messaging
2. Add service worker in `web/` directory
3. Request notification permissions
4. Send notifications via Firebase Admin SDK

Example service worker setup (for future):
```javascript
// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/9.x.x/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.x.x/firebase-messaging-compat.js');

firebase.initializeApp({
  // Firebase config
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
```

## Deployment

### Firebase Hosting
```bash
# Build the Flutter web app
flutter build web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Firestore Rules and Indexes
```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

## Testing

To test the gamification system:
1. Login as a user
2. Navigate to Chaos Dashboard
3. Click hardware fail buttons
4. Verify chaos points increment
5. Check that stories are generated
6. Verify notifications appear

## Dependencies

- `fluttertoast`: ^8.2.8 - For in-app notifications
- `firebase_core`: ^3.6.0 - Firebase initialization
- `cloud_firestore`: ^5.4.3 - Firestore database
- `bloc`: ^8.1.4 - State management
- `flutter_bloc`: ^8.1.6 - BLoC for Flutter

## Color Coding

Rank colors in dashboard:
- **Blue**: Chaos Beginner (0-9)
- **Amber**: Chaos Novice (10-19)
- **Orange**: Chaos Enthusiast (20-49)
- **Deep Orange**: Chaos Expert (50-99)
- **Red**: Chaos Master (100+)
