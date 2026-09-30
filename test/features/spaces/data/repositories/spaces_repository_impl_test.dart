import 'dart:async';

import 'package:angry_raphi/core/errors/exceptions.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/core/network/network_info.dart';
import 'package:angry_raphi/features/spaces/data/datasources/spaces_remote_datasource.dart';
import 'package:angry_raphi/features/spaces/data/models/space_member_model.dart';
import 'package:angry_raphi/features/spaces/data/models/space_model.dart';
import 'package:angry_raphi/features/spaces/data/repositories/spaces_repository_impl.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class FakeSpacesRemoteDataSource implements SpacesRemoteDataSource {
  final spacesController = StreamController<List<SpaceModel>>();
  SpaceModel? createdSpace;
  SpaceMemberModel? createdOwner;
  bool failCreate = false;

  @override
  Future<String> createSpace(SpaceModel space, SpaceMemberModel owner) async {
    if (failCreate) throw ServerException('boom');
    createdSpace = space;
    createdOwner = owner;
    return 'space1';
  }

  @override
  Stream<List<SpaceModel>> watchMySpaces(String uid) => spacesController.stream;

  Future<void> dispose() => spacesController.close();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late FakeSpacesRemoteDataSource dataSource;
  late FakeNetworkInfo networkInfo;
  late SpacesRepositoryImpl repository;

  const params = CreateSpaceParams(
    name: 'Team',
    ownerUid: 'uid1',
    ownerDisplayName: 'Max',
    ownerEmail: 'Max@Example.com',
  );

  setUp(() {
    dataSource = FakeSpacesRemoteDataSource();
    networkInfo = FakeNetworkInfo();
    repository = SpacesRepositoryImpl(
      remoteDataSource: dataSource,
      networkInfo: networkInfo,
    );
  });

  group('createSpace', () {
    test('creates space with the creator as owner', () async {
      final result = await repository.createSpace(params);

      expect(result.getOrElse(() => ''), 'space1');
      expect(dataSource.createdSpace!.createdBy, 'uid1');
      expect(dataSource.createdOwner!.role, SpaceRole.owner);
      expect(dataSource.createdOwner!.email, 'max@example.com');
    });

    test('returns NetworkFailure when offline', () async {
      networkInfo.connected = false;
      final result = await repository.createSpace(params);

      expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
      expect(dataSource.createdSpace, isNull);
    });

    test('maps ServerException to ServerFailure', () async {
      dataSource.failCreate = true;
      final result = await repository.createSpace(params);

      expect(result.fold((f) => f, (_) => null), isA<ServerFailure>());
    });
  });

  test('watchMySpaces keeps emitting after an error', () async {
    final events = <String>[];
    final subscription = repository.watchMySpaces('uid1').listen((event) {
      events.add(event.fold((f) => 'failure', (spaces) => '${spaces.length}'));
    });

    final space = SpaceModel(
      id: 's1',
      name: 'Team',
      createdBy: 'uid1',
      createdAt: DateTime(2024),
    );
    dataSource.spacesController
      ..add([space])
      ..addError(Exception('permission-denied'))
      ..add([space, space]);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    await dataSource.dispose();

    expect(events, ['1', 'failure', '2']);
  });
}
