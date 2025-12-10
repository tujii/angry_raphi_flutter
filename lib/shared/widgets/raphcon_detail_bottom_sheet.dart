import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/raphcon_type.dart';
import '../../features/raphcon_management/domain/entities/raphcon_entity.dart';

/// Detailed bottom sheet that shows individual raphcon entries for a specific type
/// Allows admins to delete individual raphcons
class RaphconDetailBottomSheet extends StatelessWidget {
  final String userName;
  final RaphconType type;
  final List<RaphconEntity> raphcons;
  final bool isAdmin;
  final VoidCallback onBackPressed;

  const RaphconDetailBottomSheet({
    super.key,
    required this.userName,
    required this.type,
    required this.raphcons,
    required this.isAdmin,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with back button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBackPressed,
                  icon: const Icon(Icons.arrow_back),
                  color: AppConstants.primaryColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        type.getDisplayName(localizations),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.problemStatisticsFor(userName),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Raphcons list
          Flexible(
            child: _buildRaphconsList(context, localizations),
          ),

          // Footer with count
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.totalCount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${raphcons.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaphconsList(
      BuildContext context, AppLocalizations localizations) {
    if (raphcons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              _getIconForType(type),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Einträge für diesen Typ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by creation date (newest first)
    final sortedRaphcons = List<RaphconEntity>.from(raphcons)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedRaphcons.length,
      itemBuilder: (context, index) {
        final raphcon = sortedRaphcons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(type),
                color: AppConstants.primaryColor,
                size: 24,
              ),
            ),
            title: Text(
              raphcon.comment ?? 'Kein Kommentar',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(raphcon.createdAt, context),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (raphcon.createdBy.isNotEmpty)
                  Text(
                    'Erstellt von: ${raphcon.createdBy}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
            trailing: isAdmin
                ? IconButton(
                    onPressed: () => _confirmDelete(context, raphcon),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  IconData _getIconForType(RaphconType type) {
    switch (type) {
      case RaphconType.mouse:
        return Icons.mouse;
      case RaphconType.keyboard:
        return Icons.keyboard;
      case RaphconType.microphone:
        return Icons.mic;
      case RaphconType.headset:
        return Icons.headset;
      case RaphconType.webcam:
        return Icons.videocam;
      case RaphconType.speakers:
        return Icons.volume_up;
      case RaphconType.network:
        return Icons.wifi_off;
      case RaphconType.software:
        return Icons.computer;
      case RaphconType.hardware:
        return Icons.hardware;
      case RaphconType.other:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return difference.inDays == 1
          ? localizations.daysAgoSingular(difference.inDays)
          : localizations.daysAgoPlural(difference.inDays);
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? localizations.hoursAgoSingular(difference.inHours)
          : localizations.hoursAgoPlural(difference.inHours);
    } else {
      return localizations.justCreated;
    }
  }

  void _confirmDelete(BuildContext context, RaphconEntity raphcon) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.confirmDeleteRaphcon),
          content: Text(localizations.confirmDeleteRaphconMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Add delete event when it exists
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.delete),
            ),
          ],
        );
      },
    );
  }

  /// Static method to show the detail bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String userName,
    required RaphconType type,
    required List<RaphconEntity> raphcons,
    required bool isAdmin,
    required VoidCallback onBackPressed,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => RaphconDetailBottomSheet(
          userName: userName,
          type: type,
          raphcons: raphcons,
          isAdmin: isAdmin,
          onBackPressed: onBackPressed,
        ),
      ),
    );
  }
}
