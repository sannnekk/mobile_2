import 'package:flutter/material.dart';
import 'package:mobile_2/app_config.dart';
import 'package:mobile_2/core/entities/media.dart';

class NooUploadedImage extends StatelessWidget {
  final MediaEntity? media;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? aspectRatio;

  const NooUploadedImage({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (media == null || media!.src.isEmpty) {
      content = Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
    } else {
      content = Image.network(
        AppConfig.CDN_URL + media!.src,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder.png',
            fit: BoxFit.contain,
          );
        },
      );
    }

    if (width != null) {
      content = SizedBox(width: width, child: content);
    }
    if (height != null && aspectRatio == null) {
      content = SizedBox(height: height, child: content);
    }
    if (aspectRatio != null) {
      content = AspectRatio(aspectRatio: aspectRatio!, child: content);
    }

    return content;
  }
}
