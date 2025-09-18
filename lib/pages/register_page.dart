import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/register_provider.dart';
import '../widgets/shared/noo_text_input.dart';
import '../widgets/shared/noo_username_input.dart';
import '../widgets/shared/noo_button.dart';
import '../widgets/shared/noo_card.dart';
import '../widgets/shared/noo_text_title.dart';
import '../widgets/shared/noo_logo.dart';
import '../widgets/shared/noo_text_button.dart';
import '../core/utils/password_validator.dart';
import '../widgets/shared/noo_legal.dart';

/// Registration page for new users
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Имя обязательно';
    }
    if (value.trim().length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Никнейм обязателен';
    }
    if (value.trim().length < 3) {
      return 'Никнейм должен содержать минимум 3 символа';
    }
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(value)) {
      return 'Никнейм может содержать только буквы, цифры, точки, дефисы и подчеркивания';
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

  String? _validatePassword(String? value) {
    return PasswordValidator.validate(value);
  }

  String? _validateConfirmPassword(String? value) {
    return PasswordValidator.validateConfirmation(
      value,
      _passwordController.text,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final registerNotifier = ref.read(registerProvider.notifier);
    await registerNotifier.register(
      name: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    final state = ref.read(registerProvider);
    if (state.error == null && !state.isLoading) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Регистрация успешна! Теперь проверьте ваш email, чтобы подтвердить регистрацию.',
            ),
          ),
        );
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 64),
            const NooLogo(),
            const SizedBox(height: 40),

            NooCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const NooTextTitle('Регистрация', size: NooTitleSize.large),
                    const SizedBox(height: 24),

                    if (registerState.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          registerState.error!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    NooTextInput(
                      controller: _nameController,
                      label: 'Имя',
                      validator: _validateName,
                    ),
                    const SizedBox(height: 12),

                    UsernameInput(
                      controller: _usernameController,
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 12),

                    NooTextInput(
                      controller: _emailController,
                      label: 'Email',
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),

                    NooTextInput(
                      controller: _passwordController,
                      label: 'Пароль',
                      password: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 12),

                    NooTextInput(
                      controller: _confirmPasswordController,
                      label: 'Подтверждение пароля',
                      password: true,
                      validator: _validateConfirmPassword,
                    ),
                    const SizedBox(height: 24),

                    NooButton(
                      label: 'Зарегистрироваться',
                      onPressed: registerState.isLoading ? null : _submit,
                      loading: registerState.isLoading,
                    ),
                    const SizedBox(height: 16),

                    NooTextButton(
                      label: 'Уже есть аккаунт? Войти',
                      onPressed: () => context.go('/auth'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 64),
            const NooLegal(),
          ],
        ),
      ),
    );
  }
}
