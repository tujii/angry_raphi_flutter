import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart' as user_entity;
import '../../../admin/presentation/bloc/admin_bloc.dart';
import '../../../raphcon_management/presentation/bloc/raphcon_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/presentation/pages/login_page.dart';
import '../bloc/user_bloc.dart';
import 'add_user_dialog.dart';

class PublicUserListPage extends StatefulWidget {
  const PublicUserListPage({super.key});

  @override
  State<PublicUserListPage> createState() => _PublicUserListPageState();
}

class _PublicUserListPageState extends State<PublicUserListPage> {
  bool _isAdmin = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndAdminStatus();
  }

  void _checkAuthAndAdminStatus() {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _isLoggedIn = true;
      });
      context.read<AdminBloc>().add(CheckAdminStatusEvent(currentUser.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(AppConstants.appName),
            if (_isAdmin)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserBloc>().add(RefreshUsersEvent());
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated && _isAdmin) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'add_user') {
                      _showAddUserDialog(context);
                    } else if (value == 'logout') {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    } else if (value == 'settings') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)
                                    ?.settingsComingSoon2 ??
                                'Einstellungen kommen bald')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'add_user',
                      child: Row(
                        children: [
                          Icon(Icons.person_add),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)?.addUser ??
                              'Benutzer hinzufügen'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8),
                          Text('Einstellungen'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)?.signOut ??
                              'Abmelden'),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () => _showLoginDialog(context),
                );
              }
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AdminBloc, AdminState>(
            listener: (context, state) {
              if (state is AdminStatusChecked) {
                setState(() {
                  _isAdmin = state.isAdmin;
                });
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                setState(() {
                  _isLoggedIn = true;
                });
                // Check admin status after login
                context
                    .read<AdminBloc>()
                    .add(CheckAdminStatusEvent(state.user.id));
                Navigator.of(context).pop(); // Close login dialog
              } else if (state is AuthUnauthenticated) {
                setState(() {
                  _isLoggedIn = false;
                  _isAdmin = false;
                });
              }
            },
          ),
          BlocListener<RaphconBloc, RaphconState>(
            listener: (context, state) {
              if (state is RaphconAdded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                // Reload users to update raphcon count
                context.read<UserBloc>().add(RefreshUsersEvent());
              } else if (state is RaphconError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is UserLoaded) {
              return _buildUsersList(context, state.users);
            } else if (state is UserError) {
              return _buildErrorView(context, state.message);
            } else {
              return Center(
                child: Text(AppLocalizations.of(context)?.noDataAvailable ??
                    'Keine Daten verfügbar'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, List<user_entity.User> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noUsersFound ??
                  'Keine Benutzer gefunden',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Info banner for guests
        if (!_isLoggedIn)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppConstants.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Melden Sie sich als Admin an, um Benutzer zu verwalten und Raphcons zu erstellen.',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showLoginDialog(context),
                  child:
                      Text(AppLocalizations.of(context)?.login ?? 'Anmelden'),
                ),
              ],
            ),
          ),

        // User list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return PublicUserCard(
                user: users[index],
                isAdmin: _isAdmin,
                isLoggedIn: _isLoggedIn,
                onNameTapped:
                    _isAdmin ? () => _createRaphcon(users[index]) : null,
                onLoginRequired: () => _showLoginDialog(context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '${AppLocalizations.of(context)?.error ?? 'Fehler'}: $message',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<UserBloc>().add(RefreshUsersEvent());
            },
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<UserBloc>(),
          child: AddUserDialog(
            onUserAdded: (name, description) {
              context.read<UserBloc>().add(AddUserEvent(
                    name: name,
                    description: description,
                  ));
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      },
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
              child: const LoginPage(isDialog: true),
            ),
          ),
        );
      },
    );
  }

  void _createRaphcon(user_entity.User user) {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showLoginDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<RaphconBloc>()),
          ],
          child: AlertDialog(
            title: Text('Raphcon für ${user.name} erstellen'),
            content: Text(AppLocalizations.of(context)?.creatingRaphcon ??
                'Erstelle Raphcon...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Abbrechen'),
              ),
              BlocBuilder<RaphconBloc, RaphconState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is RaphconLoading
                        ? null
                        : () {
                            context.read<RaphconBloc>().add(AddRaphconEvent(
                                  userId: user.id,
                                  createdBy: currentUser.uid,
                                  comment: 'Raphcon für ${user.name}',
                                ));
                            Navigator.of(dialogContext).pop();
                          },
                    child: state is RaphconLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Erstellen'),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class PublicUserCard extends StatelessWidget {
  final user_entity.User user;
  final bool isAdmin;
  final bool isLoggedIn;
  final VoidCallback? onNameTapped;
  final VoidCallback? onLoginRequired;

  const PublicUserCard({
    super.key,
    required this.user,
    required this.isAdmin,
    required this.isLoggedIn,
    this.onNameTapped,
    this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppConstants.primaryColor,
              radius: 30,
              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.avatarUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isAdmin) {
                        onNameTapped?.call();
                      } else if (!isLoggedIn) {
                        // Show login hint for guests
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Melden Sie sich an, um Raphcons zu erstellen'),
                            action: SnackBarAction(
                              label: AppLocalizations.of(context)?.login ??
                                  'Anmelden',
                              onPressed: () => onLoginRequired?.call(),
                            ),
                          ),
                        );
                        onLoginRequired?.call();
                      } else {
                        // Show admin required hint for logged in non-admins
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AppLocalizations.of(context)?.adminRequired ??
                                    'Admin-Berechtigung erforderlich'),
                          ),
                        );
                      }
                    },
                    child: Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isAdmin
                            ? AppConstants.primaryColor
                            : Colors.black87,
                        decoration: isAdmin ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.mood_bad,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Raphcons: ${user.raphconCount}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Erstellt: ${_formatDate(user.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'vor ${difference.inDays} Tag${difference.inDays == 1 ? '' : 'en'}';
    } else if (difference.inHours > 0) {
      return 'vor ${difference.inHours} Stunde${difference.inHours == 1 ? '' : 'n'}';
    } else {
      return 'gerade eben';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<UserBloc>(),
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)?.confirmDeleteUser ??
                'Benutzer löschen bestätigen'),
            content: Text(AppLocalizations.of(context)
                    ?.confirmDeleteUserMessage ??
                'Sind Sie sicher, dass Sie diesen Benutzer löschen möchten?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Abbrechen'),
              ),
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is UserLoading
                        ? null
                        : () {
                            context
                                .read<UserBloc>()
                                .add(DeleteUserEvent(user.id));
                            Navigator.of(dialogContext).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: state is UserLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)?.delete ?? 'Löschen'),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
