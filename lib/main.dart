import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'firebase_options.dart';
import 'features/user/data/repositories/firestore_user_repository.dart';
import 'features/user/domain/usecases/user_usecases.dart';
import 'features/user/presentation/bloc/user_bloc.dart';
import 'services/admin_service.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/domain/usecases/check_admin_status.dart';
import 'features/admin/domain/usecases/add_admin.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/raphcon_management/data/repositories/raphcons_repository_impl.dart';
import 'features/raphcon_management/data/datasources/raphcons_remote_datasource.dart';
import 'features/raphcon_management/domain/usecases/add_raphcon.dart';
import 'features/raphcon_management/domain/usecases/get_user_raphcon_statistics.dart';
import 'features/raphcon_management/domain/usecases/get_user_raphcons_by_type.dart';
import 'features/raphcon_management/domain/usecases/get_user_raphcons_stream.dart';
import 'features/raphcon_management/domain/usecases/get_user_raphcons_by_type_stream.dart';
import 'features/raphcon_management/domain/usecases/delete_raphcon.dart';
import 'features/raphcon_management/presentation/bloc/raphcon_bloc.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/domain/usecases/sign_in_with_google.dart';
import 'services/registered_users_service.dart';
import 'features/authentication/domain/usecases/sign_out.dart';
import 'features/authentication/domain/usecases/get_current_user.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'core/network/network_info.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

class AngryRaphiApp extends StatelessWidget {
  const AngryRaphiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final repository =
                FirestoreUserRepository(FirebaseFirestore.instance);
            final getUsersUseCase = GetUsersUseCase(repository);
            final getUsersStreamUseCase = GetUsersStreamUseCase(repository);
            final addUserUseCase = AddUserUseCase(repository);
            final deleteUserUseCase = DeleteUserUseCase(repository);
            return UserBloc(
              getUsersUseCase: getUsersUseCase,
              getUsersStreamUseCase: getUsersStreamUseCase,
              addUserUseCase: addUserUseCase,
              deleteUserUseCase: deleteUserUseCase,
            );
          },
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
          create: (_) {
            final firestore = FirebaseFirestore.instance;
            final connectivity = Connectivity();
            final networkInfo = NetworkInfoImpl(connectivity);
            final raphconDataSource = RaphconsRemoteDataSourceImpl(firestore);
            final raphconRepository = RaphconsRepositoryImpl(
              remoteDataSource: raphconDataSource,
              networkInfo: networkInfo,
            );
            final addRaphcon = AddRaphcon(raphconRepository);
            final getUserRaphconStatistics =
                GetUserRaphconStatistics(raphconRepository);
            final getUserRaphconsByType =
                GetUserRaphconsByType(raphconRepository);
            final deleteRaphcon = DeleteRaphcon(raphconRepository);
            final getUserRaphconsStream =
                GetUserRaphconsStream(raphconRepository);
            final getUserRaphconsByTypeStream =
                GetUserRaphconsByTypeStream(raphconRepository);

            return RaphconBloc(
              addRaphcon,
              getUserRaphconStatistics,
              getUserRaphconsByType,
              deleteRaphcon,
              getUserRaphconsStream,
              getUserRaphconsByTypeStream,
            );
          },
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
        routerConfig: router,
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
