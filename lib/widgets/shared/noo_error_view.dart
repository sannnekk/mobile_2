import 'package:flutter/material.dart';
import 'noo_button.dart';
import 'noo_text.dart';
import 'noo_text_title.dart';

class NooErrorView extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const NooErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/error.png',
              width: screenWidth,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const NooTextTitle('Ошибка'),
            const SizedBox(height: 8),
            NooText(error, align: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              NooButton(
                label: 'Повторить',
                onPressed: onRetry,
                style: NooButtonStyle.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
