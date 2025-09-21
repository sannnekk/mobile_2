import 'package:flutter/material.dart';
import 'package:mobile_2/widgets/shared/noo_button.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

class NooWorkSubmittedModal extends StatefulWidget {
  final Future<void> Function() onViewWork;
  final VoidCallback onReturnToList;

  const NooWorkSubmittedModal({
    super.key,
    required this.onViewWork,
    required this.onReturnToList,
  });

  @override
  State<NooWorkSubmittedModal> createState() => _NooWorkSubmittedModalState();
}

class _NooWorkSubmittedModalState extends State<NooWorkSubmittedModal> {
  bool _isLoadingView = false;

  Future<void> _handleViewWork() async {
    setState(() {
      _isLoadingView = true;
    });

    try {
      await widget.onViewWork();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingView = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              NooTextTitle('Работа сдана', size: NooTitleSize.medium),
              const SizedBox(height: 8),
              NooText(
                'Ваша работа успешно отправлена на проверку.',
                align: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NooButton(
                    label: _isLoadingView ? '' : 'Посмотреть работу',
                    onPressed: _isLoadingView ? null : _handleViewWork,
                    style: NooButtonStyle.secondary,
                    loading: _isLoadingView,
                  ),
                  const SizedBox(height: 12),
                  NooButton(
                    label: 'К списку работ',
                    onPressed: widget.onReturnToList,
                    style: NooButtonStyle.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
