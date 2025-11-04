import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/providers/statistics_providers.dart';
import 'package:mobile_2/core/providers/mentor_providers.dart';
import 'package:mobile_2/widgets/shared/noo_app_scaffold.dart';
import 'package:mobile_2/widgets/shared/noo_logout_button.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_user_avatar.dart';
import 'package:mobile_2/widgets/shared/noo_user_info_card.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';
import 'package:mobile_2/widgets/shared/noo_error_view.dart';
import 'package:mobile_2/widgets/shared/noo_select_input.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_mentor_assignment_card.dart';
import 'package:mobile_2/widgets/shared/noo_empty_list.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/entities/statistics.dart';
import 'package:mobile_2/core/utils/debouncer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/core/providers/media_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _fromDate;
  late DateTime _toDate;
  WorkType? _selectedWorkType;
  late Debouncer _debouncer;
  late StatisticsRequest _currentRequest;
  bool _changingAvatar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDefaultDates();
    _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
    _currentRequest = StatisticsRequest(
      from: _fromDate,
      to: _toDate,
      type: _selectedWorkType,
    );
    _fetchUserData();
  }

  void _initializeDefaultDates() {
    final now = DateTime.now();
    final currentDay = now.day;

    if (currentDay >= 18) {
      // If it's 18th or later, from = 17th of this month, to = today
      _fromDate = DateTime(now.year, now.month, 17);
      _toDate = now;
    } else {
      // If it's 17th or earlier, from = 17th of previous month, to = today
      final previousMonth = now.month == 1 ? 12 : now.month - 1;
      final previousYear = now.month == 1 ? now.year - 1 : now.year;
      _fromDate = DateTime(previousYear, previousMonth, 17);
      _toDate = now;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debouncer.dispose();
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

  Future<void> _refreshProfile() async {
    await _fetchUserData();

    final refreshedState = ref.read(authStateProvider);
    final user = refreshedState.user;
    if (user == null) return;

    final statisticsProvider = userStatisticsProvider(
      user.username,
      _currentRequest,
    );
    final mentorsProvider = userMentorAssignmentsProvider(user.username);

    ref.invalidate(statisticsProvider);
    ref.invalidate(mentorsProvider);

    try {
      await ref.read(statisticsProvider.future);
    } catch (_) {
      // Let the UI handle errors via AsyncValue
    }

    try {
      await ref.read(mentorsProvider.future);
    } catch (_) {
      // Let the UI handle errors via AsyncValue
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
            context.push('/settings');
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Huge avatar with edit capability
                    _buildEditableAvatar(user),
                    const SizedBox(height: 24),

                    // User info
                    NooUserInfoCard(user: user),

                    // logout button
                    const SizedBox(height: 16),
                    NooLogoutButton(),
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
              SizedBox(
                height: 1200,
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
        ),
      ),
    );
  }

  Widget _buildEditableAvatar(UserEntity user) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _changingAvatar ? null : _showAvatarOptions,
          child: NooUserAvatar(user: user, avatar: user.avatar, radius: 80),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
          ),
        ),
        if (_changingAvatar)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAvatarOptions() async {
    if (!mounted) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Выбрать из галереи'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Сделать фото'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source != null) {
      await _handlePickOrCapture(source);
    }
  }

  Future<void> _handlePickOrCapture(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      setState(() => _changingAvatar = true);

      final bytes = await picked.readAsBytes();

      // 1) Upload media
      final mediaResp = await ApiResponseHandler.handleCall<MediaEntity>(
        () async {
          final mediaService = await ref.read(mediaServiceProvider.future);
          return mediaService.uploadImageBytes(bytes, filename: picked.name);
        },
      );

      if (!mounted) return;

      if (!mediaResp.isSuccess || mediaResp.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mediaResp.error ?? 'Ошибка загрузки изображения'),
          ),
        );
        setState(() => _changingAvatar = false);
        return;
      }

      final uploaded = mediaResp.data!;

      // 2) Patch user avatar
      final user = ref.read(authStateProvider).user;
      if (user == null) {
        setState(() => _changingAvatar = false);
        return;
      }

      final newAvatar = UserAvatarEntity(
        id: user.avatar?.id ?? '',
        createdAt: user.avatar?.createdAt ?? DateTime.now(),
        media: uploaded,
        avatarType: AvatarType.custom,
        telegramAvatarUrl: '',
        updatedAt: user.avatar?.updatedAt,
      );

      final patchResp = await ApiResponseHandler.handleCall<void>(() async {
        final auth = await ref.read(authServiceProvider.future);
        return auth.updateUserAvatar(user.id.toString(), newAvatar);
      });

      if (!mounted) return;

      if (patchResp.isSuccess) {
        // Update local user state for immediate UI refresh
        final updatedUser = UserEntity(
          id: user.id,
          createdAt: user.createdAt,
          name: user.name,
          email: user.email,
          role: user.role,
          username: user.username,
          telegramUsername: user.telegramUsername,
          telegramId: user.telegramId,
          telegramNotificationsEnabled: user.telegramNotificationsEnabled,
          isBlocked: user.isBlocked,
          avatar: newAvatar,
          updatedAt: user.updatedAt,
          mentorAssignmentsAsStudent: user.mentorAssignmentsAsStudent,
          mentorAssignmentsAsMentor: user.mentorAssignmentsAsMentor,
        );
        await ref.read(authStateProvider.notifier).updateUser(updatedUser);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Аватар обновлён')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(patchResp.error ?? 'Ошибка обновления аватара'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось изменить аватар: $e')));
    } finally {
      if (mounted) setState(() => _changingAvatar = false);
    }
  }

  Widget _buildStatisticsTab() {
    final authState = ref.watch(authStateProvider);
    final user = authState.user!;

    final statisticsAsync = ref.watch(
      userStatisticsProvider(user.username, _currentRequest),
    );

    return Column(
      children: [
        // Filters section
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: 'От',
                      selectedDate: _fromDate,
                      onDateSelected: _onFromDateChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'До',
                      selectedDate: _toDate,
                      onDateSelected: _onToDateChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildWorkTypeDropdown(),
            ],
          ),
        ),

        // Statistics content
        statisticsAsync.when(
          data: (statistics) => _buildStatisticsContent(statistics),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16),
            child: NooErrorView(
              error: 'Ошибка загрузки статистики: $error',
              onRetry: () => ref.refresh(
                userStatisticsProvider(user.username, _currentRequest),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsContent(Statistics statistics) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statistics.sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NooTextTitle(section.name),
                    if (section.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      NooText(section.description),
                    ],
                  ],
                ),
              ),

              // Section entries
              ...section.entries.map((entry) => _buildStatisticsEntry(entry)),

              // Section plots
              ...section.plots.map((plot) => _buildStatisticsPlot(plot)),

              if (index < statistics.sections.length - 1)
                const Divider(height: 32),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatisticsEntry(StatisticsEntry entry) {
    return NooCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: NooTextTitle(entry.name, size: NooTitleSize.small),
              ),
              NooTextTitle(entry.value.toString(), size: NooTitleSize.small),
              if (entry.percentage != null) ...[
                const SizedBox(width: 8),
                NooText(
                  '(${entry.percentage!.toStringAsFixed(1)}%)',
                  dimmed: true,
                ),
              ],
            ],
          ),
          if (entry.description != null && entry.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            NooText(entry.description!),
          ],
          if (entry.subEntries != null && entry.subEntries!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...entry.subEntries!.map(
              (subEntry) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    NooText('• ${subEntry.name}'),
                    const Spacer(),
                    NooText(subEntry.value.toString()),
                    if (subEntry.percentage != null) ...[
                      const SizedBox(width: 8),
                      NooText(
                        '(${subEntry.percentage!.toStringAsFixed(1)}%)',
                        dimmed: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsPlot(dynamic plotData) {
    if (plotData is Plot) {
      return _buildSinglePlot(plotData);
    } else if (plotData is List) {
      return Column(
        children: plotData
            .map((plot) => _buildSinglePlot(plot as Plot))
            .toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSinglePlot(Plot plot) {
    final spots = plot.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();

    final color = _getPlotColor(plot.color);

    return NooCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plot.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (spots.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Нет данных для отображения',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 22, 26),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: plot.data.length > 10
                              ? (plot.data.length / 5).ceil().toDouble()
                              : 1,
                          reservedSize:
                              80, // Increased further for rotated text
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < plot.data.length) {
                              // Show fewer labels if there are many data points
                              final shouldShowLabel =
                                  plot.data.length <= 10 ||
                                  index %
                                          (plot.data.length > 10
                                              ? (plot.data.length / 5).ceil()
                                              : 1) ==
                                      0;

                              if (shouldShowLabel) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    8,
                                    0,
                                    0,
                                  ),
                                  child: Transform.rotate(
                                    angle:
                                        -0.5, // Rotate text slightly for better fit
                                    child: Text(
                                      plot.data[index].key,
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      border: Border(
                        left: BorderSide(color: Theme.of(context).dividerColor),
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: color,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.1),
                        ),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPlotColor(PlotColor color) {
    switch (color) {
      case PlotColor.primary:
        return Theme.of(context).primaryColor;
      case PlotColor.secondary:
        return Theme.of(context).colorScheme.secondary;
      case PlotColor.success:
        return Colors.green;
      case PlotColor.danger:
        return Colors.red;
      case PlotColor.warning:
        return Colors.orange;
      case PlotColor.info:
        return Colors.blue;
      case PlotColor.light:
        return Colors.grey[300]!;
      case PlotColor.dark:
        return Colors.grey[800]!;
    }
  }

  void _onFromDateChanged(DateTime date) {
    setState(() {
      _fromDate = date;
      _updateCurrentRequest();
    });
  }

  void _onToDateChanged(DateTime date) {
    setState(() {
      _toDate = date;
      _updateCurrentRequest();
    });
  }

  void _onWorkTypeChanged(WorkType? workType) {
    setState(() {
      _selectedWorkType = workType;
      _updateCurrentRequest();
    });
  }

  void _updateCurrentRequest() {
    _currentRequest = StatisticsRequest(
      from: _fromDate,
      to: _toDate,
      type: _selectedWorkType,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('dd.MM.yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkTypeDropdown() {
    return NooSelectInput<WorkType?>(
      label: 'Тип работы',
      hint: 'Все типы',
      value: _selectedWorkType,
      items: [
        const DropdownMenuItem<WorkType?>(value: null, child: Text('Все типы')),
        ...WorkType.values.map((type) {
          return DropdownMenuItem<WorkType?>(
            value: type,
            child: Text(_getWorkTypeDisplayName(type)),
          );
        }),
      ],
      onChanged: _onWorkTypeChanged,
    );
  }

  String _getWorkTypeDisplayName(WorkType type) {
    switch (type) {
      case WorkType.test:
        return 'Тест';
      case WorkType.miniTest:
        return 'Мини-тест';
      case WorkType.phrase:
        return 'Фраза';
      case WorkType.secondPart:
        return 'Вторая часть';
      case WorkType.trialWork:
        return 'Пробная работа';
    }
  }

  Widget _buildMentorsTab() {
    final authState = ref.watch(authStateProvider);
    final user = authState.user!;

    final mentorAssignmentsAsync = ref.watch(
      userMentorAssignmentsProvider(user.username),
    );

    return mentorAssignmentsAsync.when(
      data: (assignments) {
        if (assignments.isEmpty) {
          return const NooEmptyList(
            title: 'Нет кураторов',
            message: 'У вас пока нет назначенных кураторов',
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: assignments
                .map(
                  (assignment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NooMentorAssignmentCard(assignment: assignment),
                  ),
                )
                .toList(),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: NooErrorView(
          error: 'Ошибка загрузки кураторов: $error',
          onRetry: () =>
              ref.refresh(userMentorAssignmentsProvider(user.username)),
        ),
      ),
    );
  }

  Widget _buildPollsTab() {
    return const Center(child: Text('Мои опросы - в разработке'));
  }
}
