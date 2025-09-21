import 'package:flutter/material.dart';

class NooLoader extends StatefulWidget {
  final double? size;

  const NooLoader({super.key, this.size = 24.0});

  @override
  State<NooLoader> createState() => _NooLoaderState();
}

class _NooLoaderState extends State<NooLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Create staggered animations for multiple dots
    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2, // Stagger start times
            (index * 0.2) + 0.6, // Duration of each animation
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? const Color(0xFF9D96FF)
        : const Color(0xFFCDC9FF);
    final dotColor = isDark ? Colors.white : Colors.white;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LoaderPainter(
              animations: _animations,
              primaryColor: primaryColor,
              dotColor: dotColor,
            ),
          );
        },
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final Color primaryColor;
  final Color dotColor;

  _LoaderPainter({
    required this.animations,
    required this.primaryColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw animated dots
    for (int i = 0; i < animations.length; i++) {
      final animation = animations[i];
      final progress = animation.value;

      // Calculate position - dots move from top to bottom
      final y =
          size.height *
          (0.2 + progress * 0.6); // Move from 20% to 80% of height
      final x = center.dx + (i - 1) * (size.width * 0.2); // Spread horizontally

      final dotPaint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;

      // Vary dot sizes
      final dotRadius =
          size.width * (0.05 + (i * 0.02)); // Different sizes for each dot
      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LoaderPainter oldDelegate) {
    return true; // Always repaint as animations change
  }
}
