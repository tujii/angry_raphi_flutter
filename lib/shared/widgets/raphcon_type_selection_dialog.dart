import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/raphcon_type.dart';

/// Dialog for selecting the type(s) of problem when creating Raphcons
/// Supports multiple type selection to create multiple Raphcons at once
/// Follows Clean Code and KISS principles with clear problem categorization
class RaphconTypeSelectionDialog extends StatefulWidget {
  final Function(Set<RaphconType> selectedTypes, String? comment)
      onTypesSelected;

  const RaphconTypeSelectionDialog({
    super.key,
    required this.onTypesSelected,
  });

  @override
  State<RaphconTypeSelectionDialog> createState() =>
      _RaphconTypeSelectionDialogState();
}

class _RaphconTypeSelectionDialogState
    extends State<RaphconTypeSelectionDialog> {
  final Set<RaphconType> _selectedTypes = {};
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
      content: ConstrainedBox(
        constraints: BoxConstraints(
          // Keep dialog usable on small screens by limiting height
          maxWidth: 450,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localizations.whatKindOfProblem}\n(Mehrfachauswahl möglich)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              if (_selectedTypes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${_selectedTypes.length} Typ(en) ausgewählt',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),

              // Problem Type Selection Grid
              _buildProblemTypeGrid(localizations),

              const SizedBox(height: 24),

              // Optional comment field
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: localizations.descriptionOptional,
                  border: const OutlineInputBorder(),
                  hintText: localizations.commentExample,
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
          onPressed: _selectedTypes.isNotEmpty ? _submitSelection : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(_selectedTypes.length > 1
              ? '${_selectedTypes.length} Raphcons erstellen'
              : localizations.add),
        ),
      ],
    );
  }

  Widget _buildProblemTypeGrid(AppLocalizations localizations) {
    final width = MediaQuery.of(context).size.width;
    final crossAxis = width < 380 ? 1 : 2;
    final aspect = width < 380 ? 2.0 : 2.5;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspect,
      ),
      itemCount: RaphconType.values.length,
      itemBuilder: (context, index) {
        final type = RaphconType.values[index];
        final isSelected = _selectedTypes.contains(type);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTypes.remove(type);
              } else {
                _selectedTypes.add(type);
              }
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
      case RaphconType.headset:
        return Icons.headset;
      case RaphconType.webcam:
        return Icons.videocam;
      case RaphconType.otherPeripherals:
        return Icons.devices;
      case RaphconType.mouseHighlighter:
        return Icons.highlight_alt;
      case RaphconType.lateMeeting:
        return Icons.schedule;
    }
  }

  void _submitSelection() {
    if (_selectedTypes.isNotEmpty) {
      final comment = _commentController.text.trim();
      widget.onTypesSelected(
        _selectedTypes,
        comment.isNotEmpty ? comment : null,
      );
    }
  }
}
