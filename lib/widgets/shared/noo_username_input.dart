import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'noo_text_input.dart';
import 'noo_text.dart';
import '../../core/providers/username_check_provider.dart';

class UsernameInput extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;

  const UsernameInput({
    super.key,
    this.controller,
    this.validator,
    this.enabled = true,
  });

  @override
  ConsumerState<UsernameInput> createState() => _UsernameInputState();
}

class _UsernameInputState extends ConsumerState<UsernameInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onUsernameChanged);
  }

  @override
  void didUpdateWidget(UsernameInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onUsernameChanged);
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onUsernameChanged);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onUsernameChanged);
    }
    super.dispose();
  }

  void _onUsernameChanged() {
    final notifier = ref.read(usernameCheckProvider.notifier);
    notifier.checkUsername(_controller.text);
  }

  String? _combinedValidator(String? value) {
    // First run the custom validator if provided
    final customError = widget.validator?.call(value);
    if (customError != null) return customError;

    // Then check username availability
    final checkState = ref.read(usernameCheckProvider);
    if (checkState.status == UsernameCheckStatus.taken) {
      return 'Этот никнейм уже занят';
    }
    if (checkState.status == UsernameCheckStatus.error) {
      return checkState.error ?? 'Ошибка проверки никнейма';
    }

    return null;
  }

  Widget _buildStatusWidget(UsernameCheckState checkState) {
    switch (checkState.status) {
      case UsernameCheckStatus.checking:
        return Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            NooText('Проверка...', dimmed: true),
          ],
        );
      case UsernameCheckStatus.available:
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            NooText('Никнейм доступен', dimmed: true),
          ],
        );
      case UsernameCheckStatus.taken:
        return Row(
          children: [
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: 8),
            NooText('Никнейм занят', dimmed: true),
          ],
        );
      case UsernameCheckStatus.error:
        return Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: 8),
            NooText(checkState.error ?? 'Ошибка проверки', dimmed: true),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkState = ref.watch(usernameCheckProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NooTextInput(
          controller: _controller,
          label: 'Никнейм',
          validator: _combinedValidator,
          enabled: widget.enabled,
        ),
        if (checkState.status != UsernameCheckStatus.initial &&
            _controller.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _buildStatusWidget(checkState),
          ),
        ],
      ],
    );
  }
}
