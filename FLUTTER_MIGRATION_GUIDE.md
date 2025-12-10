# AngryRaphi Flutter Migration Guide

## Senior Architecture Überblick

Als Senior Flutter Architect implementieren wir eine saubere, skalierbare Flutter-App mit **Clean Architecture**, **BLoC Pattern** und **Firebase Backend Integration**. Diese Architektur garantiert Wartbarkeit, Testbarkeit und Performance.

---

## 🏗️ Clean Architecture Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── firebase_constants.dart
│   │   └── routes.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── extensions.dart
│   │   └── image_helper.dart
│   └── widgets/
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── lottie_animation_widget.dart
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_google.dart
│   │   │       ├── sign_out.dart
│   │   │       └── check_auth_status.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   └── auth_page.dart
│   │       └── widgets/
│   │           ├── google_sign_in_button.dart
│   │           └── user_avatar.dart
│   ├── user_management/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── users_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── person_model.dart
│   │   │   └── repositories/
│   │   │       └── users_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── person_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── users_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_all_users.dart
│   │   │       ├── add_user.dart
│   │   │       └── delete_user.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── users_bloc.dart
│   │       │   ├── users_event.dart
│   │       │   └── users_state.dart
│   │       ├── pages/
│   │       │   ├── users_list_page.dart
│   │       │   └── add_user_page.dart
│   │       └── widgets/
│   │           ├── user_card.dart
│   │           ├── user_list_widget.dart
│   │           └── add_user_form.dart
│   ├── raphcon_management/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── raphcons_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── raphcon_model.dart
│   │   │   └── repositories/
│   │   │       └── raphcons_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── raphcon_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── raphcons_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_user_raphcons.dart
│   │   │       ├── add_raphcon.dart
│   │   │       └── delete_raphcon.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── raphcons_bloc.dart
│   │       │   ├── raphcons_event.dart
│   │       │   └── raphcons_state.dart
│   │       ├── pages/
│   │       │   ├── raphcons_page.dart
│   │       │   └── add_raphcon_page.dart
│   │       └── widgets/
│   │           ├── raphcon_card.dart
│   │           └── add_raphcon_dialog.dart
│   └── admin/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── admin_remote_datasource.dart
│       │   ├── models/
│       │   │   └── admin_model.dart
│       │   └── repositories/
│       │       └── admin_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── admin_entity.dart
│       │   ├── repositories/
│       │   │   └── admin_repository.dart
│       │   └── usecases/
│       │       ├── check_admin_status.dart
│       │       ├── add_admin.dart
│       │       └── remove_admin.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── admin_bloc.dart
│           │   ├── admin_event.dart
│           │   └── admin_state.dart
│           ├── pages/
│           │   └── admin_panel_page.dart
│           └── widgets/
│               ├── admin_actions_card.dart
│               └── statistics_widget.dart
├── shared/
│   ├── widgets/
│   │   ├── custom_app_bar.dart
│   │   ├── custom_fab.dart
│   │   ├── confirmation_dialog.dart
│   │   └── language_selector.dart
│   └── services/
│       ├── firebase_service.dart
│       ├── image_service.dart
│       └── localization_service.dart
└── injection_container.dart
```

---

## 📦 Dependencies (pubspec.yaml)

```yaml
name: angry_raphi
description: "AngryRaphi - Person rating app with raphcons"
version: 1.0.0+1

environment:
  sdk: ^3.5.3

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  firebase_storage: ^12.3.2
  
  # State Management
  bloc: ^8.1.4
  flutter_bloc: ^8.1.6
  
  # Dependency Injection
  get_it: ^8.0.0
  injectable: ^2.5.0
  
  # Network & Utils
  dartz: ^0.10.1
  equatable: ^2.0.5
  connectivity_plus: ^6.0.5
  
  # UI & UX
  lottie: ^3.1.2
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  
  # Authentication
  google_sign_in: ^6.2.1
  
  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  injectable_generator: ^2.5.0
  build_runner: ^2.4.13
  
  # Testing
  mockito: ^5.4.4
  bloc_test: ^9.1.7
  
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/animations/
    - assets/images/
    - assets/locales/
```

---

## 🔥 Firebase Setup & Configuration

### 1. Firebase Project Setup

```bash
# Firebase CLI Installation & Setup
npm install -g firebase-tools
firebase login
firebase init

