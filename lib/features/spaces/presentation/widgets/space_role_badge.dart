import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/entities/space_role.dart';

/// Small colored label showing a member's role in a space.
class SpaceRoleBadge extends StatelessWidget {
  final SpaceRole role;

  const SpaceRoleBadge({super.key, required this.role});

  static String label(BuildContext context, SpaceRole role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case SpaceRole.owner:
        return l10n?.spaceRoleOwner ?? 'Owner';
      case SpaceRole.admin:
        return l10n?.spaceRoleAdmin ?? 'Admin';
      case SpaceRole.member:
        return l10n?.spaceRoleMember ?? 'Mitglied';
      case SpaceRole.viewer:
        return l10n?.spaceRoleViewer ?? 'Betrachter';
    }
  }

  static Color color(SpaceRole role) {
    switch (role) {
      case SpaceRole.owner:
        return Colors.deepPurple;
      case SpaceRole.admin:
        return Colors.green;
      case SpaceRole.member:
        return Colors.blue;
      case SpaceRole.viewer:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color(role),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label(context, role).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
