import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'noo_video_platform.dart';

/// Custom Video EmbedBuilder that renders iframe on web and clickable opener on other platforms
class NooVideoEmbedBuilder extends EmbedBuilder {
  const NooVideoEmbedBuilder();

  @override
  String get key => 'video';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final url = _extractUrl(embedContext);
    if (url.isEmpty) {
      final theme = Theme.of(context);
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.12,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        alignment: Alignment.center,
        child: Text('Invalid video URL', style: theme.textTheme.bodySmall),
      );
    }
    return NooVideoView(url: url);
  }

  String _extractUrl(EmbedContext embedContext) {
    final data = embedContext.node.value.data;
    if (data is String) return data;
    if (data is Map) {
      for (final key in const ['source', 'video', 'url', 'src']) {
        final v = data[key];
        if (v is String && v.isNotEmpty) return v;
      }
    }
    return '';
  }
}
