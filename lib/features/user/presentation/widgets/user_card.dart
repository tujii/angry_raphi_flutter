import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final int rank;

  const UserCard({
    super.key,
    required this.user,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      elevation: AppConstants.cardElevation,
      child: ListTile(
        leading: _buildRankAndAvatar(),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
        subtitle: Text(
          'Mitglied seit ${_formatDate(user.createdAt)}',
          style: const TextStyle(
            color: AppConstants.subtitleColor,
            fontSize: 12,
          ),
        ),
        trailing: _buildRaphconBadge(),
        onTap: () {
          // TODO: Navigation zu User Details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.name} Details - Coming Soon!'),
              backgroundColor: AppConstants.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankAndAvatar() {
    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rank Badge
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getRankColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaphconBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sentiment_very_dissatisfied,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${user.raphconCount}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.orange[800]!; // Bronze
      default:
        return AppConstants.subtitleColor;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months Monat${months > 1 ? 'en' : ''}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} Tag${difference.inDays > 1 ? 'en' : ''}';
    } else {
      return 'Heute';
    }
  }
}