import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacyPolicy),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.privacyPolicyTitle,
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
              AppLocalizations.of(context)!.privacySection1Title,
              AppLocalizations.of(context)!.privacySection1Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection2Title,
              AppLocalizations.of(context)!.privacySection2Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection3Title,
              AppLocalizations.of(context)!.privacySection3Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection4Title,
              AppLocalizations.of(context)!.privacySection4Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection5Title,
              AppLocalizations.of(context)!.privacySection5Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection6Title,
              AppLocalizations.of(context)!.privacySection6Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection7Title,
              AppLocalizations.of(context)!.privacySection7Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection8Title,
              AppLocalizations.of(context)!.privacySection8Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection9Title,
              AppLocalizations.of(context)!.privacySection9Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection10Title,
              AppLocalizations.of(context)!.privacySection10Content,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.privacySection11Title,
              AppLocalizations.of(context)!.privacySection11Content,
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
                  Row(
                    children: [
                      const Icon(
                        Icons.security,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.privacyContactTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.privacyContactContent,
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
