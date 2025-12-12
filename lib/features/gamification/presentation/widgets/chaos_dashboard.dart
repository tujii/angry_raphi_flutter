import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chaos_user_entity.dart';
import '../../domain/entities/story_entity.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';
import '../../../../core/enums/raphcon_type.dart';
import 'notification_service.dart';

/// Dashboard widget showing chaos points, rank, and latest story
class ChaosDashboard extends StatefulWidget {
  final String userId;
  final String userName;

  const ChaosDashboard({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChaosDashboard> createState() => _ChaosDashboardState();
}

class _ChaosDashboardState extends State<ChaosDashboard> {
  @override
  void initState() {
    super.initState();
    // Start streaming data
    context.read<GamificationBloc>()
      ..add(StreamUserChaosPointsEvent(userId: widget.userId))
      ..add(StreamLatestStoryEvent(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GamificationBloc, GamificationState>(
      listener: (context, state) {
        if (state is HardwareFailAdded) {
          NotificationService.showSuccess(state.message);
        } else if (state is StoryGenerated) {
          NotificationService.showStory(state.story.text);
        } else if (state is GamificationError) {
          NotificationService.showError(state.message);
        }
      },
      builder: (context, state) {
        if (state is GamificationDashboardState) {
          return _buildDashboard(
            context,
            state.user,
            state.latestStory,
          );
        } else if (state is GamificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    ChaosUserEntity user,
    StoryEntity? story,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Raphcon Chaos Meter',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  Icons.bolt,
                  color: _getRankColor(user.totalChaosPoints),
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chaos Points
            _buildChaosPoints(context, user),
            const SizedBox(height: 16),

            // Rank
            _buildRank(context, user),
            const SizedBox(height: 16),

            // Latest Story
            if (story != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              _buildLatestStory(context, story),
              const SizedBox(height: 16),
            ],

            // Quick Actions
            const Divider(),
            const SizedBox(height: 16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChaosPoints(BuildContext context, ChaosUserEntity user) {
    return Row(
      children: [
        Icon(Icons.trending_up, color: Colors.orange),
        const SizedBox(width: 8),
        Text(
          'Chaos Points: ',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          '${user.totalChaosPoints}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getRankColor(user.totalChaosPoints),
              ),
        ),
      ],
    );
  }

  Widget _buildRank(BuildContext context, ChaosUserEntity user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getRankColor(user.totalChaosPoints).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: _getRankColor(user.totalChaosPoints),
          ),
          const SizedBox(width: 8),
          Text(
            user.rank,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(user.totalChaosPoints),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestStory(BuildContext context, StoryEntity story) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_stories, color: Colors.purple),
            const SizedBox(width: 8),
            Text(
              'Latest Chaos Story',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            story.text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTimestamp(story.timestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Hardware Fail',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildHardwareButton(context, RaphconType.webcam, 'Webcam'),
            _buildHardwareButton(context, RaphconType.headset, 'Headset'),
            _buildHardwareButton(context, RaphconType.mouse, 'Mouse'),
            _buildHardwareButton(context, RaphconType.keyboard, 'Keyboard'),
          ],
        ),
      ],
    );
  }

  Widget _buildHardwareButton(
    BuildContext context,
    RaphconType type,
    String label,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<GamificationBloc>().add(
              AddHardwareFailEvent(
                userId: widget.userId,
                type: type,
              ),
            );
        NotificationService.showHardwareFail(label, widget.userName);
      },
      icon: Icon(_getHardwareIcon(type)),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
    );
  }

  IconData _getHardwareIcon(RaphconType type) {
    switch (type) {
      case RaphconType.webcam:
        return Icons.videocam;
      case RaphconType.headset:
        return Icons.headset;
      case RaphconType.mouse:
        return Icons.mouse;
      case RaphconType.keyboard:
        return Icons.keyboard;
      default:
        return Icons.hardware;
    }
  }

  Color _getRankColor(int points) {
    if (points >= 100) return Colors.red;
    if (points >= 50) return Colors.deepOrange;
    if (points >= 20) return Colors.orange;
    if (points >= 10) return Colors.amber;
    return Colors.blue;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
  }
}
