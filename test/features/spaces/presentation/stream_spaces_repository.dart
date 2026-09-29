import 'dart:async';

import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_member_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:dartz/dartz.dart';

/// Test repository whose streams are driven by the test.
class StreamSpacesRepository implements SpacesRepository {
  final mySpaces = StreamController<Either<Failure, List<SpaceEntity>>>();
  final space = StreamController<Either<Failure, SpaceEntity?>>();
  final membership = StreamController<Either<Failure, SpaceMemberEntity?>>();

  CreateSpaceParams? lastCreate;
  Either<Failure, String> createResult = const Right('newSpace');
  int spaceSubscriptions = 0;

  @override
  Stream<Either<Failure, List<SpaceEntity>>> watchMySpaces(String uid) =>
      mySpaces.stream;

  @override
  Stream<Either<Failure, SpaceEntity?>> watchSpace(String spaceId) {
    spaceSubscriptions++;
    return space.stream;
  }

  @override
  Stream<Either<Failure, SpaceMemberEntity?>> watchMembership(
          String spaceId, String uid) =>
      membership.stream;

  @override
  Future<Either<Failure, String>> createSpace(CreateSpaceParams params) async {
    lastCreate = params;
    return createResult;
  }

  /// Not awaited: closing a controller that was never listened to
  /// never completes.
  void dispose() {
    unawaited(mySpaces.close());
    unawaited(space.close());
    unawaited(membership.close());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

final testSpace = SpaceEntity(
  id: 'space1',
  name: 'Team Rocket',
  description: 'Prepare for trouble',
  createdBy: 'uid1',
  createdAt: DateTime(2024),
);

SpaceMemberEntity testMember(SpaceRole role) => SpaceMemberEntity(
      uid: 'uid1',
      spaceId: 'space1',
      role: role,
      displayName: 'Max',
      joinedAt: DateTime(2024),
    );
