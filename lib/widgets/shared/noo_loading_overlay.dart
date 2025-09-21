import 'package:flutter/material.dart';
import 'package:mobile_2/widgets/shared/noo_loader.dart';

class NooLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const NooLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: NooLoader(size: 48.0)),
          ),
      ],
    );
  }
}
