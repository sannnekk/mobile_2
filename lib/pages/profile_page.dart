import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/widgets/shared/noo_app_scaffold.dart';
import 'package:mobile_2/widgets/shared/noo_user_avatar.dart';
import 'package:mobile_2/widgets/shared/noo_user_info_card.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'package:mobile_2/core/entities/user.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) return;

    final username = authState.user!.username;
    try {
      final result = await ApiResponseHandler.handleCall<UserEntity>(() async {
        final authService = await ref.read(authServiceProvider.future);
        return authService.getUser(username);
      });

      if (result.isSuccess && result.data != null && mounted) {
        final user = result.data!;
        // Check if user data has changed
        final currentUser = ref.read(authStateProvider).user;

        if (currentUser == null || !_areUsersEqual(user, currentUser)) {
          // Update auth state
          final authNotifier = ref.read(authStateProvider.notifier);
          await authNotifier.updateUser(user);
        }
      }
    } catch (e) {
      // Silently ignore errors for background fetch
    }
  }

  bool _areUsersEqual(UserEntity a, UserEntity b) {
    return a.id == b.id &&
        a.name == b.name &&
        a.email == b.email &&
        a.role == b.role &&
        a.username == b.username &&
        a.telegramUsername == b.telegramUsername &&
        a.telegramId == b.telegramId &&
        a.telegramNotificationsEnabled == b.telegramNotificationsEnabled &&
        a.isBlocked == b.isBlocked &&
        a.avatar?.id == b.avatar?.id &&
        a.avatar?.avatarType == b.avatar?.avatarType &&
        a.avatar?.telegramAvatarUrl == b.avatar?.telegramAvatarUrl &&
        a.avatar?.media?.id == b.avatar?.media?.id;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (authState.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = authState.user!;

    return NooAppScaffold(
      title: 'Профиль',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.go('/settings');
          },
        ),
      ],
      child: Column(
        children: [
          // Profile header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Huge avatar
                NooUserAvatar(user: user, avatar: user.avatar, radius: 80),
                const SizedBox(height: 24),

                // User info
                NooUserInfoCard(user: user),
              ],
            ),
          ),

          // Tabs
          NooTabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Статистика'),
              Tab(text: 'Мои кураторы'),
              Tab(text: 'Мои опросы'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatisticsTab(),
                _buildMentorsTab(),
                _buildPollsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return const Center(child: Text('Статистика - в разработке'));
  }

  Widget _buildMentorsTab() {
    return const Center(child: Text('Мои кураторы - в разработке'));
  }

  Widget _buildPollsTab() {
    return const Center(child: Text('Мои опросы - в разработке'));
  }
}
