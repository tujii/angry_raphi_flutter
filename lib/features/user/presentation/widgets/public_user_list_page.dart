import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/ai_config.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/enums/raphcon_type.dart';
import '../../domain/entities/user.dart' as user_entity;
import '../../../admin/presentation/bloc/admin_bloc.dart';
import '../../../raphcon_management/presentation/bloc/raphcon_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/presentation/pages/login_page.dart';
import '../bloc/user_bloc.dart';
import 'initials_add_user_dialog.dart';
import '../../../../shared/widgets/raphcon_type_selection_dialog.dart';
import '../../../../shared/widgets/raphcon_statistics_bottom_sheet.dart';
import '../../../../shared/widgets/streaming_raphcon_detail_bottom_sheet.dart';
import '../../../../services/admin_config_service.dart';
import '../../../../services/story_of_the_day_service.dart';
import '../../../../shared/widgets/user_ranking_search_delegate.dart';
import '../../../../shared/widgets/markdown_content_widget.dart';
import '../../../../shared/widgets/story_of_the_day_banner.dart';
import '../../../../core/utils/responsive_helper.dart';

class PublicUserListPage extends StatefulWidget {
  const PublicUserListPage({super.key});

  @override
  State<PublicUserListPage> createState() => _PublicUserListPageState();
}

class _PublicUserListPageState extends State<PublicUserListPage> {
  bool _isAdmin = false;
  bool _isLoggedIn = false;
  String _appVersion = '1.0.0';
  String _whatsNewContent = '';
  List<String> _storiesOfTheWeek = [];
  late StoryOfTheDayService _storyService;