# Wähle:
# - Firestore
# - Authentication
# - Storage
# - Hosting (optional)

# FlutterFire CLI Setup
dart pub global activate flutterfire_cli
flutterfire configure
```

### 2. Firebase Configuration (`lib/core/constants/firebase_constants.dart`)

```dart
class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String raphconsCollection = 'raphcons';
  static const String adminsCollection = 'admins';
  
  static const String userImagesPath = 'users';
  static const String raphconImagesPath = 'raphcons';
  
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
}
```

### 3. Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper Functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    function isValidUser(data) {
      return data.keys().hasAll(['name', 'createdAt']) &&
             data.name is string &&
             data.name.size() > 0 &&
             data.createdAt is timestamp;
    }
    
    function isValidRaphcon(data) {
      return data.keys().hasAll(['userId', 'createdAt', 'createdBy']) &&
             data.userId is string &&
             data.createdAt is timestamp &&
             data.createdBy == request.auth.uid;
    }
    
    // Users Collection - Read for all, Write only for Admins
    match /users/{userId} {
      allow read: if true;
      allow create, update: if isAdmin() && isValidUser(resource.data);
      allow delete: if isAdmin();
    }
    
    // Raphcons Collection - Read for all, Write only for Admins
    match /raphcons/{raphconId} {
      allow read: if true;
      allow create: if isAdmin() && isValidRaphcon(request.resource.data);
      allow update, delete: if isAdmin();
    }
    
    // Admins Collection - Only Admins can read/write
    match /admins/{adminId} {
      allow read: if isAuthenticated() && 
                     (request.auth.uid == adminId || isAdmin());
      allow write: if isAdmin();
    }
    
    // Statistics - Read only for Admins
    match /statistics/{statId} {
      allow read: if isAdmin();
      allow write: if false; // Generated via Cloud Functions
    }
  }
}
```

### 4. Firebase Storage Security Rules

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper Functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    function isValidImage() {
      return request.resource.contentType.matches('image/.*') &&
             request.resource.size < 5 * 1024 * 1024 && // Max 5MB
             request.resource.contentType in ['image/jpeg', 'image/png', 'image/webp'];
    }
    
    // User Profile Images
    match /users/{userId}/{imageId} {
      allow read: if true;
      allow write: if isAdmin() && isValidImage();
      allow delete: if isAdmin();
    }
    
    // Raphcon Images
    match /raphcons/{raphconId}/{imageId} {
      allow read: if true;
      allow write: if isAdmin() && isValidImage();
      allow delete: if isAdmin();
    }
  }
}
```

---

## 🏛️ Core Architecture Implementation

### 1. Dependency Injection Setup (`injection_container.dart`)

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

// Run: dart run build_runner build
```

### 2. Main App Entry Point (`main.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/routes.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/user_management/presentation/bloc/users_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'injection_container.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Dependencies
  configureDependencies();
  
  runApp(const AngryRaphiApp());
}

class AngryRaphiApp extends StatelessWidget {
  const AngryRaphiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<UsersBloc>(
          create: (_) => getIt<UsersBloc>(),
        ),
        BlocProvider<AdminBloc>(
          create: (_) => getIt<AdminBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: _buildTheme(),
        initialRoute: Routes.splash,
        routes: Routes.routes,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('de', 'DE'), // German
          Locale('de', 'CH'), // Swiss German
        ],
        locale: const Locale('de', 'CH'),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
```

### 3. App Constants (`lib/core/constants/app_constants.dart`)

```dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'AngryRaphi';
  static const Color primaryColor = Color(0xFF8B0000); // Dark Red
  static const Color secondaryColor = Color(0xFF4CAF50); // Green
  
  // Animation Paths
  static const String angryFaceAnimation = 'assets/animations/angry_face.json';
  static const String loadingAnimation = 'assets/animations/loading_spinner.json';
  static const String successAnimation = 'assets/animations/success_checkmark.json';
  static const String userAvatarAnimation = 'assets/animations/user_avatar.json';
  
  // Validation
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxImageSizeMB = 5;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 8.0;
}
```

---

## 🎯 Feature Implementation Examples

### Authentication Feature

#### Domain Entity (`features/authentication/domain/entities/user_entity.dart`)

```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool isAdmin;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.isAdmin,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoURL,
    isAdmin,
    createdAt,
  ];
}
```

#### Use Case (`features/authentication/domain/usecases/sign_in_with_google.dart`)

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}
```

