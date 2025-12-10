import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_constants.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppConstants.textColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              message,
              style: const TextStyle(
                color: AppConstants.subtitleColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.largePadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.largePadding,
                    vertical: AppConstants.smallPadding,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
