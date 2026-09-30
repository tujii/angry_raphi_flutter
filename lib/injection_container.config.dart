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
import 'package:angry_raphi/features/admin/data/datasources/admin_remote_datasource.dart'
    as _i652;
import 'package:angry_raphi/features/admin/data/repositories/admin_repository_impl.dart'
    as _i540;
import 'package:angry_raphi/features/admin/domain/repositories/admin_repository.dart'
    as _i618;
import 'package:angry_raphi/features/admin/domain/usecases/add_admin.dart'
    as _i446;
import 'package:angry_raphi/features/admin/domain/usecases/check_admin_status.dart'
    as _i534;
import 'package:angry_raphi/features/admin/presentation/bloc/admin_bloc.dart'
    as _i100;
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
import 'package:angry_raphi/features/raphcon_management/data/datasources/raphcons_remote_datasource.dart'
    as _i42;
import 'package:angry_raphi/features/raphcon_management/data/repositories/raphcons_repository_impl.dart'
    as _i932;
import 'package:angry_raphi/features/raphcon_management/domain/repositories/raphcons_repository.dart'
    as _i158;
import 'package:angry_raphi/features/raphcon_management/domain/usecases/add_raphcon.dart'
    as _i661;
import 'package:angry_raphi/features/raphcon_management/domain/usecases/delete_raphcon.dart'
    as _i383;
import 'package:angry_raphi/features/raphcon_management/domain/usecases/get_all_raphcons_stream.dart'
    as _i389;
import 'package:angry_raphi/features/raphcon_management/domain/usecases/get_user_raphcon_statistics.dart'
    as _i717;
import 'package:angry_raphi/features/raphcon_management/domain/usecases/get_user_raphcons_by_type.dart'
    as _i154;
import 'package:angry_raphi/features/raphcon_management/domain/usecases/get_user_raphcons_by_type_stream.dart'
    as _i985;
import 'package:angry_raphi/features/raphcon_management/domain/usecases/get_user_raphcons_stream.dart'
    as _i1016;
import 'package:angry_raphi/features/raphcon_management/presentation/bloc/raphcon_bloc.dart'
    as _i36;
import 'package:angry_raphi/features/spaces/data/datasources/spaces_remote_datasource.dart'
    as _i638;
import 'package:angry_raphi/features/spaces/data/repositories/spaces_repository_impl.dart'
    as _i257;
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart'
    as _i108;
import 'package:angry_raphi/features/spaces/domain/usecases/create_space.dart'
    as _i585;
import 'package:angry_raphi/features/spaces/domain/usecases/invite_by_email.dart'
    as _i680;
import 'package:angry_raphi/features/spaces/domain/usecases/invite_usecases.dart'
    as _i1056;
import 'package:angry_raphi/features/spaces/domain/usecases/remove_member.dart'
    as _i793;
import 'package:angry_raphi/features/spaces/domain/usecases/update_member_role.dart'
    as _i788;
import 'package:angry_raphi/features/spaces/domain/usecases/watch_membership.dart'
    as _i967;
import 'package:angry_raphi/features/spaces/domain/usecases/watch_my_invitations.dart'
    as _i526;
import 'package:angry_raphi/features/spaces/domain/usecases/watch_my_spaces.dart'
    as _i801;
import 'package:angry_raphi/features/spaces/domain/usecases/watch_space.dart'
    as _i91;
import 'package:angry_raphi/features/spaces/domain/usecases/watch_space_members.dart'
    as _i257;
