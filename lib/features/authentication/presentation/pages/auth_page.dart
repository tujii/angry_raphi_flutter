import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/google_sign_in_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.sentiment_very_dissatisfied,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // App Name
                  Text(
                    'AngryRaphi',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),

                  // Subtitle
                  Text(
                    'Rate people with raphcons!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppConstants.subtitleColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largePadding * 2),

                  // Loading or Sign In Button
                  if (state is AuthLoading)
                    const CircularProgressIndicator(
                      color: AppConstants.primaryColor,
                    )
                  else
                    GoogleSignInButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthSignInRequested());
                      },
                    ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Terms and Privacy
                  Text(
                    'By signing in, you agree to our Terms of Service and Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.subtitleColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
