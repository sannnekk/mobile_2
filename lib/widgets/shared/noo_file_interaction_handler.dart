import 'package:flutter/material.dart';
import 'package:mobile_2/app_config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NooFileInteractionHandler extends StatefulWidget {
  final MediaEntity media;
  final Widget child;
  final Function(bool, double)? onDownloadProgress;

  const NooFileInteractionHandler({
    super.key,
    required this.media,
    required this.child,
    this.onDownloadProgress,
  });

  @override
  State<NooFileInteractionHandler> createState() => _NooFileInteractionHandlerState();
}

class _NooFileInteractionHandlerState extends State<NooFileInteractionHandler> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isDownloading ? null : () => _openFile(context),
      onLongPress: _isDownloading ? null : () => _showShareOptions(context),
      child: widget.child,
    );
  }

  Future<void> _openFile(BuildContext context) async {
    try {
      final uri = Uri.parse(AppConfig.CDN_URL + widget.media.src);
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
    String? filePath;
    try {
      setState(() => _isDownloading = true);
      widget.onDownloadProgress?.call(true, 0.0);

      final fileUrl = AppConfig.CDN_URL + widget.media.src;
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.media.name;
      filePath = '${tempDir.path}/$fileName';

      await Dio().download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            widget.onDownloadProgress?.call(true, progress);
          }
        },
      );

      widget.onDownloadProgress?.call(false, 1.0);

      final file = XFile(filePath);
      await Share.shareXFiles([file], text: widget.media.name);

      // Delete the file after successful sharing
      if (await File(filePath).exists()) {
        await File(filePath).delete();
      }
    } catch (e) {
      // Delete the file if sharing failed
      if (filePath != null && await File(filePath).exists()) {
        await File(filePath).delete();
      }
      widget.onDownloadProgress?.call(false, 0.0);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при отправке файла'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }
}
