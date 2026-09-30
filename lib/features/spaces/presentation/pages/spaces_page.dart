import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/entities/space_invitation_entity.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/invite_usecases.dart';
import '../../domain/usecases/watch_my_invitations.dart';
import '../../domain/usecases/watch_my_spaces.dart';
import '../cubit/my_invitations_cubit.dart';
import '../cubit/my_spaces_cubit.dart';
import '../widgets/signed_in_builder.dart';
import '../widgets/space_role_badge.dart';

/// Overview of the spaces the signed-in user belongs to (`/spaces`).
class SpacesPage extends StatelessWidget {
  const SpacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignedInBuilder(
      builder: (context, user) {
        final repository = context.read<SpacesRepository>();
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  MySpacesCubit(WatchMySpaces(repository))..watch(user.id),
            ),
            BlocProvider(
              create: (_) => MyInvitationsCubit(
                WatchMyInvitations(repository),
                AcceptInvitation(repository),
                DeclineInvitation(repository),
              )..watch(user.email),
            ),
          ],
          child: _SpacesView(user: user),
        );
      },
    );
  }
}

class _SpacesView extends StatelessWidget {
  final UserEntity user;

  const _SpacesView({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(l10n?.mySpaces ?? 'Meine Bereiche'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: AppConstants.appName,
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRouter.createSpace),
        icon: const Icon(Icons.add),
        label: Text(l10n?.createSpace ?? 'Bereich anlegen'),
      ),
      body: Column(
        children: [
          _MyInvitations(user: user),
          Expanded(
            child: BlocBuilder<MySpacesCubit, MySpacesState>(
              builder: (context, state) {
                if (state is MySpacesLoaded) {
                  return state.spaces.isEmpty
                      ? const _EmptySpaces()
                      : _SpacesList(spaces: state.spaces);
                }
                if (state is MySpacesError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Text(
                        '${l10n?.error ?? 'Fehler'}: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacesList extends StatelessWidget {
  final List<SpaceEntity> spaces;

  const _SpacesList({required this.spaces});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.wrapWithMaxWidth(
      context: context,
      child: ListView.builder(
        // Leave room for the floating action button
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: spaces.length,
        itemBuilder: (context, index) {
          final space = spaces[index];
          final description = space.description;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                child: Text(space.name.characters.first.toUpperCase()),
              ),
              title: Text(space.name),
              subtitle: description == null || description.isEmpty
                  ? null
                  : Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppRouter.space(space.id)),
            ),
          );
        },
      ),
    );
  }
}

class _EmptySpaces extends StatelessWidget {
  const _EmptySpaces();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspaces_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n?.noSpacesYet ?? 'Du bist noch in keinem Bereich.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.noSpacesHint ??
                  'Lege einen Bereich an und lade andere ein, um gemeinsam Meldungen zu machen.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pending email invitations of the user, shown above the spaces.
class _MyInvitations extends StatelessWidget {
  final UserEntity user;

  const _MyInvitations({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<MyInvitationsCubit, List<SpaceInvitationEntity>>(
      builder: (context, invitations) {
        if (invitations.isEmpty) return const SizedBox.shrink();
        return ResponsiveHelper.wrapWithMaxWidth(
          context: context,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n?.yourInvitations ?? 'Deine Einladungen',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final invitation in invitations)
                  Card(
                    color: AppConstants.primaryColor.withValues(alpha: 0.08),
                    child: ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: Text(invitation.spaceName),
                      subtitle: Text(l10n?.invitedAs(
                              SpaceRoleBadge.label(context, invitation.role)) ??
                          'Eingeladen als ${SpaceRoleBadge.label(context, invitation.role)}'),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          TextButton(
                            onPressed: () => _decline(context, invitation),
                            child: Text(l10n?.declineInvitation ?? 'Ablehnen'),
                          ),
                          ElevatedButton(
                            onPressed: () => _accept(context, invitation),
                            child: Text(l10n?.acceptInvitation ?? 'Annehmen'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _accept(
      BuildContext context, SpaceInvitationEntity invitation) async {
    final error = await context.read<MyInvitationsCubit>().accept(
          invitation,
          MemberProfile(
            uid: user.id,
            displayName: user.displayName,
            email: user.email,
            photoUrl: user.photoURL,
          ),
        );
    if (!context.mounted) return;
    if (error == null) {
      context.go(AppRouter.space(invitation.spaceId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  Future<void> _decline(
      BuildContext context, SpaceInvitationEntity invitation) async {
    final error = await context.read<MyInvitationsCubit>().decline(invitation);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }
}
