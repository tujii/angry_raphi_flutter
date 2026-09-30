import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/entities/invite_code_entity.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/entities/space_invitation_entity.dart';
import '../../domain/entities/space_member_entity.dart';
import '../../domain/entities/space_role.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/invite_by_email.dart';
import '../../domain/usecases/invite_usecases.dart';
import '../../domain/usecases/remove_member.dart';
import '../../domain/usecases/update_member_role.dart';
import '../../domain/usecases/watch_membership.dart';
import '../../domain/usecases/watch_space.dart';
import '../../domain/usecases/watch_space_members.dart';
import '../cubit/current_space_cubit.dart';
import '../cubit/space_admin_cubit.dart';
import '../widgets/invite_links.dart';
import '../widgets/signed_in_builder.dart';
import '../widgets/space_role_badge.dart';

/// Members, invitations and settings of a space (`/s/:spaceId/members`).
class SpaceMembersPage extends StatelessWidget {
  final String spaceId;

  const SpaceMembersPage({super.key, required this.spaceId});

  @override
  Widget build(BuildContext context) {
    return SignedInBuilder(
      builder: (context, user) {
        final repository = context.read<SpacesRepository>();
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => CurrentSpaceCubit(
                WatchSpace(repository),
                WatchMembership(repository),
              )..watch(spaceId, user.id),
            ),
            BlocProvider(
              create: (_) => SpaceAdminCubit(
                watchMembers: WatchSpaceMembers(repository),
                watchInviteCodes: WatchInviteCodes(repository),
                watchInvitations: WatchSpaceInvitations(repository),
                updateMemberRole: UpdateMemberRole(repository),
                removeMember: RemoveMember(repository),
                createInviteLink: CreateInviteLink(repository),
                deactivateInviteCode: DeactivateInviteCode(repository),
                inviteByEmail: InviteByEmail(repository),
                revokeInvitation: RevokeInvitation(repository),
                deleteSpace: DeleteSpace(repository),
              ),
            ),
          ],
          child: BlocConsumer<CurrentSpaceCubit, CurrentSpaceState>(
            listener: (context, state) {
              if (state is CurrentSpaceReady) {
                context.read<SpaceAdminCubit>().watch(state.member);
              } else if (state is CurrentSpaceNoAccess) {
                // Left, removed or space deleted
                context.go(AppRouter.spaces);
              }
            },
            builder: (context, state) {
              if (state is CurrentSpaceReady) {
                return _MembersView(space: state.space, me: state.member);
              }
              if (state is CurrentSpaceError) {
                return Scaffold(
                  appBar: AppBar(),
                  body: Center(child: Text(state.message)),
                );
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        );
      },
    );
  }
}

void _showResult(BuildContext context, String? error, {String? success}) {
  final messenger = ScaffoldMessenger.of(context);
  if (error != null) {
    messenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red));
  } else if (success != null) {
    messenger.showSnackBar(SnackBar(content: Text(success)));
  }
}