#### BLoC Implementation (`features/authentication/presentation/bloc/auth_bloc.dart`)

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/check_auth_status.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}
class SignInWithGoogleEvent extends AuthEvent {}
class SignOutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
  
  @override
  List<Object> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final CheckAuthStatus _checkAuthStatus;

  AuthBloc(
    this._signInWithGoogle,
    this._signOut,
    this._checkAuthStatus,
  ) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _checkAuthStatus();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signOut();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
```

### User Management Feature

#### Person Entity (`features/user_management/domain/entities/person_entity.dart`)

```dart
import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? profileImageUrl;
  final int raphconCount;
  final DateTime createdAt;

  const PersonEntity({
    required this.id,
    required this.name,
    this.description,
    this.profileImageUrl,
    required this.raphconCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    profileImageUrl,
    raphconCount,
    createdAt,
  ];
}
```

#### Users BLoC (`features/user_management/presentation/bloc/users_bloc.dart`)

```dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/person_entity.dart';
import '../../domain/usecases/get_all_users.dart';
import '../../domain/usecases/add_user.dart';
import '../../domain/usecases/delete_user.dart';

// Events
abstract class UsersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UsersEvent {}

class AddUserEvent extends UsersEvent {
  final String name;
  final String? description;
  final File? imageFile;

  AddUserEvent({
    required this.name,
    this.description,
    this.imageFile,
  });

  @override
  List<Object?> get props => [name, description, imageFile];
}

class DeleteUserEvent extends UsersEvent {
  final String userId;

  DeleteUserEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

// States
abstract class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}
class UsersLoading extends UsersState {}
class UsersLoaded extends UsersState {
  final List<PersonEntity> users;

  UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}
class UsersError extends UsersState {
  final String message;

  UsersError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
@injectable
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetAllUsers _getAllUsers;
  final AddUser _addUser;
  final DeleteUser _deleteUser;

  UsersBloc(
    this._getAllUsers,
    this._addUser,
    this._deleteUser,
  ) : super(UsersInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<AddUserEvent>(_onAddUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    
    await emit.forEach(
      _getAllUsers(),
      onData: (result) => result.fold(
        (failure) => UsersError(failure.message),
        (users) => UsersLoaded(users),
      ),
      onError: (error, stackTrace) => UsersError(error.toString()),
    );
  }

  Future<void> _onAddUser(
    AddUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    final currentState = state;
    if (currentState is UsersLoaded) {
      emit(UsersLoading());
      
      final result = await _addUser(AddUserParams(
        name: event.name,
        description: event.description,
        imageFile: event.imageFile,
      ));
      
      result.fold(
        (failure) => emit(UsersError(failure.message)),
        (_) => add(LoadUsersEvent()), // Reload users
      );
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    final currentState = state;
    if (currentState is UsersLoaded) {
      emit(UsersLoading());
      
      final result = await _deleteUser(DeleteUserParams(event.userId));
      
      result.fold(
        (failure) => emit(UsersError(failure.message)),
        (_) => add(LoadUsersEvent()), // Reload users
      );
    }
  }
}
```

---

## 🎨 UI Implementation Examples

### User List Page (`features/user_management/presentation/pages/users_list_page.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_fab.dart';
import '../bloc/users_bloc.dart';
import '../widgets/user_list_widget.dart';
import '../widgets/add_user_form.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(LoadUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'AngryRaphi'),
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UsersLoading) {
            return const LoadingWidget();
          }
          
          if (state is UsersLoaded) {
            if (state.users.isEmpty) {
              return _buildEmptyState();
            }
            return UserListWidget(users: state.users);
          }
          
          if (state is UsersError) {
            return _buildErrorState(state.message);
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated && authState.user.isAdmin) {
            return CustomFAB(
              onPressed: () => _showAddUserDialog(context),
              icon: Icons.add,
              tooltip: 'Person hinzufügen',
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppConstants.userAvatarAnimation,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Personen vorhanden',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fügen Sie die erste Person hinzu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Fehler beim Laden',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<UsersBloc>().add(LoadUsersEvent()),
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<UsersBloc>(),
        child: const AddUserForm(),
      ),
    );
  }
}
```

### User Card Widget (`features/user_management/presentation/widgets/user_card.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/person_entity.dart';
import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../bloc/users_bloc.dart';

