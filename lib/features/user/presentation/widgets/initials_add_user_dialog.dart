import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';

/// Dialog for adding a new user with initials input
/// Follows KISS principle with simple two-field input for initials
/// Implements Clean Code principles with single responsibility
class InitialsAddUserDialog extends StatefulWidget {
  final Function(String initials) onUserAdded;

  const InitialsAddUserDialog({
    super.key,
    required this.onUserAdded,
  });

  @override
  State<InitialsAddUserDialog> createState() => _InitialsAddUserDialogState();
}

class _InitialsAddUserDialogState extends State<InitialsAddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstInitialController = TextEditingController();
  final _secondInitialController = TextEditingController();
  final _firstInitialFocus = FocusNode();
  final _secondInitialFocus = FocusNode();

  @override
  void dispose() {
    _firstInitialController.dispose();
    _secondInitialController.dispose();
    _firstInitialFocus.dispose();
    _secondInitialFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addPersonWithInitials),
      content: SizedBox(
        width: 350,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.initialsFormat,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // First Initial Field
                  Expanded(
                    child: TextFormField(
                      controller: _firstInitialController,
                      focusNode: _firstInitialFocus,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.firstInitial,
                        border: const OutlineInputBorder(),
                        counterText: '', // Hide character counter
                      ),
                      maxLength: 1,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                        UpperCaseTextFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterFirstInitial;
                        }
                        if (!RegExp(r'^[A-Z]$').hasMatch(value.trim())) {
                          return AppLocalizations.of(context)!
                              .initialMustBeLetter;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        _secondInitialFocus.requestFocus();
                      },
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Dot separator
                  Text(
                    '.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 16),
                  // Second Initial Field
                  Expanded(
                    child: TextFormField(
                      controller: _secondInitialController,
                      focusNode: _secondInitialFocus,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.secondInitial,
                        border: const OutlineInputBorder(),
                        counterText: '', // Hide character counter
                      ),
                      maxLength: 1,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                        UpperCaseTextFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterSecondInitial;
                        }
                        if (!RegExp(r'^[A-Z]$').hasMatch(value.trim())) {
                          return AppLocalizations.of(context)!
                              .initialMustBeLetter;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        _submitForm();
                      },
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.enterTwoInitials,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final firstInitial = _firstInitialController.text.trim();
      final secondInitial = _secondInitialController.text.trim();
      final initials = '$firstInitial.$secondInitial.';

      widget.onUserAdded(initials);
    }
  }
}

/// Custom input formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
