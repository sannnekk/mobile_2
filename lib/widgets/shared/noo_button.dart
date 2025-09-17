import 'package:flutter/material.dart';
import '../../styles/colors.dart';

enum NooButtonStyle { primary, secondary, inline, danger }

class NooButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NooButtonStyle style;
  final Widget? icon;
  final bool expanded;
  final bool loading;
  final bool disabled;

  const NooButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = NooButtonStyle.primary,
    this.icon,
    this.expanded = true,
    this.loading = false,
    this.disabled = false,
  });

  Color _backgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (style) {
      case NooButtonStyle.primary:
        return theme.primaryColor;
      case NooButtonStyle.secondary:
        return Colors.transparent;
      case NooButtonStyle.inline:
        return Colors.transparent;
      case NooButtonStyle.danger:
        return AppColors.danger;
    }
  }

  Color _textColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (style) {
      case NooButtonStyle.primary:
        return theme.textTheme.labelMedium?.color ?? Colors.white;
      case NooButtonStyle.secondary:
        return theme.textTheme.labelMedium?.color ?? Colors.black;
      case NooButtonStyle.inline:
        return theme.hintColor;
      case NooButtonStyle.danger:
        return Colors.white;
    }
  }

  BorderSide _borderSide(BuildContext context) {
    final theme = Theme.of(context);
    switch (style) {
      case NooButtonStyle.secondary:
        return BorderSide(color: theme.dividerColor);
      case NooButtonStyle.inline:
        return BorderSide.none;
      default:
        return BorderSide.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _spinner(Color color) => SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );

    final resolvedTextColor = _textColor(context);

    final displayLabel = loading ? '' : label;

    final button = TextButton(
      onPressed: (disabled || loading) ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(_backgroundColor(context)),
        foregroundColor: WidgetStateProperty.all(resolvedTextColor),
        side: WidgetStateProperty.all(_borderSide(context)),
        padding: WidgetStateProperty.all(
          style == NooButtonStyle.inline
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              left: const Radius.circular(160),
              right: const Radius.circular(160),
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading) ...[
            _spinner(resolvedTextColor),
            const SizedBox(width: 8),
          ],
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(
            displayLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: resolvedTextColor,
            ),
          ),
        ],
      ),
    );

    if (!expanded || style == NooButtonStyle.inline) return button;

    return SizedBox(width: double.infinity, child: button);
  }
}
