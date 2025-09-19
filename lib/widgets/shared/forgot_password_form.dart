import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/services/auth_service_types.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'noo_text_input.dart';
import 'noo_button.dart';
import 'noo_card.dart';
import 'noo_text_title.dart';

/// Forgot password form component
class ForgotPasswordForm extends ConsumerStatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordForm({super.key, required this.onBackToLogin});

  @override
  ConsumerState<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends ConsumerState<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiResponseHandler.handleCall<void>(() async {
      final auth = await ref.read(authServiceProvider.future);
      return auth.forgotPassword(
        AuthForgotPasswordRequest(_emailController.text.trim()),
      );
    });

    if (result.isSuccess) {
      setState(() => _emailSent = true);
    } else {
      setState(
        () => _error = result.error ?? 'Произошла ошибка при отправке запроса',
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NooCard(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NooTextTitle(
              'Восстановление пароля',
              size: NooTitleSize.medium,
            ),
            const SizedBox(height: 16),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_emailSent) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Инструкции по восстановлению отправлены на ваш email. Проверьте почту.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            NooTextInput(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              validator: _validateEmail,
            ),
            const SizedBox(height: 24),

            NooButton(
              label: _emailSent ? 'Отправить повторно' : 'Отправить инструкции',
              onPressed: _loading ? null : _submit,
              loading: _loading,
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: widget.onBackToLogin,
              child: const Text('Вернуться ко входу'),
            ),
          ],
        ),
      ),
    );
  }
}
