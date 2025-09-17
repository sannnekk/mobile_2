import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'noo_text_button.dart';

/// Links section for authentication page with register and forgot password options
class AuthLinksSection extends StatelessWidget {
  final VoidCallback? onForgotPassword;

  const AuthLinksSection({super.key, this.onForgotPassword});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NooTextButton(
          label: 'Зарегистрироваться',
          onPressed: () => context.go('/register'),
        ),
        NooTextButton(
          label: 'Забыли пароль? Восстановить пароль',
          onPressed: onForgotPassword,
        ),
      ],
    );
  }
}
