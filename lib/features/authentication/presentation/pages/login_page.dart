import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  final bool isDialog;

  const LoginPage({super.key, this.isDialog = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _verificationId;
  String? _phoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: widget.isDialog
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
          } else if (state is AuthPhoneCodeSent) {
            setState(() {
              _verificationId = state.verificationId;
              _phoneNumber = state.phoneNumber;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.verificationCodeSent),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
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

                  // Sign In Options
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else if (_verificationId != null)
                    _buildVerificationCodeInput(context)
                  else ...[
                    _buildPhoneSignInForm(context),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.orSignInWith,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildGoogleSignInButton(context),
                  ],

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

  Widget _buildPhoneSignInForm(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.phoneNumber,
            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppConstants.primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              final phoneNumber = _phoneController.text.trim();
              if (phoneNumber.isNotEmpty) {
                context
                    .read<AuthBloc>()
                    .add(AuthPhoneSignInRequested(phoneNumber));
              }
            },
            icon: const Icon(Icons.send, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.sendCode,
              style: const TextStyle(
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
        ),
      ],
    );
  }

  Widget _buildVerificationCodeInput(BuildContext context) {
    return Column(
      children: [
        Text(
          '${AppLocalizations.of(context)!.verificationCodeSent}\n$_phoneNumber',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.verificationCode,
            hintText: AppLocalizations.of(context)!.enterVerificationCode,
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppConstants.primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              final code = _codeController.text.trim();
              if (code.isNotEmpty && _verificationId != null) {
                context.read<AuthBloc>().add(AuthVerifyPhoneCode(
                      verificationId: _verificationId!,
                      smsCode: code,
                    ));
              }
            },
            icon: const Icon(Icons.verified, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.verifyCode,
              style: const TextStyle(
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
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _verificationId = null;
              _phoneNumber = null;
              _codeController.clear();
            });
          },
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: const TextStyle(color: AppConstants.primaryColor),
          ),
        ),
      ],
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
                if (widget.isDialog) {
                  // Close dialog first, then navigate
                  Navigator.of(context).pop();
                  context.go(AppRouter.terms);
                } else {
                  context.push(AppRouter.terms);
                }
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
                if (widget.isDialog) {
                  // Close dialog first, then navigate
                  Navigator.of(context).pop();
                  context.go(AppRouter.privacy);
                } else {
                  context.push(AppRouter.privacy);
                }
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

