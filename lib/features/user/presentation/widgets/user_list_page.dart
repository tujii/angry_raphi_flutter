import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../bloc/user_bloc.dart';
import 'user_card.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_user') {
                _showAddUserDialog(context);
              } else if (value == 'settings') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Einstellungen kommen bald!')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_user',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Benutzer hinzufügen'),
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
            ],
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is UserLoading) {
            return _buildLoadingState();
          } else if (state is UserError) {
            return _buildErrorState(context, state.message);
          } else if (state is UserLoaded) {
            return _buildUserList(state.users);
          }
          return _buildLoadingState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppConstants.primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'Lade Benutzer...',
            style: TextStyle(
              color: AppConstants.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<UserBloc>().add(RefreshUsersEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<User> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppConstants.subtitleColor,
            ),
            SizedBox(height: 16),
            Text(
              'Keine Benutzer gefunden',
              style: TextStyle(
                fontSize: 18,
                color: AppConstants.textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Füge den ersten Benutzer hinzu!',
              style: TextStyle(
                color: AppConstants.subtitleColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header mit Statistiken
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Benutzer', users.length.toString()),
              _buildStatCard(
                  'Total Raphcons', _getTotalRaphcons(users).toString()),
              _buildStatCard('Top Sammler', users.first.name),
            ],
          ),
        ),
        // User Liste
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final rank = _calculateRank(users, index);
              return UserCard(
                user: users[index],
                rank: rank,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.subtitleColor,
          ),
        ),
      ],
    );
  }

  int _getTotalRaphcons(List<User> users) {
    return users.fold(0, (sum, user) => sum + user.raphconCount);
  }

  /// Calculates the rank of a user at a given index, accounting for ties.
  /// Users with the same raphconCount get the same rank.
  /// Returns a 1-based rank (1 = Gold, 2 = Silver, 3 = Bronze).
  int _calculateRank(List<User> users, int index) {
    if (index == 0) return 1;
    
    int rank = 1;
    for (int i = 0; i < index; i++) {
      // Only increment rank when raphconCount changes
      if (users[i].raphconCount != users[i + 1].raphconCount) {
        rank = i + 2; // +2 because rank is 1-based and we're at i+1 position
      }
    }
    return rank;
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Benutzer verwalten'),
        content: const Text(
          'Möchten Sie Beispiel-Benutzer zur Datenbank hinzufügen oder einen neuen Benutzer erstellen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Sample data functionality removed
            },
            child: const Text('Beispiel-Daten'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Benutzer erstellen kommt bald!')),
              );
            },
            child: const Text('Neuer Benutzer'),
          ),
        ],
      ),
    );
  }
}
