import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import '../embeds/noo_image_embed_builder.dart';
import '../embeds/noo_video_embed_builder.dart';
import '../../core/types/richtext.dart' as rt;
import 'package:mobile_2/styles/colors.dart';

class NooRichTextDisplay extends StatefulWidget {
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

  @override
  State<NooRichTextDisplay> createState() => _NooRichTextDisplayState();
}

class _NooRichTextDisplayState extends State<NooRichTextDisplay> {
  late QuillController _controller;
  final GlobalKey _editorKey = GlobalKey();
  ScrollController? _ownedScrollController;

  ScrollController get _scrollController =>
      widget.scrollController ??
      (_ownedScrollController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document.fromDelta(widget.richText.delta),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  void didUpdateWidget(covariant NooRichTextDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.richText.toJson().toString() !=
        widget.richText.toJson().toString()) {
      _controller.dispose();
      _controller = QuillController(
        document: Document.fromDelta(widget.richText.delta),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ownedScrollController?.dispose();
    super.dispose();
  }

  Color _commentColor(String? type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (type == null) {
      return isDark ? AppDarkColors.primary : AppColors.lila;
    }
    final lower = type.toLowerCase();
    if (lower == 'logic') {
      return isDark ? AppDarkColors.warning : AppColors.warning;
    }
    if (lower == 'fact') {
      return isDark ? AppDarkColors.danger : AppColors.danger;
    }
    if (type.isNotEmpty && (type[0] == 'k' || type[0] == 'K')) {
      return isDark ? AppDarkColors.secondary : AppColors.secondary;
    }
    return isDark ? AppDarkColors.primary : AppColors.lila;
  }

  TextStyle _defaultTextStyle(Attribute<dynamic> attribute) {
    final baseStyle = widget.textStyle ?? const TextStyle(height: 1.8);

    if (attribute.key == 'link') {
      return baseStyle.copyWith(decoration: TextDecoration.none);
    }
    if (attribute.key == 'comment') {
      String? type;
      final value = attribute.value;
      if (value is Map) {
        final t = value['type'];
        if (t is String) type = t;
      }
      final color = _commentColor(type);
      return baseStyle.copyWith(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dashed,
        decorationColor: color,
        decorationThickness: 3,
      );
    }

    return baseStyle;
  }

  Map<String, dynamic>? _commentAtDocOffset(int docOffset) {
    Map<String, dynamic>? fromStyleAt(int offset) {
      final doc = _controller.document;
      if (offset < 0) return null;
      final max = doc.length;
      if (max == 0) return null;
      final clamped = offset >= max ? max - 1 : offset;
      final style = doc.collectStyle(clamped, 1);
      final attr = style.attributes['comment'];
      final val = attr?.value;
      if (val is Map) return Map<String, dynamic>.from(val);
      return null;
    }

    // Try exact offset and a few neighbors to handle edge taps
    final candidates = <int>{
      docOffset,
      docOffset - 1,
      docOffset + 1,
      docOffset - 2,
      docOffset + 2,
    };
    for (final c in candidates) {
      final res = fromStyleAt(c);
      if (res != null) return res;
    }
    return null;
  }

  String getCommentTitle(String type) {
    if (type.isEmpty) return 'Комментарий';
    final lower = type.toLowerCase();
    if (lower == 'logic') return 'Логическая ошибка';
    if (lower == 'fact') return 'Фактическая ошибка';
    if (type[0] == 'k' || type[0] == 'K') return type;

    return 'Комментарий';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _editorKey,
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      child: QuillEditor(
        controller: _controller,
        scrollController: _scrollController,
        focusNode: FocusNode(),
        config: QuillEditorConfig(
          showCursor: false,
          embedBuilders: const [NooImageEmbedBuilder(), NooVideoEmbedBuilder()],
          customStyleBuilder: _defaultTextStyle,
          onTapDown: (details, getPosition) {
            final pos = getPosition(details.globalPosition);
            final comment = _commentAtDocOffset(pos.offset);
            if (comment != null) {
              final type = comment['type']?.toString() ?? 'Комментарий';
              final content = comment['content']?.toString() ?? '-';
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: NooTextTitle(
                    getCommentTitle(type),
                    color: _commentColor(type),
                  ),
                  content: Text(content),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Закрыть'),
                    ),
                  ],
                ),
              );
              return true; // handled
            }

            return false; // let quill handle other taps normally
          },
        ),
      ),
    );
  }
}

// End of file
