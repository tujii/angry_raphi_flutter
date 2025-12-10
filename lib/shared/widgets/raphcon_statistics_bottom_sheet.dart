import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/raphcon_type.dart';

/// Scrollable bottom sheet that displays raphcon statistics by type
/// Shown to non-authenticated users when they tap on a user tile
class RaphconStatisticsBottomSheet extends StatelessWidget {
  final String userName;
  final Map<RaphconType, int> statistics;
  final bool isAdmin;
  final Function(RaphconType)? onTypeSelected;

  const RaphconStatisticsBottomSheet({
    super.key,
    required this.userName,
    required this.statistics,
    this.isAdmin = false,
    this.onTypeSelected,
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

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  localizations.problemStatisticsFor(userName),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.sortedByType,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.subtitleColor,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Statistics list
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Flexible(
              child: _buildStatisticsList(context, localizations),
            ),
          ),

          // Footer with total
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
                  '${_getTotalCount()} ${localizations.problems}',
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

  Widget _buildStatisticsList(
      BuildContext context, AppLocalizations localizations) {
    if (statistics.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              localizations.noProblemsReported,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              localizations.noTechnicalProblemsYet,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Sort by count (descending)
    final sortedEntries = statistics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final type = entry.key;
        final count = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            onTap: () => onTypeSelected?.call(type),
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
              type.getDisplayName(localizations),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorForCount(count),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
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

  Color _getColorForCount(int count) {
    if (count >= 10) return Colors.red;
    if (count >= 5) return Colors.orange;
    if (count >= 2) return Colors.blue;
    return Colors.green;
  }

  int _getTotalCount() {
    return statistics.values.fold(0, (sum, count) => sum + count);
  }

  /// Static method to show the bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String userName,
    required Map<RaphconType, int> statistics,
    bool isAdmin = false,
    Function(RaphconType)? onTypeSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: GestureDetector(
                onTap: () {}, // Verhindert dass Taps auf dem Sheet das Sheet schließen
                child: RaphconStatisticsBottomSheet(
                  userName: userName,
                  statistics: statistics,
                  isAdmin: isAdmin,
                  onTypeSelected: onTypeSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