  @override
  void initState() {
    super.initState();
    _storyService = StoryOfTheDayService(
      FirebaseFirestore.instance,
      geminiApiKey: AIConfig.geminiApiKey,
    );
    _checkAuthAndAdminStatus();
    _loadAppVersion();
    // Set initial localized content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _whatsNewContent.isEmpty) {
        setState(() {
          _whatsNewContent = AppLocalizations.of(context)?.subtitle ??
              'Bewerte Personen mit Raphcons';
        });
      }
    });
    _loadWhatsNewContent();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      // Fallback to hardcoded version if package info fails
      if (mounted) {
        setState(() {
          _appVersion = '1.0.1';
        });
      }
    }
  }

  Future<void> _loadWhatsNewContent() async {
    try {
      final content = await rootBundle.loadString('assets/whatsnew.md');
      if (mounted) {
        setState(() {
          if (content.trim().isNotEmpty) {
            _whatsNewContent = content.trim();
          } else {
            _whatsNewContent = AppLocalizations.of(context)?.subtitle ??
                'Bewerte Personen mit Raphcons';
          }
        });
      }
    } catch (e) {
      // Keep default value if file can't be loaded
      if (mounted) {
        setState(() {
          _whatsNewContent = AppLocalizations.of(context)?.subtitle ??
              'Bewerte Personen mit Raphcons';
        });
      }
    }
  }

  void _checkAuthAndAdminStatus() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
        });
      }

      // Check if user is admin from CSV configuration
      final isAdminUser = await AdminConfigService.isAdmin(currentUser.email!);

      if (mounted) {
        if (isAdminUser) {
          final displayName =
              await AdminConfigService.getAdminDisplayName(currentUser.email!);
          if (mounted) {
            context.read<AdminBloc>().add(EnsureCurrentUserIsAdminEvent(
                  userId: currentUser.uid,
                  email: currentUser.email!,
                  displayName: currentUser.displayName ?? displayName,
                ));
          }
        } else {
          // For other users, just check admin status
          context.read<AdminBloc>().add(CheckAdminStatusEvent(currentUser.email ?? ''));
        }
      }
    }
  }

  Future<void> _loadStoryOfTheDay(List<user_entity.User> users) async {
    if (users.isEmpty) return;

    final stories = await _storyService.getWeeklyStories(users);
    if (mounted) {
      setState(() {
        _storiesOfTheWeek = stories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _showAppIconDialog(context),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  'assets/images/icon-removebg.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showAppIconDialog(context),
              child: const Text(AppConstants.appName),
            ),
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
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded && state.users.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showSearchDelegate(context, state.users),
                  tooltip: 'Suchen & Rangliste',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserBloc>().add(RefreshUsersEvent());
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: authState.user.photoURL != null
                        ? NetworkImage(authState.user.photoURL!)
                        : null,
                    child: authState.user.photoURL == null
                        ? Text(
                            authState.user.displayName.isNotEmpty
                                ? authState.user.displayName
                                    .substring(0, 1)
                                    .toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    } else if (value == 'settings') {
                      context.push(AppRouter.adminSettings);
                    }
                  },
                  itemBuilder: (context) => [
                    // Only show settings for admins
                    if (_isAdmin)
                      PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context)?.settings ??
                                'Einstellungen'),
                          ],
                        ),
                      ),
                    // Show logout for all authenticated users
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
              if (state is AdminStatusChecked && mounted) {
                setState(() {
                  _isAdmin = state.isAdmin;
                });
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated && mounted) {
                setState(() {
                  _isLoggedIn = true;
                });
                // Check admin status after login
                context
                    .read<AdminBloc>()
                    .add(CheckAdminStatusEvent(state.user.email));
                Navigator.of(context).pop(); // Close login dialog
              } else if (state is AuthUnauthenticated && mounted) {
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
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              // Load stories when users are loaded
              if (state is UserLoaded &&
                  state.users.isNotEmpty &&
                  _storiesOfTheWeek.isEmpty) {
                _loadStoryOfTheDay(state.users);
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
      floatingActionButton: _isAdmin
          ? Tooltip(
              message: AppLocalizations.of(context)?.addUser ??
                  'Benutzer hinzufügen',
              child: Focus(
                child: Material(
                  elevation: 6.0,
                  shape: const CircleBorder(),
                  color: AppConstants.primaryColor,
                  child: InkWell(
                    onTap: () => _showAddUserDialog(context),
                    customBorder: const CircleBorder(),
                    splashColor: Colors.white.withValues(alpha: 0.3),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    focusColor: Colors.white.withValues(alpha: 0.2),
                    hoverColor:
                        AppConstants.primaryColor.withValues(alpha: 0.8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 56.0,
                      height: 56.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
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
        // Story of the Week banner (replaces login banner)
        if (_storiesOfTheWeek.isNotEmpty)
          StoryOfTheDayBanner(
            stories: _storiesOfTheWeek,
          ),

        // User list
        Expanded(
          child: ResponsiveHelper.wrapWithMaxWidth(
            context: context,
            child: ResponsiveHelper.isMobile(context)
                ? ListView.builder(
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return PublicUserCard(
                        user: users[index],
                        isAdmin: _isAdmin,
                        isLoggedIn: _isLoggedIn,
                        onNameTapped: _isAdmin
                            ? () => _createRaphcon(users[index])
                            : null,
                        onLoginRequired: () => _showLoginDialog(context),
                        onShowStatistics: () =>
                            _showStatisticsBottomSheet(users[index]),
                      );
                    },
                  )
                : GridView.builder(
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.getGridColumns(context),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return PublicUserCard(
                        user: users[index],
                        isAdmin: _isAdmin,
                        isLoggedIn: _isLoggedIn,
                        onNameTapped: _isAdmin
                            ? () => _createRaphcon(users[index])
                            : null,
                        onLoginRequired: () => _showLoginDialog(context),
                        onShowStatistics: () =>
                            _showStatisticsBottomSheet(users[index]),
                      );
                    },
                  ),
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
            child: Text(AppLocalizations.of(context)?.tryAgainButton ??
                'Erneut versuchen'),
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
          child: InitialsAddUserDialog(
            onUserAdded: (initials) {
              context.read<UserBloc>().add(AddUserEvent(
                    initials: initials,
                  ));
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      },
    );
  }

  void _showAppIconDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background tap to close
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
              // App icon with info
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Large app icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        'assets/images/icon-removebg.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // App name
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Container(
                      constraints:
                          const BoxConstraints(maxWidth: 350, maxHeight: 300),
                      child: SingleChildScrollView(
                        child: MarkdownContentWidget(content: _whatsNewContent),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Version info
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Version $_appVersion',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Close button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context)?.ok ?? 'OK'),
                    ),
                  ],
                ),
              ),
              // Close X button
              Positioned(
                top: 40,
                right: 40,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 300,
                maxWidth: 400,
                minHeight: 200,
                maxHeight: 600,
              ),
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
          child: RaphconTypeSelectionDialog(
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
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      },
    );
  }

  void _showStatisticsBottomSheet(user_entity.User user) {
    final context = this.context; // Capture context

    // Load statistics for the user
    context.read<RaphconBloc>().add(LoadUserRaphconStatisticsEvent(user.id));

    // Listen for the result and show the bottom sheet (only once)
    StreamSubscription<RaphconState>? subscription;
    subscription = context.read<RaphconBloc>().stream.listen((state) {
      if (state is UserRaphconStatisticsLoaded && context.mounted) {
        subscription?.cancel(); // Cancel immediately to prevent multiple calls
        RaphconStatisticsBottomSheet.show(
          context: context,
          userName: user.name,
          statistics: state.statistics,
          isAdmin: _isAdmin,
          onTypeSelected: (type) {
            _showDetailBottomSheet(context, user, type);
          },
        );
      } else if (state is RaphconError && context.mounted) {
        subscription?.cancel(); // Cancel on error too
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)
                      ?.errorLoadingStatistics(state.message) ??
                  'Fehler beim Laden der Statistiken: ${state.message}',
            ),
          ),
        );
      }
    });

    // Auto-cancel subscription after timeout to prevent memory leaks
    Timer(const Duration(seconds: 10), () {
      subscription?.cancel();
    });
  }

  void _showDetailBottomSheet(
      BuildContext context, user_entity.User user, RaphconType type) {
    // Show the streaming detail bottom sheet directly
    // The stream will automatically load and update the raphcons
    Navigator.of(context).pop(); // Close statistics sheet first
    StreamingRaphconDetailBottomSheet.show(
      context: context,
      userName: user.name,
      userId: user.id,
      type: type,
      isAdmin: _isAdmin,
      onBackPressed: () {
        Navigator.of(context).pop(); // Close detail sheet
        // Show statistics sheet again
        _showStatisticsBottomSheet(user);
      },
    );
  }

  void _showSearchDelegate(BuildContext context, List<user_entity.User> users) {
    showSearch(
      context: context,
      delegate: UserRankingSearchDelegate(users, AppLocalizations.of(context)!),
    );
  }
}

