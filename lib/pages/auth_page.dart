import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/services/auth_service_types.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import '../widgets/shared/noo_text_input.dart';
import '../widgets/shared/noo_button.dart';
import '../widgets/shared/noo_card.dart';
import '../widgets/shared/noo_text_title.dart';
import '../widgets/shared/noo_logo.dart';
import '../widgets/shared/noo_typing_text.dart';
import '../widgets/shared/noo_legal.dart';
import '../constants/auth_messages.dart';
import '../widgets/shared/auth_links_section.dart';
import '../widgets/shared/forgot_password_form.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  // Form switching state
  bool _showForgotPassword = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _toggleForgotPassword() {
    setState(() {
      _showForgotPassword = !_showForgotPassword;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await ApiResponseHandler.handleCall<AuthLoginResponse>(
      () async {
        final auth = await ref.read(authServiceProvider.future);
        return auth.login(
          AuthLoginRequest(
            usernameOrEmail: _usernameCtrl.text.trim(),
            password: _passwordCtrl.text,
          ),
          // Don't persist token yet — we'll check role first
          rememberToken: false,
        );
      },
    );
    if (result.isSuccess && result.data != null) {
      final data = result.data!;
      // Allow login only for students
      if (data.payload.role != UserRole.student) {
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Доступ ограничен'),
              content: const Text(
                'Сейчас приложение доступно только для учеников.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Ок'),
                ),
              ],
            ),
          );
        }
      } else {
        // Update auth state and persist token only for allowed role
        final authNotifier = ref.read(authStateProvider.notifier);
        await authNotifier.login(data.token, data.payload, user: data.user);

        // Navigation will be handled by router automatically
        if (mounted) context.go('/courses');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error ?? 'Ошибка входа')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 64),

            // App Logo
            const NooLogo(),
            const SizedBox(height: 40),

            // Auth Icon
            SvgPicture.asset(
              'assets/images/auth-icon-space.svg',
              width: MediaQuery.of(context).size.width * 0.8,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),

            // Typing Text Animation
            NooTypingText(
              messages: authMarketingMessages,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // Form Container with Animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                final offset =
                    Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: _showForgotPassword
                  ? ForgotPasswordForm(
                      key: const ValueKey('forgot_form'),
                      onBackToLogin: _toggleForgotPassword,
                    )
                  : NooCard(
                      key: const ValueKey('login_form'),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const NooTextTitle(
                              'Вход на платформу',
                              size: NooTitleSize.large,
                            ),
                            const SizedBox(height: 24),
                            NooTextInput(
                              controller: _usernameCtrl,
                              label: 'Никнейм или email',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Это поле обязательно'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            NooTextInput(
                              controller: _passwordCtrl,
                              label: 'Пароль',
                              password: true,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Это поле обязательно'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            NooButton(
                              label: 'Войти',
                              style: NooButtonStyle.primary,
                              onPressed: _loading ? null : _submit,
                              loading: _loading,
                            ),
                            const SizedBox(height: 16),
                            AuthLinksSection(
                              onForgotPassword: _toggleForgotPassword,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 64),

            // Legal Information
            const NooLegal(),
          ],
        ),
      ),
    );
  }
}
