import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Custom Image EmbedBuilder that shows a loading indicator while the image loads
class NooImageEmbedBuilder extends EmbedBuilder {
  const NooImageEmbedBuilder();

  @override
  String get key => 'image';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final url = _extractUrl(embedContext);
    return _ImageWithLoader(url: url);
  }

  String _extractUrl(EmbedContext embedContext) {
    final data = embedContext.node.value.data;
    if (data is String) return data;
    if (data is Map) {
      // Common keys used by various embed formats
      for (final key in const ['source', 'image', 'url', 'src']) {
        final v = data[key];
        if (v is String && v.isNotEmpty) return v;
      }
    }
    return data?.toString() ?? '';
  }
}

class _ImageWithLoader extends StatelessWidget {
  final String url;
  const _ImageWithLoader({required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle placeholder background while loading
                Positioned.fill(
                  child: Container(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.08,
                    ),
                  ),
                ),
                // Actual image
                Image.network(
                  url,
                  fit: BoxFit.contain,
                  // Show progress while loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    final expected = loadingProgress.expectedTotalBytes;
                    final loaded = loadingProgress.cumulativeBytesLoaded;
                    final value = (expected != null && expected > 0)
                        ? loaded / expected
                        : null;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(value: value),
                        ),
                      ),
                    );
                  },
                  // Graceful error state
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.12),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 28,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image failed to load',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
