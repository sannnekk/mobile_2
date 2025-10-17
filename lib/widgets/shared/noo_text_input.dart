import 'package:flutter/material.dart';

class NooTextInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final bool password;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  const NooTextInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.password = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.focusNode,
    this.onFocusChange,
  });

  @override
  State<NooTextInput> createState() => _NooTextInputState();
}

class _NooTextInputState extends State<NooTextInput> {
  late final TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscure = false;
  bool _ownsFocusNode = false;
  bool _focusListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    if (widget.onFocusChange != null) {
      _attachFocusListener();
    }
    _obscure = widget.password;
  }

  @override
  void didUpdateWidget(NooTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }

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
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _detachFocusListener();
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        if (widget.label != null) const SizedBox(height: 4),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            FormField<String>(
              initialValue: widget.initialValue ?? '',
              validator: widget.validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: (field) {
                final theme = Theme.of(context);
                final baseColor = theme.textTheme.bodyMedium?.color;
                return TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  obscureText: _obscure,
                  style: TextStyle(
                    color: widget.enabled ? baseColor : theme.disabledColor,
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: baseColor?.withOpacity(0.45),
                      fontSize: 15,
                      fontFamily: 'Montserrat',
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.6),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.6),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.6,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.disabledColor.withOpacity(0.4),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.6,
                      ),
                    ),
                    errorText: field.errorText,
                  ),
                  onChanged: (val) {
                    field.didChange(val);
                    widget.onChanged?.call(val);
                  },
                  onSubmitted: widget.onSubmitted,
                  textInputAction: widget.textInputAction,
                );
              },
            ),
            if (widget.password)
              Positioned(
                right: 8,
                child: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).hintColor,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
