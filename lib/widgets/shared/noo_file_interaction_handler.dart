import 'package:flutter/material.dart';
import 'package:mobile_2/app_config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_2/core/entities/media.dart';

class NooFileInteractionHandler extends StatelessWidget {
  final MediaEntity media;
  final Widget child;

  const NooFileInteractionHandler({
    super.key,
    required this.media,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFile(context),
      onLongPress: () => _showShareOptions(context),
      child: child,
    );
  }

  Future<void> _openFile(BuildContext context) async {
    try {
      final uri = Uri.parse(AppConfig.CDN_URL + media.src);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Не удалось открыть файл ${uri.toString()}'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть файл'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Поделиться файлом'),
                onTap: () {
                  Navigator.of(context).pop();
                  _shareFile(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Отменить'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      await Share.share(media.name, subject: media.name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при отправке файла'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
