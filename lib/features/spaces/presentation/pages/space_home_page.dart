import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/data_scope.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/scoped_blocs.dart';
import '../../../raphcon_management/presentation/bloc/raphcon_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/widgets/public_user_list_page.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/watch_membership.dart';
import '../../domain/usecases/watch_space.dart';
import '../cubit/current_space_cubit.dart';
import '../widgets/signed_in_builder.dart';

/// Home of a single space (`/s/:spaceId`): the ranking of its persons.
///
/// Access is checked via the membership of the signed-in user; the person
/// and raphcon blocs are scoped to the space's collections.
class SpaceHomePage extends StatelessWidget {
  final String spaceId;

  const SpaceHomePage({super.key, required this.spaceId});

  @override
  Widget build(BuildContext context) {
    return SignedInBuilder(
      builder: (context, user) => BlocProvider(
        create: (context) {
          final repository = context.read<SpacesRepository>();
          return CurrentSpaceCubit(
            WatchSpace(repository),
            WatchMembership(repository),
          )..watch(spaceId, user.id);
        },
        child: _SpaceHomeView(spaceId: spaceId),
      ),
    );
  }
}

class _SpaceHomeView extends StatelessWidget {
  final String spaceId;

  const _SpaceHomeView({required this.spaceId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentSpaceCubit, CurrentSpaceState>(
      // Only rebuild the data blocs when access changes, not on every
      // update of the space or membership document.
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          current is! CurrentSpaceReady,
      builder: (context, state) {
        if (state is CurrentSpaceReady) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<UserBloc>(
                create: (_) => createUserBloc(
                    FirebaseFirestore.instance, DataScope.space(spaceId)),
              ),
              BlocProvider<RaphconBloc>(
                create: (_) => createRaphconBloc(
                    FirebaseFirestore.instance, DataScope.space(spaceId)),
              ),
            ],
            child: const _SpaceListPage(),
          );
        }
        if (state is CurrentSpaceNoAccess || state is CurrentSpaceError) {
          return _NoAccessView(
            message: state is CurrentSpaceError ? state.message : null,
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

/// Keeps the list page in sync with renames and role changes.
class _SpaceListPage extends StatelessWidget {
  const _SpaceListPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentSpaceCubit, CurrentSpaceState>(
      buildWhen: (_, current) => current is CurrentSpaceReady,
      builder: (context, state) {
        final ready = state as CurrentSpaceReady;
        return PublicUserListPage(space: ready.space, member: ready.member);
      },
    );
  }
}

class _NoAccessView extends StatelessWidget {
  final String? message;

  const _NoAccessView({this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n?.spaceNoAccess ??
                    'Diesen Bereich gibt es nicht oder du hast keinen Zugriff.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRouter.spaces),
                child: Text(l10n?.backToSpaces ?? 'Zurück zu meinen Bereichen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
