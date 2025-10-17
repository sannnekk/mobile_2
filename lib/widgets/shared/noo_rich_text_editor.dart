import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_2/app_config.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/core/providers/media_providers.dart';
import '../embeds/noo_image_embed_builder.dart';
import '../embeds/noo_video_embed_builder.dart';
import '../../core/types/richtext.dart' as rt;

class NooRichTextEditor extends ConsumerStatefulWidget {
  final rt.RichText? initialRichText;
  final Function(rt.RichText)? onChanged;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final bool showToolbar;
  final bool readOnly;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  const NooRichTextEditor({
    super.key,
    this.initialRichText,
    this.onChanged,
    this.textStyle,
    this.padding,
    this.scrollController,
    this.showToolbar = true,
    this.readOnly = false,
    this.focusNode,
    this.onFocusChange,
  });

  @override
  ConsumerState<NooRichTextEditor> createState() => _NooRichTextEditorState();
}

class _NooRichTextEditorState extends ConsumerState<NooRichTextEditor> {
  late QuillController _controller;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _focusListenerAttached = false;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    if (widget.onFocusChange != null) {
      _attachFocusListener();
    }
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
    if (widget.focusNode != oldWidget.focusNode) {
      _detachFocusListener();
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      if (widget.onFocusChange != null) {
        _attachFocusListener();
      }
    } else if (widget.onFocusChange != oldWidget.onFocusChange) {
      if (widget.onFocusChange == null) {
        _detachFocusListener();
      } else if (!_focusListenerAttached) {
        _attachFocusListener();
      }
    }

    if (oldWidget.initialRichText != widget.initialRichText) {
      final newDoc = widget.initialRichText != null
          ? Document.fromDelta(widget.initialRichText!.delta)
          : Document();

      // If content didn't actually change, avoid rebuilding the controller
      final currentDelta = _controller.document.toDelta().toJson();
      final newDelta = newDoc.toDelta().toJson();
      final isSame = _deepJsonEquals(currentDelta, newDelta);
      if (isSame) return;

      final hadFocus = _focusNode.hasFocus;
      final prevSelection = _controller.selection;

      // Clean up old controller
      _controller.removeListener(_onControllerChanged);
      _controller.dispose();

      // Create new controller with preserved selection
      final maxOffset = newDoc.length - 1; // keep within bounds
      final safeOffset = prevSelection.baseOffset.clamp(0, maxOffset);
      _controller = QuillController(
        document: newDoc,
        selection: TextSelection.collapsed(offset: safeOffset),
        readOnly: widget.readOnly,
      );
      _controller.addListener(_onControllerChanged);

      // Restore focus after the frame if it was focused
      if (hadFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusNode.requestFocus();
        });
      }
    }
  }

  void _onControllerChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(rt.RichText.fromDelta(_controller.document.toDelta()));
    }
  }

  @override
  void dispose() {
    _detachFocusListener();
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showToolbar) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_bold),
                      style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all(const Size(20, 20)),
                      ),
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
                      icon: const Icon(Icons.subscript),
                      onPressed: () =>
                          _controller.formatSelection(Attribute.subscript),
                    ),
                    IconButton(
                      icon: const Icon(Icons.superscript),
                      onPressed: () =>
                          _controller.formatSelection(Attribute.superscript),
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_list_numbered),
                      onPressed: () =>
                          _controller.formatSelection(Attribute.ol),
                    ),
                    IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () =>
                          _controller.formatSelection(Attribute.link),
                    ),
                    _isUploading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : PopupMenuButton<_ImageAction>(
                            icon: const Icon(Icons.image),
                            color: Theme.of(context).cardColor,
                            onSelected: (action) async {
                              switch (action) {
                                case _ImageAction.pick:
                                  await _handlePickOrCapture(
                                    ImageSource.gallery,
                                  );
                                  break;
                                case _ImageAction.capture:
                                  await _handlePickOrCapture(
                                    ImageSource.camera,
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: _ImageAction.pick,
                                child: ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Выбрать изображение'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: _ImageAction.capture,
                                child: ListTile(
                                  leading: Icon(Icons.photo_camera),
                                  title: Text('Сделать снимок'),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
          Container(
            padding: widget.padding ?? const EdgeInsets.all(16.0),
            child: QuillEditor(
              controller: _controller,
              scrollController: widget.scrollController ?? ScrollController(),
              focusNode: _focusNode,
              config: QuillEditorConfig(
                minHeight: 200,
                embedBuilders: [
                  const NooImageEmbedBuilder(),
                  const NooVideoEmbedBuilder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _deepJsonEquals(Object? a, Object? b) {
    if (identical(a, b)) return true;
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key)) return false;
        if (!_deepJsonEquals(a[key], b[key])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepJsonEquals(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  Future<void> _handlePickOrCapture(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      setState(() => _isUploading = true);

      final bytes = await picked.readAsBytes();
      final service = await ref.read(mediaServiceProvider.future);
      final resp = await service.uploadImageBytes(bytes, filename: picked.name);

      if (!mounted) return;

      if (resp is ApiSingleResponse<MediaEntity>) {
        final media = resp.data;
        final absoluteUrl = _absoluteCdnUrl(media.src);
        _insertImage(absoluteUrl);
      } else if (resp is ApiErrorResponse) {
        _showSnack(resp.error);
      } else {
        _showSnack('Ошибка при загрузке изображения');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Ошибка при выборе/загрузке изображения');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _insertImage(String url) {
    final selection = _controller.selection;
    final index = selection.baseOffset >= 0
        ? selection.baseOffset
        : _controller.document.length - 1;
    _controller.document.insert(index, BlockEmbed.image(url));
    _controller.updateSelection(
      TextSelection.collapsed(offset: index + 1),
      ChangeSource.local,
    );
  }

  String _absoluteCdnUrl(String src) {
    final base = AppConfig.CDN_URL;
    if (src.isEmpty) return base;
    final needsSlash = !base.endsWith('/') && !src.startsWith('/');
    final doubleSlash = base.endsWith('/') && src.startsWith('/');
    if (needsSlash) return '$base/$src';
    if (doubleSlash) return base + src.substring(1);
    return base + src;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _attachFocusListener() {
    _focusNode.addListener(_handleFocusChange);
    _focusListenerAttached = true;
  }

  void _detachFocusListener() {
    if (_focusListenerAttached) {
      _focusNode.removeListener(_handleFocusChange);
      _focusListenerAttached = false;
    }
  }

  void _handleFocusChange() {
    widget.onFocusChange?.call(_focusNode.hasFocus);
  }
}

enum _ImageAction { pick, capture }
