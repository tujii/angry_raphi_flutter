import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/invite_usecases.dart';
import '../../domain/usecases/watch_membership.dart';
import '../cubit/join_space_cubit.dart';
import '../widgets/signed_in_builder.dart';
import '../widgets/space_role_badge.dart';

/// Target of an invite link (`/join/:spaceId/:code`).
class JoinSpacePage extends StatelessWidget {
  final String spaceId;
  final String code;

  const JoinSpacePage({super.key, required this.spaceId, required this.code});

  @override
  Widget build(BuildContext context) {
    return SignedInBuilder(
      builder: (context, user) => BlocProvider(
        create: (context) {
          final repository = context.read<SpacesRepository>();
          return JoinSpaceCubit(
            GetInviteCode(repository),
            WatchMembership(repository),
            JoinSpaceWithCode(repository),
          )..load(spaceId, code, user.id);
        },
        child: BlocConsumer<JoinSpaceCubit, JoinSpaceState>(
          listener: (context, state) {
            if (state is JoinSpaceJoined) {
              context.go(AppRouter.space(state.spaceId));
            } else if (state is JoinSpaceReady && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ));
            }
          },
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              backgroundColor: AppConstants.backgroundColor,
              appBar: AppBar(
                title: Text(l10n?.joinSpaceTitle ?? 'Bereich beitreten'),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  child: _buildContent(context, state, () {
                    context.read<JoinSpaceCubit>().join(MemberProfile(
                          uid: user.id,
                          displayName: user.displayName,
                          email: user.email,
                          photoUrl: user.photoURL,
                        ));
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, JoinSpaceState state, VoidCallback onJoin) {
    final l10n = AppLocalizations.of(context);
    if (state is JoinSpaceReady) {
      final invite = state.invite;
      final role = SpaceRoleBadge.label(context, invite.role);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group_add,
              size: 64, color: AppConstants.primaryColor),
          const SizedBox(height: 16),
          Text(
            l10n?.joinSpaceQuestion(invite.spaceName, role) ??
                'Du wurdest in „${invite.spaceName}“ als $role eingeladen.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: state.joining ? null : onJoin,
            child: state.joining
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n?.joinSpaceButton ?? 'Beitreten'),
          ),
        ],
      );
    }
    if (state is JoinSpaceInvalid) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n?.inviteLinkInvalid ??
                'Dieser Einladungslink ist ungültig oder abgelaufen.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRouter.spaces),
            child: Text(l10n?.backToSpaces ?? 'Zurück zu meinen Bereichen'),
          ),
        ],
      );
    }
    return const CircularProgressIndicator();
  }
}
