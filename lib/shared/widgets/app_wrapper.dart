import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_state.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/user/presentation/widgets/public_user_list_page.dart';

class AppWrapper extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final Function(ThemeMode) onThemeChanged;
  final Locale currentLocale;
  final ThemeMode currentTheme;

  const AppWrapper({
    super.key,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    required this.currentLocale,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const SplashPage();
        } else {
          // Always show the public user list - login is handled within
          return PublicUserListPage(
            onLanguageChanged: onLanguageChanged,
            onThemeChanged: onThemeChanged,
            currentLocale: currentLocale,
            currentTheme: currentTheme,
          );
        }
      },
    );
  }
}
