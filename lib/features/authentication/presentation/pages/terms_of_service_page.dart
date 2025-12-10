import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.termsOfService),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.termsOfServiceTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.lastUpdated(
                  '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              AppLocalizations.of(context)!.termsSection1Title,
              AppLocalizations.of(context)!.termsSection1Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.termsSection2Title,
              AppLocalizations.of(context)!.termsSection2Content,
            ),
            _buildSection(
              context,
              '3. Benutzerkonten und Zugang',
              'Der Zugang zur App erfolgt über Google-Authentifizierung. Sie sind verantwortlich für:\n\n• Die Geheimhaltung Ihrer Anmeldedaten\n• Alle Aktivitäten unter Ihrem Konto\n• Die Benachrichtigung bei unbefugter Nutzung',
            ),
            _buildSection(
              context,
              '4. Angemessene Nutzung',
              'Sie verpflichten sich zur angemessenen Nutzung der App:\n\n• Keine Beleidigungen oder Diskriminierung\n• Respektvoller Umgang mit anderen Benutzern\n• Keine missbräuchliche Nutzung der Bewertungsfunktion\n• Wahrung der Privatsphäre anderer Personen',
            ),
            _buildSection(
              context,
              '5. Datenschutz',
              'Ihre Privatsphäre ist uns wichtig. Details zur Datenerhebung und -verarbeitung finden Sie in unserer Datenschutzerklärung, die integraler Bestandteil dieser Nutzungsbedingungen ist.',
            ),
            _buildSection(
              context,
              '6. Geistiges Eigentum',
              'Alle Inhalte der App, einschließlich Design, Code und Grafiken, sind urheberrechtlich geschützt. Die Nutzung ist nur im Rahmen der bestimmungsgemäßen Verwendung der App gestattet.',
            ),
            _buildSection(
              context,
              '7. Haftungsausschluss',
              'Die App wird "wie besehen" bereitgestellt. Wir übernehmen keine Gewähr für:\n\n• Kontinuierliche Verfügbarkeit\n• Fehlerfreiheit der Software\n• Eignung für bestimmte Zwecke\n• Schäden durch die Nutzung der App',
            ),
            _buildSection(
              context,
              '8. Änderungen der Bedingungen',
              'Wir behalten uns das Recht vor, diese Nutzungsbedingungen jederzeit zu ändern. Änderungen werden in der App bekannt gegeben und treten mit der Fortsetzung der Nutzung in Kraft.',
            ),
            _buildSection(
              context,
              '9. Kündigung',
              'Sie können Ihr Konto jederzeit löschen. Wir behalten uns vor, Konten bei Verstößen gegen diese Bedingungen zu sperren oder zu löschen.',
            ),
            _buildSection(
              context,
              '10. Anwendbares Recht',
              'Diese Nutzungsbedingungen unterliegen dem Recht der Bundesrepublik Deutschland. Gerichtsstand ist [Ihr Standort].',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppConstants.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.contactTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!
                        .termsContactContent(AppConstants.appVersion),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
