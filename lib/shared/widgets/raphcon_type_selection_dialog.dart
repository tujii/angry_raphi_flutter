import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/raphcon_type.dart';

/// Dialog for selecting the type of problem when creating a Raphcon
/// Follows Clean Code and KISS principles with clear problem categorization
class RaphconTypeSelectionDialog extends StatefulWidget {
  final Function(RaphconType selectedType, String? comment) onTypeSelected;

  const RaphconTypeSelectionDialog({
    super.key,
    required this.onTypeSelected,
  });

  @override
  State<RaphconTypeSelectionDialog> createState() =>
      _RaphconTypeSelectionDialogState();
}

class _RaphconTypeSelectionDialogState
    extends State<RaphconTypeSelectionDialog> {
  RaphconType? _selectedType;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.selectProblemType),
      content: SizedBox(
        width: 450,
        height: 550,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.whatKindOfProblem,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),

              // Problem Type Selection Grid
              _buildProblemTypeGrid(localizations),

              const SizedBox(height: 24),

              // Optional comment field
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: '${localizations.descriptionOptional}',
                  border: const OutlineInputBorder(),
                  hintText: 'z.B. "Maus klickt nicht richtig"',
                ),
                maxLines: 2,
                maxLength: 200,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: _selectedType != null ? _submitSelection : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(localizations.add),
        ),
      ],
    );
  }

  Widget _buildProblemTypeGrid(AppLocalizations localizations) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: RaphconType.values.length,
      itemBuilder: (context, index) {
        final type = RaphconType.values[index];
        final isSelected = _selectedType == type;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedType = type;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? AppConstants.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForType(type),
                  size: 24,
                  color:
                      isSelected ? AppConstants.primaryColor : Colors.grey[600],
                ),
                const SizedBox(height: 4),
                Text(
                  type.getDisplayName(localizations),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? AppConstants.primaryColor
                            : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  void _submitSelection() {
    if (_selectedType != null) {
      final comment = _commentController.text.trim();
      widget.onTypeSelected(
        _selectedType!,
        comment.isNotEmpty ? comment : null,
      );
    }
  }
}
