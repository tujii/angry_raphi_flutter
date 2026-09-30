import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/create_space.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/watch_membership.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/watch_my_spaces.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/watch_space.dart';
import 'package:angry_raphi/features/spaces/presentation/cubit/create_space_cubit.dart';
import 'package:angry_raphi/features/spaces/presentation/cubit/current_space_cubit.dart';
import 'package:angry_raphi/features/spaces/presentation/cubit/my_spaces_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'stream_spaces_repository.dart';

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late StreamSpacesRepository repository;

  setUp(() => repository = StreamSpacesRepository());
  tearDown(() => repository.dispose());

  group('MySpacesCubit', () {
    test('emits loaded spaces and errors', () async {
      final cubit = MySpacesCubit(WatchMySpaces(repository))..watch('uid1');
      expect(cubit.state, const MySpacesLoading());

      repository.mySpaces.add(Right([testSpace]));
      await pump();
      expect(cubit.state, MySpacesLoaded([testSpace]));

      repository.mySpaces.add(const Left(ServerFailure('denied')));
      await pump();
      expect(cubit.state, const MySpacesError('denied'));

      await cubit.close();
    });
  });

  group('CurrentSpaceCubit', () {
    late CurrentSpaceCubit cubit;

    setUp(() {
      cubit = CurrentSpaceCubit(
        WatchSpace(repository),
        WatchMembership(repository),
      )..watch('space1', 'uid1');
    });

    tearDown(() => cubit.close());

    test('is ready once membership and space are known', () async {
      repository.membership.add(Right(testMember(SpaceRole.member)));
      await pump();
      expect(cubit.state, const CurrentSpaceLoading());

      repository.space.add(Right(testSpace));
      await pump();
      expect(
        cubit.state,
        CurrentSpaceReady(testSpace, testMember(SpaceRole.member)),
      );
    });

    test('does not read the space without membership', () async {
      repository.membership.add(const Right(null));
      await pump();

      expect(cubit.state, const CurrentSpaceNoAccess());
      expect(repository.spaceSubscriptions, 0);
    });

    test('follows role changes', () async {
      repository.membership.add(Right(testMember(SpaceRole.member)));
      repository.space.add(Right(testSpace));
      await pump();

      repository.membership.add(Right(testMember(SpaceRole.admin)));
      await pump();

      expect(
        cubit.state,
        CurrentSpaceReady(testSpace, testMember(SpaceRole.admin)),
      );
      expect(repository.spaceSubscriptions, 1);
    });

    test('loses access when removed from the space', () async {
      repository.membership.add(Right(testMember(SpaceRole.member)));
      repository.space.add(Right(testSpace));
      await pump();

      repository.membership.add(const Right(null));
      await pump();

      expect(cubit.state, const CurrentSpaceNoAccess());
    });

    test('loses access when the space is deleted', () async {
      repository.membership.add(Right(testMember(SpaceRole.owner)));
      repository.space.add(const Right(null));
      await pump();

      expect(cubit.state, const CurrentSpaceNoAccess());
    });
  });

  group('CreateSpaceCubit', () {
    const params = CreateSpaceParams(
      name: 'Team',
      ownerUid: 'uid1',
      ownerDisplayName: 'Max',
    );

    test('emits success with the new space id', () async {
      final cubit = CreateSpaceCubit(CreateSpace(repository));
      final states = <CreateSpaceState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.submit(params);
      await pump();

      expect(states, const [
        CreateSpaceSubmitting(),
        CreateSpaceSuccess('newSpace'),
      ]);
      await subscription.cancel();
      await cubit.close();
    });

    test('emits failure from the repository', () async {
      repository.createResult = const Left(ServerFailure('offline'));
      final cubit = CreateSpaceCubit(CreateSpace(repository));

      await cubit.submit(params);

      expect(cubit.state, const CreateSpaceFailure('offline'));
      await cubit.close();
    });
  });
}
