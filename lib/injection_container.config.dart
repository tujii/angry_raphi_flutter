// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:angry_raphi/core/network/network_info.dart' as _i582;
import 'package:angry_raphi/core/utils/image_helper.dart' as _i227;
import 'package:angry_raphi/features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i306;
import 'package:angry_raphi/features/authentication/data/repositories/auth_repository_impl.dart'
    as _i271;
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart'
    as _i938;
import 'package:angry_raphi/features/authentication/domain/usecases/get_current_user.dart'
    as _i660;
import 'package:angry_raphi/features/authentication/domain/usecases/sign_in_with_google.dart'
    as _i153;
import 'package:angry_raphi/features/authentication/domain/usecases/sign_out.dart'
    as _i456;
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i670;
import 'package:angry_raphi/injection_container_module.dart' as _i1023;
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.factory<_i227.ImageHelper>(() => _i227.ImageHelper());
    gh.factory<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.factory<_i974.FirebaseFirestore>(() => registerModule.firestore);
    gh.factory<_i457.FirebaseStorage>(() => registerModule.firebaseStorage);
    gh.factory<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.factory<_i895.Connectivity>(() => registerModule.connectivity);
    gh.factory<_i582.NetworkInfo>(
        () => _i582.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.factory<_i306.AuthRemoteDataSource>(() => _i306.AuthRemoteDataSourceImpl(
          gh<_i59.FirebaseAuth>(),
          gh<_i116.GoogleSignIn>(),
          gh<_i974.FirebaseFirestore>(),
        ));
    gh.factory<_i938.AuthRepository>(() => _i271.AuthRepositoryImpl(
          remoteDataSource: gh<_i306.AuthRemoteDataSource>(),
          networkInfo: gh<_i582.NetworkInfo>(),
        ));
    gh.factory<_i456.SignOut>(() => _i456.SignOut(gh<_i938.AuthRepository>()));
    gh.factory<_i153.SignInWithGoogle>(
        () => _i153.SignInWithGoogle(gh<_i938.AuthRepository>()));
    gh.factory<_i660.GetCurrentUser>(
        () => _i660.GetCurrentUser(gh<_i938.AuthRepository>()));
    gh.factory<_i670.AuthBloc>(() => _i670.AuthBloc(
          gh<_i153.SignInWithGoogle>(),
          gh<_i456.SignOut>(),
          gh<_i660.GetCurrentUser>(),
          gh<_i938.AuthRepository>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i1023.RegisterModule {}