Future<bool> _confirm(BuildContext context, String message,
    {required String action}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n?.cancel ?? 'Abbrechen'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _MembersView extends StatelessWidget {
  final SpaceEntity space;
  final SpaceMemberEntity me;

  const _MembersView({required this.space, required this.me});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('${l10n?.members ?? 'Mitglieder'} · ${space.name}'),
      ),
      body: BlocConsumer<SpaceAdminCubit, SpaceAdminState>(
        listenWhen: (previous, current) =>
            current.error != null && current.error != previous.error,
        listener: (context, state) => _showResult(context, state.error),
        builder: (context, state) {
          return ResponsiveHelper.wrapWithMaxWidth(
            context: context,
            maxWidth: 800,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                _SectionTitle(l10n?.members ?? 'Mitglieder'),
                if (state.members == null)
                  const Center(child: CircularProgressIndicator())
                else
                  for (final member in state.members!)
                    _MemberTile(member: member, me: me),
                if (me.role.canManageMembers) ...[
                  const SizedBox(height: AppConstants.largePadding),
                  _InviteLinksSection(
                      space: space, me: me, codes: state.inviteCodes),
                  const SizedBox(height: AppConstants.largePadding),
                  _EmailInviteSection(
                      space: space, me: me, invitations: state.invitations),
                ],
                const SizedBox(height: AppConstants.largePadding),
                _LeaveOrDeleteButton(space: space, me: me),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _MemberTile extends StatelessWidget {
  static const String _removeAction = 'remove';

  final SpaceMemberEntity member;
  final SpaceMemberEntity me;

  const _MemberTile({required this.member, required this.me});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMe = member.uid == me.uid;
    final canManage = !isMe && me.role.canManageMemberWithRole(member.role);
    final photoUrl = member.photoUrl;
    final name = member.displayName.isEmpty ? '?' : member.displayName;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? Text(name.characters.first.toUpperCase())
              : null,
        ),
        title: Text(isMe ? '$name ${l10n?.youSuffix ?? '(du)'}' : name),
        subtitle: member.email == null ? null : Text(member.email!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpaceRoleBadge(role: member.role),
            if (canManage)
              PopupMenuButton<String>(
                tooltip: l10n?.changeRole ?? 'Rolle ändern',
                // Values are role names or [_removeAction]; a null value
                // would not trigger onSelected.
                onSelected: (value) => value == _removeAction
                    ? _remove(context, name)
                    : _changeRole(context, SpaceRole.fromString(value)),
                itemBuilder: (context) => [
                  for (final role in me.role.assignableRoles)
                    if (role != member.role)
                      PopupMenuItem(
                        value: role.value,
                        child: Text(SpaceRoleBadge.label(context, role)),
                      ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _removeAction,
                    child: Text(
                      l10n?.removeMember ?? 'Entfernen',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeRole(BuildContext context, SpaceRole role) async {
    final error =
        await context.read<SpaceAdminCubit>().changeRole(member, role);
    if (context.mounted) _showResult(context, error);
  }

  Future<void> _remove(BuildContext context, String name) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      context,
      l10n?.removeMemberConfirm(name) ?? '$name aus diesem Bereich entfernen?',
      action: l10n?.removeMember ?? 'Entfernen',
    );
    if (!confirmed || !context.mounted) return;
    final error = await context.read<SpaceAdminCubit>().remove(member);
    if (context.mounted) _showResult(context, error);
  }
}

class _InviteLinksSection extends StatelessWidget {
  final SpaceEntity space;
  final SpaceMemberEntity me;
  final List<InviteCodeEntity> codes;

  const _InviteLinksSection({
    required this.space,
    required this.me,
    required this.codes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final usable = codes.where((code) => code.isUsableAt(now)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(l10n?.inviteLinks ?? 'Einladungslinks'),
        if (usable.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
            child: Text(
              l10n?.noActiveInviteLinks ?? 'Keine aktiven Einladungslinks',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        for (final code in usable) _InviteLinkTile(invite: code),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_link),
            label: Text(l10n?.createInviteLink ?? 'Link erstellen'),
            onPressed: () => _createLink(context),
          ),
        ),
      ],
    );
  }

  Future<void> _createLink(BuildContext context) async {
    final options = await showDialog<_LinkOptions>(
      context: context,
      builder: (_) => _CreateLinkDialog(
        roles: me.role.assignableRoles
            .where((role) => role != SpaceRole.owner)
            .toList(),
      ),
    );
    if (options == null || !context.mounted) return;

    final result = await context.read<SpaceAdminCubit>().createLink(
          spaceName: space.name,
          role: options.role,
          validFor: options.validFor,
        );
    if (!context.mounted) return;
    await result.fold(
      (failure) async => _showResult(context, failure.message),
      (code) => _copyLink(context, InviteLinks.build(space.id, code)),
    );
  }
}

Future<void> _copyLink(BuildContext context, String link) async {
  await Clipboard.setData(ClipboardData(text: link));
  if (context.mounted) {
    _showResult(context, null,
        success: AppLocalizations.of(context)?.inviteLinkCopied ??
            'Link in die Zwischenablage kopiert');
  }
}

class _InviteLinkTile extends StatelessWidget {
  final InviteCodeEntity invite;

  const _InviteLinkTile({required this.invite});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expiresAt = invite.expiresAt;
    final expiry = expiresAt == null
        ? (l10n?.neverExpires ?? 'läuft nie ab')
        : (l10n?.expiresOn(
                DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
                    .format(expiresAt)) ??
            'läuft ab am $expiresAt');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.link),
        title: Row(
          children: [
            SpaceRoleBadge(role: invite.role),
            const SizedBox(width: 8),
            Flexible(child: Text(expiry, overflow: TextOverflow.ellipsis)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: l10n?.copyLink ?? 'Link kopieren',
              onPressed: () => _copyLink(
                  context, InviteLinks.build(invite.spaceId, invite.code)),
            ),
            IconButton(
              icon: const Icon(Icons.link_off, color: Colors.red),
              tooltip: l10n?.deactivateLink ?? 'Deaktivieren',
              onPressed: () async {
                final error = await context
                    .read<SpaceAdminCubit>()
                    .deactivateLink(invite);
                if (context.mounted) _showResult(context, error);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkOptions {
  final SpaceRole role;
  final Duration? validFor;

  const _LinkOptions(this.role, this.validFor);
}

class _CreateLinkDialog extends StatefulWidget {
  final List<SpaceRole> roles;

  const _CreateLinkDialog({required this.roles});

  @override
  State<_CreateLinkDialog> createState() => _CreateLinkDialogState();
}

class _CreateLinkDialogState extends State<_CreateLinkDialog> {
  static const _validities = <Duration?>[
    Duration(days: 7),
    Duration(days: 30),
    null,
  ];

  late SpaceRole _role = widget.roles.contains(SpaceRole.member)
      ? SpaceRole.member
      : widget.roles.first;
  Duration? _validFor = const Duration(days: 7);

  String _validityLabel(AppLocalizations? l10n, Duration? validity) {
    if (validity == null) return l10n?.validityForever ?? 'Unbegrenzt';
    return validity.inDays == 7
        ? (l10n?.validity7Days ?? '7 Tage')
        : (l10n?.validity30Days ?? '30 Tage');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n?.createInviteLink ?? 'Link erstellen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<SpaceRole>(
            value: _role,
            decoration: InputDecoration(
              labelText: l10n?.inviteLinkRole ?? 'Rolle für neue Mitglieder',
            ),
            items: [
              for (final role in widget.roles)
                DropdownMenuItem(
                  value: role,
                  child: Text(SpaceRoleBadge.label(context, role)),
                ),
            ],
            onChanged: (role) => setState(() => _role = role ?? _role),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          DropdownButtonFormField<Duration?>(
            value: _validFor,
            decoration: InputDecoration(
              labelText: l10n?.inviteLinkValidity ?? 'Gültig für',
            ),
            items: [
              for (final validity in _validities)
                DropdownMenuItem(
                  value: validity,
                  child: Text(_validityLabel(l10n, validity)),
                ),
            ],
            onChanged: (validity) => setState(() => _validFor = validity),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pop(_LinkOptions(_role, _validFor)),
          child: Text(l10n?.createInviteLink ?? 'Link erstellen'),
        ),
      ],
    );
  }
}

class _EmailInviteSection extends StatefulWidget {
  final SpaceEntity space;
  final SpaceMemberEntity me;
  final List<SpaceInvitationEntity> invitations;

  const _EmailInviteSection({
    required this.space,
    required this.me,
    required this.invitations,
  });

  @override
  State<_EmailInviteSection> createState() => _EmailInviteSectionState();
}

class _EmailInviteSectionState extends State<_EmailInviteSection> {
  final _emailController = TextEditingController();
  SpaceRole _role = SpaceRole.member;
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _sending = true);
    final error = await context.read<SpaceAdminCubit>().inviteByEmail(
          spaceName: widget.space.name,
          email: email,
          role: _role,
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (error == null) _emailController.clear();
    _showResult(context, error,
        success: AppLocalizations.of(context)?.invitationCreated(email) ??
            'Einladung erstellt. $email sieht sie nach dem Anmelden.');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roles = widget.me.role.assignableRoles
        .where((role) => role != SpaceRole.owner)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(l10n?.inviteByEmail ?? 'Per E-Mail einladen'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                enabled: !_sending,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: l10n?.emailLabel ?? 'E-Mail-Adresse',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _invite(),
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            DropdownButton<SpaceRole>(
              value: _role,
              items: [
                for (final role in roles)
                  DropdownMenuItem(
                    value: role,
                    child: Text(SpaceRoleBadge.label(context, role)),
                  ),
              ],
              onChanged:
                  _sending ? null : (role) => setState(() => _role = role!),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            ElevatedButton(
              onPressed: _sending ? null : _invite,
              child: Text(l10n?.sendInvitation ?? 'Einladen'),
            ),
          ],
        ),
        if (widget.invitations.isNotEmpty) ...[
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            l10n?.pendingInvitations ?? 'Offene Einladungen',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          for (final invitation in widget.invitations)
            Card(
              child: ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(invitation.email),
                subtitle: Align(
                  alignment: Alignment.centerLeft,
                  child: SpaceRoleBadge(role: invitation.role),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final error = await context
                        .read<SpaceAdminCubit>()
                        .revoke(invitation);
                    if (context.mounted) _showResult(context, error);
                  },
                  child: Text(l10n?.revokeInvitation ?? 'Zurückziehen'),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _LeaveOrDeleteButton extends StatelessWidget {
  final SpaceEntity space;
  final SpaceMemberEntity me;

  const _LeaveOrDeleteButton({required this.space, required this.me});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOwner = me.role.canDeleteSpace;
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        icon: Icon(isOwner ? Icons.delete_forever : Icons.logout),
        label: Text(isOwner
            ? (l10n?.deleteSpace ?? 'Bereich löschen')
            : (l10n?.leaveSpace ?? 'Bereich verlassen')),
        onPressed: () => isOwner ? _delete(context) : _leave(context),
      ),
    );
  }

  Future<void> _leave(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      context,
      l10n?.leaveSpaceConfirm ?? 'Willst du diesen Bereich wirklich verlassen?',
      action: l10n?.leaveSpace ?? 'Bereich verlassen',
    );
    if (!confirmed || !context.mounted) return;
    // On success the membership disappears and the page navigates away.
    final error = await context.read<SpaceAdminCubit>().leave();
    if (context.mounted) _showResult(context, error);
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      context,
      l10n?.deleteSpaceConfirm(space.name) ??
          '„${space.name}“ mit allen Personen und Meldungen löschen? '
              'Das kann nicht rückgängig gemacht werden.',
      action: l10n?.deleteSpace ?? 'Bereich löschen',
    );
    if (!confirmed || !context.mounted) return;
    final error = await context.read<SpaceAdminCubit>().deleteSpace();
    if (context.mounted) _showResult(context, error);
  }
}