import 'package:angry_raphi/injection_container_module.dart' as _i1023;
import 'package:angry_raphi/services/admin_service.dart' as _i76;
import 'package:angry_raphi/services/registered_users_service.dart' as _i451;
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
    gh.factory<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.factory<_i974.FirebaseFirestore>(() => registerModule.firestore);
    gh.factory<_i457.FirebaseStorage>(() => registerModule.firebaseStorage);
    gh.factory<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.factory<_i895.Connectivity>(() => registerModule.connectivity);
    gh.factory<_i227.ImageHelper>(() => _i227.ImageHelper());
    gh.factory<_i652.AdminRemoteDataSource>(
        () => _i652.AdminRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i582.NetworkInfo>(
        () => _i582.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.factory<_i618.AdminRepository>(() => _i540.AdminRepositoryImpl(
          remoteDataSource: gh<_i652.AdminRemoteDataSource>(),
          networkInfo: gh<_i582.NetworkInfo>(),
        ));
    gh.factory<_i638.SpacesRemoteDataSource>(
        () => _i638.SpacesRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i446.AddAdmin>(
        () => _i446.AddAdmin(gh<_i618.AdminRepository>()));
    gh.factory<_i534.CheckAdminStatus>(
        () => _i534.CheckAdminStatus(gh<_i618.AdminRepository>()));
    gh.factory<_i42.RaphconsRemoteDataSource>(
        () => _i42.RaphconsRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i451.RegisteredUsersService>(
        () => _i451.RegisteredUsersService(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i306.AuthRemoteDataSource>(() => _i306.AuthRemoteDataSourceImpl(
          gh<_i59.FirebaseAuth>(),
          gh<_i116.GoogleSignIn>(),
          gh<_i974.FirebaseFirestore>(),
          gh<_i451.RegisteredUsersService>(),
        ));
    gh.factory<_i108.SpacesRepository>(() => _i257.SpacesRepositoryImpl(
          remoteDataSource: gh<_i638.SpacesRemoteDataSource>(),
          networkInfo: gh<_i582.NetworkInfo>(),
        ));
    gh.factory<_i526.WatchMyInvitations>(
        () => _i526.WatchMyInvitations(gh<_i108.SpacesRepository>()));
    gh.factory<_i793.RemoveMember>(
        () => _i793.RemoveMember(gh<_i108.SpacesRepository>()));
    gh.factory<_i801.WatchMySpaces>(
        () => _i801.WatchMySpaces(gh<_i108.SpacesRepository>()));
    gh.factory<_i585.CreateSpace>(
        () => _i585.CreateSpace(gh<_i108.SpacesRepository>()));
    gh.factory<_i680.InviteByEmail>(
        () => _i680.InviteByEmail(gh<_i108.SpacesRepository>()));
    gh.factory<_i967.WatchMembership>(
        () => _i967.WatchMembership(gh<_i108.SpacesRepository>()));
    gh.factory<_i788.UpdateMemberRole>(
        () => _i788.UpdateMemberRole(gh<_i108.SpacesRepository>()));
    gh.factory<_i257.WatchSpaceMembers>(
        () => _i257.WatchSpaceMembers(gh<_i108.SpacesRepository>()));
    gh.factory<_i91.WatchSpace>(
        () => _i91.WatchSpace(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.CreateInviteLink>(
        () => _i1056.CreateInviteLink(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.WatchInviteCodes>(
        () => _i1056.WatchInviteCodes(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.DeactivateInviteCode>(
        () => _i1056.DeactivateInviteCode(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.GetInviteCode>(
        () => _i1056.GetInviteCode(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.JoinSpaceWithCode>(
        () => _i1056.JoinSpaceWithCode(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.AcceptInvitation>(
        () => _i1056.AcceptInvitation(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.DeclineInvitation>(
        () => _i1056.DeclineInvitation(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.RevokeInvitation>(
        () => _i1056.RevokeInvitation(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.WatchSpaceInvitations>(
        () => _i1056.WatchSpaceInvitations(gh<_i108.SpacesRepository>()));
    gh.factory<_i1056.DeleteSpace>(
        () => _i1056.DeleteSpace(gh<_i108.SpacesRepository>()));
    gh.factory<_i938.AuthRepository>(() => _i271.AuthRepositoryImpl(
          remoteDataSource: gh<_i306.AuthRemoteDataSource>(),
          networkInfo: gh<_i582.NetworkInfo>(),
        ));
    gh.factory<_i158.RaphconsRepository>(() => _i932.RaphconsRepositoryImpl(
          remoteDataSource: gh<_i42.RaphconsRemoteDataSource>(),
          networkInfo: gh<_i582.NetworkInfo>(),
        ));
    gh.factory<_i154.GetUserRaphconsByType>(
        () => _i154.GetUserRaphconsByType(gh<_i158.RaphconsRepository>()));
    gh.factory<_i383.DeleteRaphcon>(
        () => _i383.DeleteRaphcon(gh<_i158.RaphconsRepository>()));
    gh.factory<_i1016.GetUserRaphconsStream>(
        () => _i1016.GetUserRaphconsStream(gh<_i158.RaphconsRepository>()));
    gh.factory<_i661.AddRaphcon>(
        () => _i661.AddRaphcon(gh<_i158.RaphconsRepository>()));
    gh.factory<_i985.GetUserRaphconsByTypeStream>(() =>
        _i985.GetUserRaphconsByTypeStream(gh<_i158.RaphconsRepository>()));
    gh.factory<_i389.GetAllRaphconsStream>(
        () => _i389.GetAllRaphconsStream(gh<_i158.RaphconsRepository>()));
    gh.factory<_i717.GetUserRaphconStatistics>(
        () => _i717.GetUserRaphconStatistics(gh<_i158.RaphconsRepository>()));
    gh.factory<_i660.GetCurrentUser>(
        () => _i660.GetCurrentUser(gh<_i938.AuthRepository>()));
    gh.factory<_i153.SignInWithGoogle>(
        () => _i153.SignInWithGoogle(gh<_i938.AuthRepository>()));
    gh.factory<_i456.SignOut>(() => _i456.SignOut(gh<_i938.AuthRepository>()));
    gh.factory<_i100.AdminBloc>(() => _i100.AdminBloc(
          gh<_i534.CheckAdminStatus>(),
          gh<_i446.AddAdmin>(),
        ));
    gh.factory<_i76.AdminService>(() => _i76.AdminService(
          adminRepository: gh<_i618.AdminRepository>(),
          firebaseAuth: gh<_i59.FirebaseAuth>(),
        ));
    gh.factory<_i36.RaphconBloc>(() => _i36.RaphconBloc(
          gh<_i661.AddRaphcon>(),
          gh<_i717.GetUserRaphconStatistics>(),
          gh<_i154.GetUserRaphconsByType>(),
          gh<_i383.DeleteRaphcon>(),
          gh<_i1016.GetUserRaphconsStream>(),
          gh<_i985.GetUserRaphconsByTypeStream>(),
        ));
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
