import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
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
      child: Column(
        children: [
          if (widget.showToolbar) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.format_bold),
                    onPressed: () =>
                        _controller.formatSelection(Attribute.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_italic),
                    onPressed: () =>
                        _controller.formatSelection(Attribute.italic),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_underline),
                    onPressed: () =>
                        _controller.formatSelection(Attribute.underline),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted),
                    onPressed: () => _controller.formatSelection(Attribute.ul),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_list_numbered),
                    onPressed: () => _controller.formatSelection(Attribute.ol),
                  ),
                  IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: () =>
                        _controller.formatSelection(Attribute.link),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      // Handle image insertion
                      final imageUrl = await _showImageDialog(context);
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        final index = _controller.selection.baseOffset;
                        _controller.document.insert(
                          index,
                          BlockEmbed.image(imageUrl),
                        );
                        _controller.updateSelection(
                          TextSelection.collapsed(offset: index + 1),
                          ChangeSource.local,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.video_camera_back),
                    onPressed: () async {
                      // Handle video insertion
                      final videoUrl = await _showVideoDialog(context);
                      if (videoUrl != null && videoUrl.isNotEmpty) {
                        final index = _controller.selection.baseOffset;
                        _controller.document.insert(
                          index,
                          BlockEmbed.video(videoUrl),
                        );
                        _controller.updateSelection(
                          TextSelection.collapsed(offset: index + 1),
                          ChangeSource.local,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          Expanded(
            child: QuillEditor(
              controller: _controller,
              scrollController: widget.scrollController ?? ScrollController(),
              focusNode: FocusNode(),
              config: QuillEditorConfig(
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showImageDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Image'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter image URL'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showVideoDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Video'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter video URL (YouTube, etc.)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }
}
