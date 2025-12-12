import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';

class LanguageSelectorDialog extends StatefulWidget {
  final Function(Locale) onLanguageSelected;
  final Locale currentLocale;

  const LanguageSelectorDialog({
    super.key,
    required this.onLanguageSelected,
    required this.currentLocale,
  });

  @override
  State<LanguageSelectorDialog> createState() => _LanguageSelectorDialogState();
}

class _LanguageSelectorDialogState extends State<LanguageSelectorDialog> {
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.selectYourLanguage ?? 'Select Your Language',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.welcomeSelectLanguage ??
                  'Welcome! Please select your preferred language:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildLanguageOption('English', const Locale('en')),
            const Divider(),
            _buildLanguageOption('Deutsch', const Locale('de')),
            const Divider(),
            _buildLanguageOption('Schwiizerdütsch', const Locale('gsw')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                widget.onLanguageSelected(_selectedLocale);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n?.continuee ?? l10n?.ok ?? 'Continue',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, Locale locale) {
    final isSelected = _selectedLocale.languageCode == locale.languageCode;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocale = locale;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Radio<Locale>(
              value: locale,
              groupValue: _selectedLocale,
              onChanged: (Locale? value) {
                if (value != null) {
                  setState(() {
                    _selectedLocale = value;
                  });
                }
              },
              activeColor: AppConstants.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
