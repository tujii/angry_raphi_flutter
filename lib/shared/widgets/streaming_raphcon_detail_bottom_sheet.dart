import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/raphcon_type.dart';
import '../../features/raphcon_management/domain/entities/raphcon_entity.dart';
import '../../features/raphcon_management/presentation/bloc/raphcon_bloc.dart';
import '../../features/user/presentation/bloc/user_bloc.dart';

/// Stream-based detailed bottom sheet that shows individual raphcon entries for a specific type
/// Automatically updates when new raphcons are added or deleted
/// Allows admins to delete individual raphcons
class StreamingRaphconDetailBottomSheet extends StatefulWidget {
  final String userName;
  final String userId;
  final RaphconType type;
  final bool isAdmin;
  final VoidCallback onBackPressed;

  const StreamingRaphconDetailBottomSheet({
    super.key,
    required this.userName,
    required this.userId,
    required this.type,
    required this.isAdmin,
    required this.onBackPressed,
  });

  @override
  State<StreamingRaphconDetailBottomSheet> createState() =>
      _StreamingRaphconDetailBottomSheetState();

  /// Static method to show the streaming detail bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String userName,
    required String userId,
    required RaphconType type,
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
            child: StreamingRaphconDetailBottomSheet(
              userName: userName,
              userId: userId,
              type: type,
              isAdmin: isAdmin,
              onBackPressed: onBackPressed,
            ),
          ),
        ),
      ),
    );
  }
}

class _StreamingRaphconDetailBottomSheetState
    extends State<StreamingRaphconDetailBottomSheet> {
  final Map<String, String> _adminUserCache = {};
  late RaphconBloc _raphconBloc;

  @override
  void initState() {
    super.initState();
    _loadUserNames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely store the RaphconBloc reference
    _raphconBloc = context.read<RaphconBloc>();
    // Start the stream for raphcons of this type for this user
    _raphconBloc.add(
      StartUserRaphconsByTypeStreamEvent(widget.userId, widget.type),
    );
  }

  @override
  void dispose() {
    // Stop the stream when widget is disposed
    _raphconBloc.add(StopRaphconsStreamEvent());
    super.dispose();
  }

  void _loadUserNames() {
    // Load all users to cache their names
    context.read<UserBloc>().add(LoadUsersEvent());
  }

  String _getCreatorDisplayName(String createdBy) {
    return _adminUserCache[createdBy] ?? 'Administrator';
  }

  void _loadAdminDisplayName(String adminId) async {
    if (_adminUserCache.containsKey(adminId)) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final displayName = data['displayName'] as String? ?? 'Administrator';
        if (mounted) {
          setState(() {
            _adminUserCache[adminId] = displayName;
          });
        }
      }
    } catch (e) {
      // Fallback to generic admin name
      if (mounted) {
        setState(() {
          _adminUserCache[adminId] = 'Administrator';
        });
      }
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
                  _adminUserCache[user.id] = user.name;
                }
              });
            }
          },
        ),
        BlocListener<RaphconBloc, RaphconState>(
          listener: (context, state) {
            if (state is RaphconDeleted) {
              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.raphconDeleted),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else if (state is RaphconDeletionError) {
              // Show error message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.errorRaphconIdNotFound),
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

            // Stream-based Raphcons list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildStreamingRaphconsList(context, localizations),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamingRaphconsList(
      BuildContext context, AppLocalizations localizations) {
    return BlocBuilder<RaphconBloc, RaphconState>(
      builder: (context, state) {
        if (state is RaphconLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          );
        }

        if (state is RaphconsStreamError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Fehler: ${state.message}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RaphconBloc>().add(
                          StartUserRaphconsByTypeStreamEvent(
                              widget.userId, widget.type),
                        );
                  },
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          );
        }

        List<RaphconEntity> raphcons = [];
        if (state is RaphconsStreamLoaded) {
          raphcons = state.raphcons;
        }

        if (raphcons.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ),
              // Footer with count (0)
              Container(
                width: double.infinity,
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
                    const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Sort by creation date (newest first)
        final sortedRaphcons = List<RaphconEntity>.from(raphcons)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sortedRaphcons.length,
                itemBuilder: (context, index) {
                  final raphcon = sortedRaphcons[index];

                  // Pre-load creator name if not cached
                  if (!_adminUserCache.containsKey(raphcon.createdBy) &&
                      raphcon.createdBy.isNotEmpty) {
                    _loadAdminDisplayName(raphcon.createdBy);
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              AppConstants.primaryColor.withValues(alpha: 0.1),
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
                              localizations.createdBy(
                                  _getCreatorDisplayName(raphcon.createdBy)),
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
              ),
            ),
            // Footer with count
            Container(
              width: double.infinity,
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
                    '${raphcons.length}',
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
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, RaphconEntity raphcon) {
    final localizations = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.delete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Möchtest du diesen Raphcon wirklich löschen?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconForType(widget.type),
                          size: 20,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.type.getDisplayName(localizations),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      raphcon.comment ?? localizations.noComment,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(raphcon.createdAt, context),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                      content: Text(localizations.errorRaphconIdNotFound),
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'vor ${difference.inDays} ${difference.inDays == 1 ? 'Tag' : 'Tagen'}';
    } else if (difference.inHours > 0) {
      return 'vor ${difference.inHours} ${difference.inHours == 1 ? 'Stunde' : 'Stunden'}';
    } else if (difference.inMinutes > 0) {
      return 'vor ${difference.inMinutes} ${difference.inMinutes == 1 ? 'Minute' : 'Minuten'}';
    } else {
      return 'gerade eben';
    }
  }
}
