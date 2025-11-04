import 'dart:ui' as ui;
// Required import for web to use IFrameElement
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show IFrameElement;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NooVideoView extends StatefulWidget {
  final String url;
  const NooVideoView({super.key, required this.url});

  @override
  State<NooVideoView> createState() => _NooVideoViewState();
}

class _NooVideoViewState extends State<NooVideoView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    // Register a unique view type for the iframe
    _viewType = 'noo-video-view-${UniqueKey()}';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int id) {
      final element = IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..allow =
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
        ..allowFullscreen = true
        ..style.border = '0';

      // Helps YouTube avoid 153 errors by providing a compatible referrer policy.
      element.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
      element.referrerPolicy = 'strict-origin-when-cross-origin';
      element.src = widget.url;
      return element;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
