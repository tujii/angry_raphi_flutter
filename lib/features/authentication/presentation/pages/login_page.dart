import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  final bool isDialog;

  const LoginPage({super.key, this.isDialog = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: isDialog
          ? AppBar(
              title: Text(AppLocalizations.of(context)!.login),
              backgroundColor: AppConstants.backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.loginFailed,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(state.message),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${AppLocalizations.of(context)!.loginSuccess}: ${state.user.displayName}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo and Animation
                  _buildLogo(),
                  const SizedBox(height: 48),

                  // App Title
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // App Description
                  Text(
                    AppLocalizations.of(context)!.ratePersonsWithRaphcons,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Google Sign In Button
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else
                    _buildGoogleSignInButton(context),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  _buildTermsAndPrivacy(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(60),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.asset(
          'assets/images/icon-removebg.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.mood_bad,
              size: 60,
              color: AppConstants.primaryColor,
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(AuthSignInRequested());
        },
        icon: Image.asset(
          'assets/images/google_logo.png',
          height: 24,
          width: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.login,
              color: Colors.white,
            );
          },
        ),
        label: Text(
          AppLocalizations.of(context)!.signInWithGoogle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.bySigningInYouAgree,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Navigate to Terms
              },
              child: Text(
                AppLocalizations.of(context)!.termsOfService,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
            Text(
              ' ${AppLocalizations.of(context)!.and} ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to Privacy Policy
              },
              child: Text(
                AppLocalizations.of(context)!.privacyPolicy,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ],
        ),
        Text(
          AppLocalizations.of(context)!.agreeTo,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