class UserCard extends StatelessWidget {
  final PersonEntity person;

  const UserCard({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: () => _navigateToUserDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(child: _buildUserInfo(context)),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppConstants.primaryColor.withOpacity(0.1),
      ),
      child: person.profileImageUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: person.profileImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Lottie.asset(
                  AppConstants.loadingAnimation,
                  width: 30,
                  height: 30,
                ),
                errorWidget: (context, url, error) => _buildDefaultAvatar(),
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Lottie.asset(
      AppConstants.userAvatarAnimation,
      width: 40,
      height: 40,
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          person.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${person.raphconCount} Raphcons',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        if (person.description?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            person.description!,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated && authState.user.isAdmin) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Lottie.asset(
                  AppConstants.angryFaceAnimation,
                  width: 24,
                  height: 24,
                ),
                onPressed: () => _addRaphcon(context),
                tooltip: 'Raphcon hinzufügen',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
                tooltip: 'Löschen',
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToUserDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/user-details',
      arguments: person.id,
    );
  }

  void _addRaphcon(BuildContext context) {
    // Navigate to add raphcon page or show dialog
    Navigator.pushNamed(
      context,
      '/add-raphcon',
      arguments: person.id,
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Person löschen'),
        content: Text('Sind Sie sicher, dass Sie ${person.name} löschen möchten?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UsersBloc>().add(DeleteUserEvent(person.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🛠️ Shared Widgets & Services

### Custom App Bar (`shared/widgets/custom_app_bar.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_constants.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Lottie.asset(
            AppConstants.angryFaceAnimation,
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return _buildUserMenu(context, state);
            }
            return _buildSignInButton(context);
          },
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, AuthAuthenticated state) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: state.user.photoURL != null
            ? NetworkImage(state.user.photoURL!)
            : null,
        child: state.user.photoURL == null
            ? Text(
                state.user.displayName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: AppConstants.primaryColor),
              )
            : null,
      ),
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 8),
              Text(state.user.displayName),
            ],
          ),
        ),
        if (state.user.isAdmin)
          const PopupMenuItem(
            value: 'admin',
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings),
                SizedBox(width: 8),
                Text('Admin Panel'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('Abmelden'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<AuthBloc>().add(SignInWithGoogleEvent()),
      child: const Text(
        'Anmelden',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'admin':
        Navigator.pushNamed(context, '/admin');
        break;
      case 'logout':
        context.read<AuthBloc>().add(SignOutEvent());
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
```

### Loading Widget (`core/widgets/loading_widget.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppConstants.loadingAnimation,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          if (message != null)
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## 🧪 Testing Strategy

### Unit Test Example (`test/features/authentication/domain/usecases/sign_in_with_google_test.dart`)

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_in_with_google.dart';

import 'sign_in_with_google_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignInWithGoogle usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithGoogle(mockAuthRepository);
  });

  const testUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
    isAdmin: false,
    createdAt: null,
  );

  test('should get user from repository when sign in is successful', () async {
    // Arrange
    when(mockAuthRepository.signInWithGoogle())
        .thenAnswer((_) async => const Right(testUser));

    // Act
    final result = await usecase();

    // Assert
    expect(result, const Right(testUser));
    verify(mockAuthRepository.signInWithGoogle());
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return failure when sign in fails', () async {
    // Arrange
    when(mockAuthRepository.signInWithGoogle())
        .thenAnswer((_) async => Left(AuthFailure('Sign in failed')));

    // Act
    final result = await usecase();

    // Assert
    expect(result, Left(AuthFailure('Sign in failed')));
    verify(mockAuthRepository.signInWithGoogle());
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
```

### BLoC Test Example (`test/features/authentication/presentation/bloc/auth_bloc_test.dart`)

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_bloc.dart';

import '../../domain/usecases/sign_in_with_google_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late MockCheckAuthStatus mockCheckAuthStatus;

  setUp(() {
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockCheckAuthStatus = MockCheckAuthStatus();
    authBloc = AuthBloc(mockSignInWithGoogle, mockSignOut, mockCheckAuthStatus);
  });

  tearDown(() {
    authBloc.close();
  });

  const testUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
    isAdmin: false,
    createdAt: null,
  );

  blocTest<AuthBloc, AuthState>(
    'should emit [AuthLoading, AuthAuthenticated] when sign in is successful',
    build: () {
      when(mockSignInWithGoogle()).thenAnswer(
        (_) async => const Right(testUser),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(SignInWithGoogleEvent()),
    expect: () => [
      AuthLoading(),
      AuthAuthenticated(testUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'should emit [AuthLoading, AuthError] when sign in fails',
    build: () {
      when(mockSignInWithGoogle()).thenAnswer(
        (_) async => Left(AuthFailure('Sign in failed')),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(SignInWithGoogleEvent()),
    expect: () => [
      AuthLoading(),
      AuthError('Sign in failed'),
    ],
  );
}
```

---

## 🚀 Deployment & Performance

### Build Configuration

```bash
# Debug Build
flutter run --debug

# Release Build (APK)
flutter build apk --release

# Release Build (iOS)
flutter build ios --release

# Web Build
flutter build web --release

# Performance Profiling
flutter run --profile
```

### Performance Optimizations

1. **Image Optimization**:
   ```dart
   // Use cached_network_image for network images
   CachedNetworkImage(
     imageUrl: imageUrl,
     placeholder: (context, url) => const CircularProgressIndicator(),
     errorWidget: (context, url, error) => const Icon(Icons.error),
   )
   ```

2. **List Performance**:
   ```dart
   // Use ListView.builder for large lists
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) => UserCard(person: items[index]),
   )
   ```

3. **State Management Optimization**:
   ```dart
   // Use Equatable for efficient state comparisons
   class UsersLoaded extends Equatable {
     final List<PersonEntity> users;
     
     @override
     List<Object> get props => [users];
   }
   ```

---

## 📱 Platform-Specific Configuration

### Android (`android/app/build.gradle`)

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### iOS Configuration (`ios/Runner/Info.plist`)

```xml
<key>CFBundleDisplayName</key>
<string>AngryRaphi</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take profile pictures</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select profile pictures</string>
```

---

## 🏆 Senior Architecture Best Practices

### 1. **Dependency Injection Hierarchy**
```dart
// Injectable Services
@injectable
class FirebaseAuthService implements AuthRepository {}

@injectable  
class FirestoreUserService implements UsersRepository {}

// Module für externe Dependencies
@module
abstract class RegisterModule {
  @injectable
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  
  @injectable
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
```

### 2. **Error Handling Strategy**
```dart
// Centralized Failure Types
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Network connection failed');
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}
```

### 3. **Repository Pattern Implementation**
```dart
// Abstract Repository
abstract class UsersRepository {
  Stream<Either<Failure, List<PersonEntity>>> getAllUsers();
  Future<Either<Failure, void>> addUser(AddUserParams params);
  Future<Either<Failure, void>> deleteUser(DeleteUserParams params);
}

// Concrete Implementation
@Injectable(as: UsersRepository)
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UsersRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<Either<Failure, List<PersonEntity>>> getAllUsers() async* {
    if (await networkInfo.isConnected) {
      try {
        yield* remoteDataSource.getAllUsers().map(
          (users) => Right(users.map((model) => model.toEntity()).toList()),
        ).handleError((error) => Left(_mapException(error)));
      } catch (e) {
        yield Left(_mapException(e));
      }
    } else {
      yield const Left(NetworkFailure());
    }
  }

  Failure _mapException(dynamic exception) {
    if (exception is FirebaseException) {
      return ServerFailure(exception.message ?? 'Server error occurred');
    }
    return ServerFailure(exception.toString());
  }
}
```

### 4. **Localization Setup**
```dart
// l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart

// app_de.arb
{
  "appTitle": "AngryRaphi",
  "signIn": "Anmelden",
  "signOut": "Abmelden",
  "addPerson": "Person hinzufügen",
  "deletePerson": "Person löschen",
  "confirmDelete": "Sind Sie sicher, dass Sie {name} löschen möchten?",
  "@confirmDelete": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

---

**Diese umfassende Architektur garantiert:**

✅ **Skalierbarkeit** - Clean Architecture mit klarer Trennung  
✅ **Testbarkeit** - 100% Unit Test Coverage möglich  
✅ **Wartbarkeit** - SOLID Principles & Dependency Injection  
✅ **Performance** - Optimierte State Management & Caching  
✅ **Sicherheit** - Firebase Security Rules & Input Validation  
✅ **UX Excellence** - Lottie Animations & Material Design 3  

Als Senior Architect ist diese Lösung enterprise-ready und production-tauglich! 🚀