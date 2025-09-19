import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_uploaded_image.dart';
import 'package:mobile_2/widgets/shared/noo_file_interaction_handler.dart';
import 'package:mobile_2/styles/colors.dart';

class NooFileCard extends StatefulWidget {
  final MediaEntity media;

  const NooFileCard({super.key, required this.media});

  @override
  State<NooFileCard> createState() => _FileCardState();
}

class _FileCardState extends State<NooFileCard> {
  @override
  Widget build(BuildContext context) {
    final isImage = _isImageFile(widget.media.src);
    final isPdf = widget.media.src.contains('pdf');

    return NooFileInteractionHandler(
      media: widget.media,
      child: NooCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // File preview/icon
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NooUploadedImage(
                  media: widget.media,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              )
            else if (isPdf)
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/pdf-file.svg',
                    height: 40,
                    width: 40,
                  ),
                ),
              )
            else
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.insert_drive_file, size: 40),
                ),
              ),

            const SizedBox(width: 12),

            // File name - takes remaining space
            Expanded(child: NooText(widget.media.name)),
          ],
        ),
      ),
    );
  }

  bool _isImageFile(String? src) {
    if (src == null) return false;
    return src.contains('png') || src.contains('jpg') || src.contains('jpeg');
  }
}
