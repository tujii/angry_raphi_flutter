import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/data/data_scope.dart';
import '../core/network/network_info.dart';
import '../features/raphcon_management/data/datasources/raphcons_remote_datasource.dart';
import '../features/raphcon_management/data/repositories/raphcons_repository_impl.dart';
import '../features/raphcon_management/domain/usecases/add_raphcon.dart';
import '../features/raphcon_management/domain/usecases/delete_raphcon.dart';
import '../features/raphcon_management/domain/usecases/get_user_raphcon_statistics.dart';
import '../features/raphcon_management/domain/usecases/get_user_raphcons_by_type.dart';
import '../features/raphcon_management/domain/usecases/get_user_raphcons_by_type_stream.dart';
import '../features/raphcon_management/domain/usecases/get_user_raphcons_stream.dart';
import '../features/raphcon_management/presentation/bloc/raphcon_bloc.dart';
import '../features/user/data/repositories/firestore_user_repository.dart';
import '../features/user/domain/usecases/user_usecases.dart';
import '../features/user/presentation/bloc/user_bloc.dart';

/// Creates a [UserBloc] reading the persons of [scope].
UserBloc createUserBloc(FirebaseFirestore firestore, DataScope scope) {
  final repository = FirestoreUserRepository(firestore, scope: scope);
  return UserBloc(
    getUsersUseCase: GetUsersUseCase(repository),
    getUsersStreamUseCase: GetUsersStreamUseCase(repository),
    addUserUseCase: AddUserUseCase(repository),
    deleteUserUseCase: DeleteUserUseCase(repository),
  );
}

/// Creates a [RaphconBloc] reading and writing the raphcons of [scope].
RaphconBloc createRaphconBloc(FirebaseFirestore firestore, DataScope scope) {
  final repository = RaphconsRepositoryImpl(
    remoteDataSource: RaphconsRemoteDataSourceImpl(firestore, scope: scope),
    networkInfo: NetworkInfoImpl(Connectivity()),
  );
  return RaphconBloc(
    AddRaphcon(repository),
    GetUserRaphconStatistics(repository),
    GetUserRaphconsByType(repository),
    DeleteRaphcon(repository),
    GetUserRaphconsStream(repository),
    GetUserRaphconsByTypeStream(repository),
  );
}
