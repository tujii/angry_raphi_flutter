import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/ranking_utils.dart';
import '../../core/utils/responsive_helper.dart';
import '../../features/user/domain/entities/user.dart';

class UserRankingSearchDelegate extends SearchDelegate<String> {
  final List<User> users;
  final AppLocalizations localizations;

  UserRankingSearchDelegate(this.users, this.localizations);

  @override
  String get searchFieldLabel => localizations.searchUsers;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      IconButton(
        icon: const Icon(Icons.leaderboard),
        onPressed: () => _showRankingDialog(context),
        tooltip: localizations.showRanking,
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRankingList(context, showAll: false);
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredUsers = users.where((user) {
      return user.initials.toLowerCase().contains(query.toLowerCase()) ||
          user.raphconCount.toString().contains(query);
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noResultsFor(query),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return _buildUserList(context, filteredUsers);
  }

  Widget _buildRankingList(BuildContext context, {bool showAll = true}) {
    final topUsers = showAll ? users : users.take(5).toList();

    if (topUsers.isEmpty) {
      return Center(
        child: Text(localizations.noUsersAvailable),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
          child: Text(
            showAll ? localizations.fullRanking : localizations.topRanking,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: _buildUserList(context, topUsers, showRanking: true),
        ),
        if (!showAll && users.length > 5)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () => _showRankingDialog(context),
              child: Text(
                localizations.showFullRanking(users.length),
                style: const TextStyle(color: AppConstants.primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserList(BuildContext context, List<User> userList,
      {bool showRanking = false}) {
    return ResponsiveHelper.isMobile(context)
        ? _buildMobileList(context, userList, showRanking: showRanking)
        : _buildWebGrid(context, userList, showRanking: showRanking);
  }

  Widget _buildMobileList(BuildContext context, List<User> userList,
      {bool showRanking = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: userList.length,
      itemBuilder: (context, index) {
        final rank = RankingUtils.calculateRank(userList, index);
        return _buildUserCard(context, userList[index], index, rank,
            showRanking: showRanking);
      },
    );
  }

  Widget _buildWebGrid(BuildContext context, List<User> userList,
      {bool showRanking = false}) {
    final crossAxisCount = ResponsiveHelper.getGridColumns(context);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.8,
      ),
      itemCount: userList.length,
      itemBuilder: (context, index) {
        final rank = RankingUtils.calculateRank(userList, index);
        return _buildUserCard(context, userList[index], index, rank,
            showRanking: showRanking);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, User user, int index, int rank,
      {bool showRanking = false}) {
    final shouldShowBadge = _shouldShowBadge(users, index);
    final badgePosition = _getBadgePosition(users, index);
    final rankIcon =
        shouldShowBadge ? _getBadgeIcon(badgePosition) : _getRankIcon(rank);
    final rankColor =
        shouldShowBadge ? _getBadgeColor(badgePosition) : _getRankColor(rank);

    return Card(
      elevation: showRanking && rank <= 3 ? 8 : 4,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => close(context, user.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: showRanking && shouldShowBadge
                ? LinearGradient(
                    colors: [
                      rankColor.withValues(alpha: 0.1),
                      rankColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                if (showRanking) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: rankColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: shouldShowBadge
                          ? [
                              BoxShadow(
                                color: rankColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: shouldShowBadge
                          ? Icon(rankIcon, color: Colors.white, size: 20)
                          : Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                CircleAvatar(
                  backgroundColor: AppConstants.primaryColor,
                  radius: 20,
                  child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            user.avatarUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Icon(
                            Icons.mood_bad,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${user.raphconCount} Raphcons',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showRanking && shouldShowBadge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: rankColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shouldShowBadge
                          ? _getBadgeText(badgePosition)
                          : _getRankText(rank),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.workspace_premium; // Silver medal
      case 3:
        return Icons.military_tech; // Bronze medal
      default:
        return Icons.person;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppConstants.primaryColor;
    }
  }

  String _getRankText(int rank) {
    switch (rank) {
      case 1:
        return localizations.gold;
      case 2:
        return localizations.silver;
      case 3:
        return localizations.bronze;
      default:
        return '';
    }
  }

  bool _shouldShowBadge(List<User> userList, int index) {
    if (index >= userList.length) return false;

    // Get unique raphcon counts in descending order
    final uniqueCounts = userList
        .map((user) => user.raphconCount)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Show badge if user has one of the top 3 unique scores
    final userCount = userList[index].raphconCount;
    return uniqueCounts.length >= 3
        ? uniqueCounts.take(3).contains(userCount)
        : uniqueCounts.contains(userCount);
  }

  int _getBadgePosition(List<User> userList, int index) {
    if (index >= userList.length) return 0;

    final uniqueCounts = userList
        .map((user) => user.raphconCount)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final userCount = userList[index].raphconCount;
    return uniqueCounts.indexOf(userCount) + 1; // 1-based position
  }

  IconData _getBadgeIcon(int badgePosition) {
    switch (badgePosition) {
      case 1:
        return Icons.emoji_events; // Trophy for Gold
      case 2:
        return Icons.workspace_premium; // Medal for Silver
      case 3:
        return Icons.military_tech; // Medal for Bronze
      default:
        return Icons.person;
    }
  }

  Color _getBadgeColor(int badgePosition) {
    switch (badgePosition) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppConstants.primaryColor;
    }
  }

  String _getBadgeText(int badgePosition) {
    switch (badgePosition) {
      case 1:
        return localizations.gold;
      case 2:
        return localizations.silver;
      case 3:
        return localizations.bronze;
      default:
        return '';
    }
  }

  void _showRankingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: ResponsiveHelper.isMobile(context)
              ? MediaQuery.of(context).size.width * 0.9
              : 800,
          height: ResponsiveHelper.isMobile(context)
              ? MediaQuery.of(context).size.height * 0.8
              : 600,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.leaderboard, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.fullRanking,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildUserList(context, users, showRanking: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
