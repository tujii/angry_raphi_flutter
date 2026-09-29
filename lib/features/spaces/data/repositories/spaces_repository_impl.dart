import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/entities/space_invitation_entity.dart';
import '../../domain/entities/space_member_entity.dart';
import '../../domain/entities/space_role.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../datasources/spaces_remote_datasource.dart';
import '../models/space_invitation_model.dart';
import '../models/space_member_model.dart';
import '../models/space_model.dart';

@Injectable(as: SpacesRepository)
class SpacesRepositoryImpl implements SpacesRepository {
  final SpacesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SpacesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> createSpace(CreateSpaceParams params) {
    final now = DateTime.now();
    return _guard(() => remoteDataSource.createSpace(
          SpaceModel(
            id: '',
            name: params.name,
            description: params.description,
            createdBy: params.ownerUid,
            createdAt: now,
          ),
          SpaceMemberModel(
            uid: params.ownerUid,
            spaceId: '',
            role: SpaceRole.owner,
            displayName: params.ownerDisplayName,
            email: params.ownerEmail?.toLowerCase(),
            photoUrl: params.ownerPhotoUrl,
            joinedAt: now,
          ),
        ));
  }

  @override
  Future<Either<Failure, void>> updateSpace(
    String spaceId, {
    required String name,
    String? description,
  }) {
    return _guard(
        () => remoteDataSource.updateSpace(spaceId, name, description));
  }

  @override
  Future<Either<Failure, void>> deleteSpace(String spaceId) {
    return _guard(() => remoteDataSource.deleteSpace(spaceId));
  }

  @override
  Stream<Either<Failure, List<SpaceEntity>>> watchMySpaces(String uid) {
    return _guardStream(remoteDataSource.watchMySpaces(uid));
  }

  @override
  Stream<Either<Failure, SpaceEntity?>> watchSpace(String spaceId) {
    return _guardStream(remoteDataSource.watchSpace(spaceId));
  }

  @override
  Stream<Either<Failure, SpaceMemberEntity?>> watchMembership(
      String spaceId, String uid) {
    return _guardStream(remoteDataSource.watchMembership(spaceId, uid));
  }

  @override
  Stream<Either<Failure, List<SpaceMemberEntity>>> watchMembers(
      String spaceId) {
    return _guardStream(remoteDataSource.watchMembers(spaceId));
  }

  @override
  Future<Either<Failure, void>> updateMemberRole(
      String spaceId, String uid, SpaceRole role) {
    return _guard(() => remoteDataSource.updateMemberRole(spaceId, uid, role));
  }

  @override
  Future<Either<Failure, void>> removeMember(String spaceId, String uid) {
    return _guard(() => remoteDataSource.removeMember(spaceId, uid));
  }

  @override
  Future<Either<Failure, String>> inviteByEmail(InviteByEmailParams params) {
    return _guard(() => remoteDataSource.createInvitation(SpaceInvitationModel(
          id: '',
          spaceId: params.spaceId,
          spaceName: params.spaceName,
          email: params.email,
          role: params.role,
          invitedBy: params.invitedBy,
          createdAt: DateTime.now(),
        )));
  }

  @override
  Future<Either<Failure, void>> revokeInvitation(String invitationId) {
    return _guard(() => remoteDataSource.setInvitationStatus(
        invitationId, InvitationStatus.revoked));
  }

  @override
  Future<Either<Failure, void>> declineInvitation(String invitationId) {
    return _guard(() => remoteDataSource.setInvitationStatus(
        invitationId, InvitationStatus.declined));
  }

  @override
  Stream<Either<Failure, List<SpaceInvitationEntity>>> watchSpaceInvitations(
      String spaceId) {
    return _guardStream(remoteDataSource.watchSpaceInvitations(spaceId));
  }

  @override
  Stream<Either<Failure, List<SpaceInvitationEntity>>> watchMyInvitations(
      String email) {
    return _guardStream(remoteDataSource.watchMyInvitations(email));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Wraps data events in [Right] and turns stream errors (e.g. permission
  /// denied after being removed from a space) into [Left] events.
  Stream<Either<Failure, T>> _guardStream<T>(Stream<T> source) {
    // Map first: the source's runtime type may be a subtype of Stream<T>
    // (e.g. Stream<List<SpaceModel>>), which a StreamTransformer<T, _>
    // would not accept.
    return source.map<Either<Failure, T>>((data) => Right(data)).transform(
          StreamTransformer<Either<Failure, T>,
              Either<Failure, T>>.fromHandlers(
            handleError: (error, stackTrace, sink) =>
                sink.add(Left(ServerFailure(error.toString()))),
          ),
        );
  }
}
