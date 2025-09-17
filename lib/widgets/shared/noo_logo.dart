import 'package:flutter/material.dart';

/// A clean logo widget displaying the app branding
class NooLogo extends StatelessWidget {
  const NooLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          color: Theme.of(context).textTheme.headlineSmall?.color,
        ),
        children: const [
          TextSpan(
            text: 'НОО.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: 'Платформа'),
        ],
      ),
    );
  }
}
