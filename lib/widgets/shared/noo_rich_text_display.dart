import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../embeds/noo_image_embed_builder.dart';
import '../embeds/noo_video_embed_builder.dart';
import '../../core/types/richtext.dart' as rt;

class NooRichTextDisplay extends StatelessWidget {
  final rt.RichText richText;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;

  const NooRichTextDisplay({
    super.key,
    required this.richText,
    this.textStyle,
    this.padding,
    this.scrollController,
  });

  TextStyle _defaultTextStyle(Attribute<dynamic> attribute) {
    final baseStyle = textStyle ?? const TextStyle(height: 1.8);

    if (attribute.key == 'link') {
      return baseStyle.copyWith(decoration: TextDecoration.none);
    }

    return baseStyle;
  }

  @override
  Widget build(BuildContext context) {
    final document = Document.fromDelta(richText.delta);

    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: QuillEditor(
        controller: QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        ),
        scrollController: scrollController ?? ScrollController(),
        focusNode: FocusNode(),
        config: QuillEditorConfig(
          showCursor: false,
          embedBuilders: [
            const NooImageEmbedBuilder(),
            const NooVideoEmbedBuilder(),
          ],
          customStyleBuilder: _defaultTextStyle,
        ),
      ),
    );
  }
}
