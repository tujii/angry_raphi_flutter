import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/constants/app_constants.dart';
import 'core/data/data_scope.dart';
import 'core/network/network_info.dart';
import 'core/routing/app_router.dart';
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/usecases/add_admin.dart';
import 'features/admin/domain/usecases/check_admin_status.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/usecases/get_current_user.dart';
import 'features/authentication/domain/usecases/sign_in_with_google.dart';
import 'features/authentication/domain/usecases/sign_out.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/spaces/data/datasources/spaces_remote_datasource.dart';
import 'features/spaces/data/repositories/spaces_repository_impl.dart';
import 'features/spaces/domain/repositories/spaces_repository.dart';
import 'firebase_options.dart';
import 'services/admin_service.dart';
import 'services/registered_users_service.dart';
import 'shared/scoped_blocs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for web to show clean URLs without #
  setUrlStrategy(PathUrlStrategy());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize admin service
  await _initializeAdmin();

  runApp(const AngryRaphiApp());
}

Future<void> _initializeAdmin() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final firebaseAuth = FirebaseAuth.instance;
    final connectivity = Connectivity();

    final networkInfo = NetworkInfoImpl(connectivity);
    final adminDataSource = AdminRemoteDataSourceImpl(firestore);
    final adminRepository = AdminRepositoryImpl(
      remoteDataSource: adminDataSource,
      networkInfo: networkInfo,
    );

    final adminService = AdminService(
      adminRepository: adminRepository,
      firebaseAuth: firebaseAuth,
    );

    // Ensure admin exists
    await adminService.ensureAdminExists('17tujii@gmail.com');
    await adminService.ensureAdminExists('uhlmannraphael@gmail.com');
  } catch (e) {
    // Error initializing admin: silent fail in production
  }
}

class AngryRaphiApp extends StatefulWidget {
  const AngryRaphiApp({super.key});

  @override
  State<AngryRaphiApp> createState() => _AngryRaphiAppState();
}

class _AngryRaphiAppState extends State<AngryRaphiApp> {
  late final StreamListenable _authChanges;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authChanges = StreamListenable(FirebaseAuth.instance.authStateChanges());
    _router = AppRouter.createRouter(refreshListenable: _authChanges);
  }

  @override
  void dispose() {
    _router.dispose();
    _authChanges.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<SpacesRepository>(
      create: (_) => SpacesRepositoryImpl(
        remoteDataSource:
            SpacesRemoteDataSourceImpl(FirebaseFirestore.instance),
        networkInfo: NetworkInfoImpl(Connectivity()),
      ),
      child: _buildBlocs(context),
    );
  }

  Widget _buildBlocs(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              createUserBloc(FirebaseFirestore.instance, DataScope.legacy),
        ),
        BlocProvider(
          create: (_) {
            final firestore = FirebaseFirestore.instance;
            final connectivity = Connectivity();
            final networkInfo = NetworkInfoImpl(connectivity);
            final adminDataSource = AdminRemoteDataSourceImpl(firestore);
            final adminRepository = AdminRepositoryImpl(
              remoteDataSource: adminDataSource,
              networkInfo: networkInfo,
            );
            final checkAdminStatus = CheckAdminStatus(adminRepository);
            final addAdmin = AddAdmin(adminRepository);

            return AdminBloc(checkAdminStatus, addAdmin);
          },
        ),
        BlocProvider(
          create: (_) =>
              createRaphconBloc(FirebaseFirestore.instance, DataScope.legacy),
        ),
        BlocProvider(
          create: (_) {
            final firebaseAuth = FirebaseAuth.instance;
            final googleSignIn = GoogleSignIn(
              scopes: ['email'],
            );
            final firestore = FirebaseFirestore.instance;
            final connectivity = Connectivity();
            final networkInfo = NetworkInfoImpl(connectivity);

            // Create RegisteredUsersService
            final registeredUsersService = RegisteredUsersService(firestore);

            final authDataSource = AuthRemoteDataSourceImpl(
              firebaseAuth,
              googleSignIn,
              firestore,
              registeredUsersService,
            );

            final authRepository = AuthRepositoryImpl(
              remoteDataSource: authDataSource,
              networkInfo: networkInfo,
            );

            final signInWithGoogle = SignInWithGoogle(authRepository);
            final signOut = SignOut(authRepository);
            final getCurrentUser = GetCurrentUser(authRepository);

            return AuthBloc(
                signInWithGoogle, signOut, getCurrentUser, authRepository)
              ..add(AuthStarted());
          },
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: _buildTheme(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('de'),
        ],
        routerConfig: _router,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }
}

// UserListPage is now in features/user/presentation/widgets/user_list_page.dart
