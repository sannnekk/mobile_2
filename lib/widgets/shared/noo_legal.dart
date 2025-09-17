import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Legal information widget with copyright and policy links
class NooLegal extends StatelessWidget {
  final String companyName;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;

  const NooLegal({
    super.key,
    this.companyName = 'НОО.Платформа',
    this.privacyPolicyUrl = 'https://example.com/privacy-policy',
    this.termsOfServiceUrl = 'https://example.com/terms-of-service',
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodySmall?.color;
    final linkColor = Theme.of(context).colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copyright row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copyright, size: 16, color: textColor),
            const SizedBox(width: 4),
            Text(
              '${DateTime.now().year} $companyName',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Legal links
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 4,
          children: [
            GestureDetector(
              onTap: () => _launchUrl(privacyPolicyUrl),
              child: Text(
                'Политика конфиденциальности',
                style: TextStyle(
                  color: linkColor,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _launchUrl(termsOfServiceUrl),
              child: Text(
                'Договор публичной оферты',
                style: TextStyle(
                  color: linkColor,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
