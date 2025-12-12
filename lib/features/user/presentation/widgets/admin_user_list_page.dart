import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart' as user_entity;
import '../../../admin/presentation/bloc/admin_bloc.dart';
import '../../../raphcon_management/presentation/bloc/raphcon_bloc.dart';
import '../bloc/user_bloc.dart';
import 'initials_add_user_dialog.dart';
import '../../../../shared/widgets/raphcon_type_selection_dialog.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  void _checkAdminStatus() {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<AdminBloc>().add(CheckAdminStatusEvent(currentUser.email ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserBloc>().add(RefreshUsersEvent());
            },
          ),
          if (_isAdmin)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add_user') {
                  _showAddUserDialog(context);
                } else if (value == 'settings') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.settingsComingSoon)),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'add_user',
                  child: Row(
                    children: [
                      const Icon(Icons.person_add),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.addUser),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.settings),
                    ],
                  ),
                ),
              ],
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
          BlocListener<RaphconBloc, RaphconState>(
            listener: (context, state) {
              if (state is RaphconAdded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                // No need to manually refresh - stream will auto-update
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
                child: Text(AppLocalizations.of(context)!.noDataAvailable),
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
              AppLocalizations.of(context)!.noUsersFound,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return AdminUserCard(
          user: users[index],
          isAdmin: _isAdmin,
          onNameTapped: _isAdmin ? () => _createRaphcon(users[index]) : null,
        );
      },
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
            '${AppLocalizations.of(context)!.error}: $message',
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
            child: Text(AppLocalizations.of(context)!.tryAgain),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InitialsAddUserDialog(
          onUserAdded: (initials) {
            context.read<UserBloc>().add(AddUserEvent(
                  initials: initials,
                ));
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _createRaphcon(user_entity.User user) {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mustBeLoggedIn)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RaphconTypeSelectionDialog(
          onTypesSelected: (types, comment) {
            // Erstelle für jeden ausgewählten Typ einen Raphcon
            for (final type in types) {
              context.read<RaphconBloc>().add(AddRaphconEvent(
                    userId: user.id,
                    createdBy: currentUser.uid,
                    comment: comment ?? 'Raphcon für ${user.name}',
                    type: type,
                  ));
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class AdminUserCard extends StatelessWidget {
  final user_entity.User user;
  final bool isAdmin;
  final VoidCallback? onNameTapped;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.isAdmin,
    this.onNameTapped,
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
                    onTap: onNameTapped,
                    child: Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isAdmin ? AppConstants.primaryColor : Colors.black,
                        decoration: isAdmin ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Raphcons: ${user.raphconCount}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (user.lastRaphconAt != null)
                    Text(
                      'Letzter Raphcon: ${_formatDate(user.lastRaphconAt!)}',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDeleteUser),
          content: Text(AppLocalizations.of(context)!.confirmDeleteUserMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<UserBloc>().add(DeleteUserEvent(user.id));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return difference.inDays == 1
          ? 'vor ${difference.inDays} Tag'
          : 'vor ${difference.inDays} Tagen';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? 'vor ${difference.inHours} Stunde'
          : 'vor ${difference.inHours} Stunden';
    } else {
      return 'gerade eben';
    }
  }
}
