import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/widgets/shared/noo_uploaded_image.dart';

class NooParallaxHeader extends StatefulWidget {
  final ScrollController controller;
  final double height;
  final MediaEntity media;
  final Widget child;
  final double contentOverlap; // How much the content overlaps the image

  const NooParallaxHeader({
    super.key,
    required this.controller,
    required this.height,
    required this.media,
    required this.child,
    this.contentOverlap = 0.0, // Default no overlap
  });

  @override
  State<NooParallaxHeader> createState() => _ParallaxHeaderState();
}

class _ParallaxHeaderState extends State<NooParallaxHeader> {
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateOffset);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateOffset);
    super.dispose();
  }

  void _updateOffset() {
    setState(() {
      _offset = widget.controller.offset * 0.5; // Parallax factor
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, -_offset),
          child: SizedBox(
            height: widget.height,
            child: NooUploadedImage(
              media: widget.media,
              fit: BoxFit.cover,
              height: widget.height,
              width: double.infinity,
            ),
          ),
        ),
        SingleChildScrollView(
          controller: widget.controller,
          child: Column(
            children: [
              SizedBox(height: widget.height - widget.contentOverlap),
              widget.child,
            ],
          ),
        ),
      ],
    );
  }
}