class PublicUserCard extends StatelessWidget {
  final user_entity.User user;
  final bool isAdmin;
  final bool isLoggedIn;
  final VoidCallback? onNameTapped;
  final VoidCallback? onLoginRequired;
  final VoidCallback? onShowStatistics;

  const PublicUserCard({
    super.key,
    required this.user,
    required this.isAdmin,
    required this.isLoggedIn,
    this.onNameTapped,
    this.onLoginRequired,
    this.onShowStatistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 4,
      child: InkWell(
        onTap:
            isAdmin ? null : onShowStatistics, // Nur für nicht-Admins klickbar
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              backgroundColor: AppConstants.primaryColor,
              radius: 24,
              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.avatarUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mood_bad,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)
                                    ?.raphconsCount(user.raphconCount) ??
                                'Raphcons: ${user.raphconCount}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onShowStatistics,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.showDetails ??
                                'Details anzeigen',
                            style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Show last Raphcon info on all devices (important info)
                  if (user.lastRaphconAt != null)
                    Text(
                      'Letzter Raphcon: ${_formatDate(user.lastRaphconAt!, context)}',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  // Show created date only on desktop (less important)
                  if (ResponsiveHelper.isDesktop(context))
                    Text(
                      AppLocalizations.of(context)?.createdTimeAgo(
                              _formatDate(user.createdAt, context)) ??
                          'Erstellt: ${_formatDate(user.createdAt, context)}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            if (isAdmin) ...[
              IconButton(
                icon: const Icon(Icons.add_circle,
                    color: AppConstants.primaryColor),
                onPressed: onNameTapped,
                tooltip: AppLocalizations.of(context)?.add ?? 'Hinzufügen',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
                tooltip: AppLocalizations.of(context)?.delete ?? 'Löschen',
              ),
            ],
          ]),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return difference.inDays == 1
          ? (AppLocalizations.of(context)?.daysAgoSingular(difference.inDays) ??
              'vor ${difference.inDays} Tag')
          : (AppLocalizations.of(context)?.daysAgoPlural(difference.inDays) ??
              'vor ${difference.inDays} Tagen');
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? (AppLocalizations.of(context)
                  ?.hoursAgoSingular(difference.inHours) ??
              'vor ${difference.inHours} Stunde')
          : (AppLocalizations.of(context)?.hoursAgoPlural(difference.inHours) ??
              'vor ${difference.inHours} Stunden');
    } else {
      return AppLocalizations.of(context)?.justCreated ?? 'gerade eben';
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
                child: Text(
                    AppLocalizations.of(context)?.cancelButton ?? 'Abbrechen'),
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
