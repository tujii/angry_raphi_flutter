import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Domain
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/user/domain/usecases/user_usecases.dart';

// Data
import '../../features/user/data/repositories/firestore_user_repository.dart';

// Presentation
import '../../features/user/presentation/bloc/user_bloc.dart';

final getIt = GetIt.instance;

/// Dependency injection setup following Clean Architecture
void setupDependencyInjection() {
  // External dependencies
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Data layer
  getIt.registerLazySingleton<UserRepository>(
    () => FirestoreUserRepository(getIt<FirebaseFirestore>()),
  );

  // Domain layer (Use cases)
  getIt.registerLazySingleton<GetUsersUseCase>(
    () => GetUsersUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<AddUserUseCase>(
    () => AddUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<UpdateUserRaphconsUseCase>(
    () => UpdateUserRaphconsUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<DeleteUserUseCase>(
    () => DeleteUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<AddSampleDataUseCase>(
    () => AddSampleDataUseCase(getIt<UserRepository>()),
  );

  // Presentation layer (BLoC)
  getIt.registerFactory<UserBloc>(
    () => UserBloc(
      getUsersUseCase: getIt<GetUsersUseCase>(),
      addSampleDataUseCase: getIt<AddSampleDataUseCase>(),
    ),
  );
}
