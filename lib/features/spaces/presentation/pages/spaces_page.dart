import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/watch_my_spaces.dart';
import '../cubit/my_spaces_cubit.dart';
import '../widgets/signed_in_builder.dart';

/// Overview of the spaces the signed-in user belongs to (`/spaces`).
class SpacesPage extends StatelessWidget {
  const SpacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignedInBuilder(
      builder: (context, user) => BlocProvider(
        create: (context) =>
            MySpacesCubit(WatchMySpaces(context.read<SpacesRepository>()))
              ..watch(user.id),
        child: const _SpacesView(),
      ),
    );
  }
}

class _SpacesView extends StatelessWidget {
  const _SpacesView();

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
      body: BlocBuilder<MySpacesCubit, MySpacesState>(
        builder: (context, state) {
          if (state is MySpacesLoaded) {
            return state.spaces.isEmpty
                ? const _EmptySpaces()
                : _SpacesList(spaces: state.spaces);
          }
          if (state is MySpacesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
