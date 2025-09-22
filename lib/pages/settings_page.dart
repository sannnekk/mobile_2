import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';
import 'package:mobile_2/widgets/shared/settings_section.dart';
import 'package:mobile_2/widgets/shared/noo_legal.dart';
import 'package:mobile_2/widgets/shared/noo_text_input.dart';
import 'package:mobile_2/widgets/shared/noo_button.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/utils/password_validator.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _appVersion;
  String? _serverVersion;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _deletePasswordController = TextEditingController();

  // Form keys
  final _passwordFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();

  // Form states
  bool _updatingName = false;
  bool _updatingEmail = false;
  bool _updatingPassword = false;
  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    // Load app version
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
    } catch (e) {
      _appVersion = 'Unknown';
    }

    // Load server version
    final result = await ApiResponseHandler.handleCall<String>(() async {
      final auth = await ref.read(authServiceProvider.future);
      return auth.getServerVersion();
    });
    if (result.isSuccess && result.data != null) {
      _serverVersion = result.data;
    } else {
      _serverVersion = 'Unknown';
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        NooTabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Аккаунт'),
            Tab(text: 'Telegram'),
            Tab(text: 'Внешний вид'),
            Tab(text: 'Системные'),
          ],
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAccountTab(),
              _buildTelegramTab(),
              _buildAppearanceTab(),
              _buildSystemTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGeneralSection(),
          _buildPasswordSection(),
          _buildUserSessionsSection(),
          _buildDeleteAccountSection(),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    return SettingsSection(
      title: 'Общие',
      child: Column(
        children: [
          _buildChangeNameForm(),
          const SizedBox(height: 16),
          _buildChangeEmailForm(),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return SettingsSection(
      title: 'Изменение пароля',
      child: Column(children: [_buildChangePasswordForm()]),
    );
  }

  Widget _buildUserSessionsSection() {
    return const SettingsSection(
      title: 'Сессии пользователей',
      child: Text('В разработке'),
    );
  }

  Widget _buildDeleteAccountSection() {
    return SettingsSection(
      title: 'Удаление аккаунта',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Удаление аккаунта необратимо. Все ваши данные будут удалены.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          _buildDeleteAccountForm(),
        ],
      ),
    );
  }

  Widget _buildTelegramTab() {
    return const Center(child: Text('Настройки Telegram - в разработке'));
  }

  Widget _buildAppearanceTab() {
    return const Center(child: Text('Настройки внешнего вида - в разработке'));
  }

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SettingsSection(
            title: 'Версии',
            child: Column(
              children: [
                _buildVersionRow(
                  'Версия приложения',
                  _appVersion ?? 'Загрузка...',
                ),
                const SizedBox(height: 8),
                _buildVersionRow(
                  'Версия сервера',
                  _serverVersion ?? 'Загрузка...',
                ),
              ],
            ),
          ),
          const SettingsSection(
            title: 'Правовая информация',
            child: NooLegal(),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeNameForm() {
    final user = ref.watch(authStateProvider).user;
    if (user == null) return const SizedBox.shrink();

    return Form(
      key: _nameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NooTextInput(
            controller: _nameController..text = user.name,
            label: 'Новое имя',
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NooButton(
                label: 'Изменить имя',
                style: NooButtonStyle.secondary,
                onPressed: _updatingName ? null : _updateName,
                loading: _updatingName,
                expanded: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeEmailForm() {
    final user = ref.watch(authStateProvider).user;
    if (user == null) return const SizedBox.shrink();

    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NooTextInput(
            controller: _emailController..text = user.email,
            label: 'Ваш email',
            validator: _validateEmail,
          ),
          const SizedBox(height: 8),
          const NooText(
            'Email будет изменён только после того, как вы подтвердите его, перейдя по ссылке в письме, отправленном на новый адрес',
            dimmed: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NooButton(
                label: 'Изменить email',
                style: NooButtonStyle.secondary,
                onPressed: _updatingEmail ? null : _updateEmail,
                loading: _updatingEmail,
                expanded: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordForm() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NooTextInput(
            controller: _oldPasswordController,
            label: 'Текущий пароль',
            password: true,
          ),
          const SizedBox(height: 8),
          NooTextInput(
            controller: _newPasswordController,
            label: 'Новый пароль',
            password: true,
            validator: _validateNewPassword,
          ),
          const SizedBox(height: 8),
          NooTextInput(
            controller: _confirmPasswordController,
            label: 'Подтвердите новый пароль',
            password: true,
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NooButton(
                label: 'Изменить пароль',
                style: NooButtonStyle.secondary,
                onPressed: _updatingPassword ? null : _updatePassword,
                loading: _updatingPassword,
                expanded: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NooTextInput(
          controller: _deletePasswordController,
          label: 'Пароль',
          password: true,
        ),
        const SizedBox(height: 8),
        NooButton(
          label: 'Удалить аккаунт',
          style: NooButtonStyle.danger,
          onPressed: _deletingAccount ? null : _showDeleteConfirmation,
          loading: _deletingAccount,
          expanded: false,
        ),
      ],
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Имя обязательно';
    }
    if (value.trim().length > 255) {
      return 'Имя не должно превышать 255 символов';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email обязателен';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    return PasswordValidator.validate(value);
  }

  String? _validateConfirmPassword(String? value) {
    return PasswordValidator.validateConfirmation(
      value,
      _newPasswordController.text,
    );
  }

  Future<void> _updateName() async {
    if (!_nameFormKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    setState(() => _updatingName = true);
    final result = await ApiResponseHandler.handleCall<void>(() async {
      final auth = await ref.read(authServiceProvider.future);
      return auth.updateUserName(
        user.id.toString(),
        _nameController.text.trim(),
      );
    });

    if (result.isSuccess) {
      // Update local user state
      final updatedUser = UserEntity(
        id: user.id,
        createdAt: user.createdAt,
        name: _nameController.text.trim(),
        email: user.email,
        role: user.role,
        username: user.username,
        telegramUsername: user.telegramUsername,
        telegramId: user.telegramId,
        telegramNotificationsEnabled: user.telegramNotificationsEnabled,
        isBlocked: user.isBlocked,
        avatar: user.avatar,
        updatedAt: user.updatedAt,
      );
      ref.read(authStateProvider.notifier).updateUser(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Имя обновлено')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Ошибка обновления имени')),
        );
      }
    }
    if (mounted) setState(() => _updatingName = false);
  }

  Future<void> _updateEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) {
      return;
    }

    setState(() => _updatingEmail = true);
    final result = await ApiResponseHandler.handleCall<void>(() async {
      final auth = await ref.read(authServiceProvider.future);
      return auth.updateUserEmail(
        user.id.toString(),
        _emailController.text.trim(),
      );
    });

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email будет изменён после проверки почты'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Ошибка обновления email')),
        );
      }
    }
    if (mounted) setState(() => _updatingEmail = false);
  }

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).user;
    if (user == null || _oldPasswordController.text.isEmpty) {
      return;
    }

    setState(() => _updatingPassword = true);
    final result = await ApiResponseHandler.handleCall<void>(() async {
      final auth = await ref.read(authServiceProvider.future);
      return auth.updateUserPassword(
        user.id.toString(),
        _oldPasswordController.text,
        _newPasswordController.text,
      );
    });

    if (result.isSuccess) {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Пароль обновлён')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Ошибка обновления пароля')),
        );
      }
    }
    if (mounted) setState(() => _updatingPassword = false);
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: const Text(
          'Это действие необратимо. Все данные будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    final user = ref.read(authStateProvider).user;
    if (user == null || _deletePasswordController.text.isEmpty) return;

    setState(() => _deletingAccount = true);
    final result = await ApiResponseHandler.handleCall<void>(() async {
      final auth = await ref.read(authServiceProvider.future);
      return auth.deleteUserAccount(
        user.id.toString(),
        _deletePasswordController.text,
      );
    });

    if (result.isSuccess) {
      // Logout and redirect to auth page
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) context.go('/auth');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Ошибка удаления аккаунта')),
        );
      }
    }
    if (mounted) setState(() => _deletingAccount = false);
  }

  Widget _buildVersionRow(String label, String version) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16),
        ),
        Text(
          version,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
