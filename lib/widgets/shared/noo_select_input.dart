import 'package:flutter/material.dart';

class NooSelectInput<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const NooSelectInput({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<NooSelectInput<T>> createState() => _NooSelectInputState<T>();
}

class _NooSelectInputState<T> extends State<NooSelectInput<T>> {
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
        FormField<T>(
          initialValue: widget.value,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (field) {
            final theme = Theme.of(context);
            final baseColor = theme.textTheme.bodyMedium?.color;

            return DropdownButtonFormField<T>(
              value: widget.value,
              items: widget.items,
              onChanged: widget.enabled
                  ? (value) {
                      field.didChange(value);
                      widget.onChanged?.call(value);
                    }
                  : null,
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
              style: TextStyle(
                color: widget.enabled ? baseColor : theme.disabledColor,
                fontSize: 15,
                fontFamily: 'Montserrat',
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: widget.enabled ? baseColor : theme.disabledColor,
              ),
              dropdownColor: theme.cardColor,
            );
          },
        ),
      ],
    );
  }
}
