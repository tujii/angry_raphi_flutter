import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

/// Builds [builder] with the signed-in user; shows a spinner while the auth
/// state is resolved and a sign-in prompt otherwise.
class SignedInBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, UserEntity user) builder;

  const SignedInBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is! AuthAuthenticated ||
          previous is! AuthAuthenticated ||
          previous.user.id != current.user.id,
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return builder(context, state.user);
        }
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          body: Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: Text(l10n?.signIn ?? 'Anmelden'),
              onPressed: () {
                final here = GoRouterState.of(context).uri.toString();
                context.go(Uri(
                  path: AppRouter.login,
                  queryParameters: {AppRouter.fromParam: here},
                ).toString());
              },
            ),
          ),
        );
      },
    );
  }
}
