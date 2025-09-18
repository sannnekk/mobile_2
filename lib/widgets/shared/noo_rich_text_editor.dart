import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../core/types/richtext.dart' as rt;

class NooRichTextEditor extends StatefulWidget {
  // TODO: Add toolbar support using QuillToolbar.simple when available
  final rt.RichText? initialRichText;
  final Function(rt.RichText)? onChanged;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final bool showToolbar;
  final bool readOnly;

  const NooRichTextEditor({
    super.key,
    this.initialRichText,
    this.onChanged,
    this.textStyle,
    this.padding,
    this.scrollController,
    this.showToolbar = true,
    this.readOnly = false,
  });

  @override
  State<NooRichTextEditor> createState() => _NooRichTextEditorState();
}

class _NooRichTextEditorState extends State<NooRichTextEditor> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    final document = widget.initialRichText != null
        ? Document.fromDelta(widget.initialRichText!.delta)
        : Document();
    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: widget.readOnly,
    );
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(NooRichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRichText != widget.initialRichText) {
      final document = widget.initialRichText != null
          ? Document.fromDelta(widget.initialRichText!.delta)
          : Document();
      _controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: widget.readOnly,
      );
      _controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(rt.RichText.fromDelta(_controller.document.toDelta()));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      child: QuillEditor(
        controller: _controller,
        scrollController: widget.scrollController ?? ScrollController(),
        focusNode: FocusNode(),
      ),
    );
  }
}
