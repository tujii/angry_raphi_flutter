import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/raphcon_type.dart';
import '../../features/raphcon_management/domain/entities/raphcon_entity.dart';
import '../../features/raphcon_management/presentation/bloc/raphcon_bloc.dart';
import '../../features/user/presentation/bloc/user_bloc.dart';

/// Detailed bottom sheet that shows individual raphcon entries for a specific type
/// Allows admins to delete individual raphcons
class RaphconDetailBottomSheet extends StatefulWidget {
  final String userName;
  final RaphconType type;
  final List<RaphconEntity> raphcons;
  final bool isAdmin;
  final VoidCallback onBackPressed;

  const RaphconDetailBottomSheet({
    super.key,
    required this.userName,
    required this.type,
    required this.raphcons,
    required this.isAdmin,
    required this.onBackPressed,
  });

  @override
  State<RaphconDetailBottomSheet> createState() =>
      _RaphconDetailBottomSheetState();

  /// Static method to show the detail bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String userName,
    required RaphconType type,
    required List<RaphconEntity> raphcons,
    required bool isAdmin,
    required VoidCallback onBackPressed,
  }) {
    final userBloc = context.read<UserBloc>();
    final raphconBloc = context.read<RaphconBloc>();
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<UserBloc>.value(value: userBloc),
              BlocProvider<RaphconBloc>.value(value: raphconBloc),
            ],
            child: RaphconDetailBottomSheet(
              userName: userName,
              type: type,
              raphcons: raphcons,
              isAdmin: isAdmin,
              onBackPressed: onBackPressed,
            ),
          ),
        ),
      ),
    );
  }
}

class _RaphconDetailBottomSheetState extends State<RaphconDetailBottomSheet> {
  final Map<String, String> _userNameCache = {};

  @override
  void initState() {
    super.initState();
    _loadUserNames();
  }

  void _loadUserNames() {
    // Load all users to cache their names
    context.read<UserBloc>().add(LoadUsersEvent());

    // Pre-load all unique creator names from raphcons
    final uniqueCreators = widget.raphcons
        .map((r) => r.createdBy)
        .where((creator) => creator.isNotEmpty)
        .toSet();

    for (final creator in uniqueCreators) {
      _loadAdminDisplayName(creator);
    }
  }

  String _getCreatorDisplayName(String createdBy) {
    if (createdBy.isEmpty) return '';
    // Check cache first
    if (_userNameCache.containsKey(createdBy)) {
      return _userNameCache[createdBy]!;
    }
    // Return a better formatted fallback while loading
    if (createdBy.contains('@')) {
      // Extract name from email
      final emailPart = createdBy.split('@')[0];
      // Capitalize first letter and replace dots with spaces
      final formatted = emailPart.replaceAll('.', ' ').toLowerCase();
      return formatted
          .split(' ')
          .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : word)
          .join(' ');
    }

    return createdBy;
  }

  Future<void> _loadAdminDisplayName(String userId) async {
    try {
      // Check if it's the current user first
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.uid == userId) {
        final displayName = currentUser?.displayName ??
            currentUser?.email?.split('@')[0] ??
            userId;
        if (mounted) {
          setState(() {
            _userNameCache[userId] = displayName;
          });
        }
        return;
      }

      // Check admins collection for display name
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userId)
          .get();

      if (adminDoc.exists) {
        final data = adminDoc.data();
        final displayName = data?['displayName'] as String? ??
            data?['email']?.toString().split('@')[0] ??
            userId;
        if (mounted) {
          setState(() {
            _userNameCache[userId] = displayName;
          });
        }
      }
    } catch (e) {
      // If error, keep the fallback
      debugPrint('Error loading admin display name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoaded) {
              setState(() {
                for (final user in state.users) {
                  _userNameCache[user.id] = user.name;
                }
              });
            }
          },
        ),
        BlocListener<RaphconBloc, RaphconState>(
          listener: (context, state) {
            if (state is RaphconDeleted) {
              // Remove from local list
              setState(() {
                widget.raphcons
                    .removeWhere((r) => r.id == state.deletedRaphconId);
              });

              // Refresh user statistics to update the overview
              context
                  .read<RaphconBloc>()
                  .add(LoadUserRaphconStatisticsEvent(widget.userName));

              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.raphconDeleted),
                    backgroundColor: Colors.green,
                  ),
                );
              }

              // Close detail sheet if no raphcons left
              if (widget.raphcons.isEmpty && mounted) {
                Navigator.of(context).pop();
              }
            } else if (state is RaphconDeletionError) {
              // Show error message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        AppLocalizations.of(context)!.errorRaphconIdNotFound),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackPressed,
                    icon: const Icon(Icons.arrow_back),
                    color: AppConstants.primaryColor,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.type.getDisplayName(localizations),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.problemStatisticsFor(widget.userName),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Divider
            const Divider(height: 1),

            // Raphcons list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildRaphconsList(context, localizations),
              ),
            ),

            // Footer with count
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.totalCount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.raphcons.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaphconsList(
      BuildContext context, AppLocalizations localizations) {
    if (widget.raphcons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              _getIconForType(widget.type),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noEntriesForThisType,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by creation date (newest first)
    final sortedRaphcons = List<RaphconEntity>.from(widget.raphcons)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedRaphcons.length,
      itemBuilder: (context, index) {
        final raphcon = sortedRaphcons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(widget.type),
                color: AppConstants.primaryColor,
                size: 24,
              ),
            ),
            title: Text(
              raphcon.comment ?? localizations.noComment,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(raphcon.createdAt, context),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (raphcon.createdBy.isNotEmpty)
                  Text(
                    localizations
                        .createdBy(_getCreatorDisplayName(raphcon.createdBy)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
            trailing: widget.isAdmin
                ? IconButton(
                    onPressed: () => _confirmDelete(context, raphcon),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  IconData _getIconForType(RaphconType type) {
    switch (type) {
      case RaphconType.headset:
        return Icons.headset;
      case RaphconType.webcam:
        return Icons.videocam;
      case RaphconType.otherPeripherals:
        return Icons.devices;
      case RaphconType.mouseHighlighter:
        return Icons.highlight_alt;
      case RaphconType.lateMeeting:
        return Icons.schedule;
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return difference.inDays == 1
          ? localizations.daysAgoSingular(difference.inDays)
          : localizations.daysAgoPlural(difference.inDays);
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? localizations.hoursAgoSingular(difference.inHours)
          : localizations.hoursAgoPlural(difference.inHours);
    } else {
      return localizations.justCreated;
    }
  }

  void _confirmDelete(BuildContext context, RaphconEntity raphcon) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.confirmDeleteRaphcon),
          content: Text(localizations.confirmDeleteRaphconMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                // Check if ID is not null before deleting
                if (raphcon.id != null) {
                  // Dispatch delete event to BLoC
                  context
                      .read<RaphconBloc>()
                      .add(DeleteRaphconEvent(raphcon.id!));
                  Navigator.of(dialogContext).pop();
                } else {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.errorRaphconIdNotFound),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.delete),
            ),
          ],
        );
      },
    );
  }
}
