import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_2/core/entities/media.dart';

class NooUploadedImage extends StatelessWidget {
  final MediaEntity? media;
  final double? width;
  final double? height;
  final BoxFit fit;

  const NooUploadedImage({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (media == null || media!.src.isEmpty) {
      return SvgPicture.asset(
        'assets/images/placeholder.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
    }

    return Image.network(
      media!.src,
      width: width,
      height: height,
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
        return SvgPicture.asset(
          'assets/images/placeholder.svg',
          width: width,
          height: height,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
