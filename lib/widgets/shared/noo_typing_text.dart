import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// A smooth typing animation widget that cycles through a list of messages
class NooTypingText extends StatefulWidget {
  /// List of messages to cycle through
  final List<String> messages;

  /// Base typing speed in milliseconds per character
  final Duration baseTypingSpeed;

  /// Pause duration between messages
  final Duration pauseDuration;

  /// Text style for the displayed text
  final TextStyle? style;

  /// Whether to show cursor
  final bool showCursor;

  /// Cursor blink interval
  final Duration cursorBlinkInterval;

  const NooTypingText({
    super.key,
    required this.messages,
    this.baseTypingSpeed = const Duration(milliseconds: 80),
    this.pauseDuration = const Duration(seconds: 3),
    this.style,
    this.showCursor = true,
    this.cursorBlinkInterval = const Duration(
      milliseconds: 800,
    ), // Slower, less aggressive blinking
  });

  @override
  State<NooTypingText> createState() => _NooTypingTextState();
}

class _NooTypingTextState extends State<NooTypingText>
    with TickerProviderStateMixin {
  late AnimationController _cursorController;
  late Animation<double> _cursorOpacity;

  late Timer _messageTimer;
  String _displayedText = '';
  int _currentMessageIndex = 0;
  int _currentCharIndex = 0;
  bool _isTyping = true;

  // For more natural typing with variable speed
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    assert(widget.messages.isNotEmpty, 'Messages list cannot be empty');

    _cursorController = AnimationController(
      vsync: this,
      duration: widget.cursorBlinkInterval,
    );

    _cursorOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _cursorController,
        curve: Curves.easeInOutCubic,
      ), // Smoother curve
    );

    _cursorController.addStatusListener(_onCursorAnimationComplete);
    _startCursorBlinking();
    _startTyping();
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _messageTimer.cancel();
    super.dispose();
  }

  void _startCursorBlinking() {
    if (widget.showCursor) {
      _cursorController.forward();
    }
  }

  void _onCursorAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _cursorController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _cursorController.forward();
    }
  }

  void _startTyping() {
    _messageTimer = Timer.periodic(_getTypingSpeed(), _onTypingTick);
  }

  Duration _getTypingSpeed() {
    // Add some randomness for more natural typing feel
    final variation = _random.nextInt(40) - 20; // -20 to +20 ms variation
    final baseMs = widget.baseTypingSpeed.inMilliseconds;
    return Duration(milliseconds: max(30, baseMs + variation));
  }

  void _onTypingTick(Timer timer) {
    if (!mounted) return;

    final currentMessage = widget.messages[_currentMessageIndex];

    if (_isTyping) {
      if (_currentCharIndex < currentMessage.length) {
        setState(() {
          _displayedText = currentMessage.substring(0, _currentCharIndex + 1);
          _currentCharIndex++;
        });

        // Update timer with new random speed for next character
        _messageTimer.cancel();
        _messageTimer = Timer.periodic(_getTypingSpeed(), _onTypingTick);
      } else {
        // Finished typing, start pause
        _isTyping = false;
        _messageTimer.cancel();

        // Smooth transition to next message
        Future.delayed(widget.pauseDuration, _moveToNextMessage);
      }
    }
  }

  void _moveToNextMessage() {
    if (!mounted) return;

    // Add a brief pause before starting the next message to reduce flashing
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        _currentMessageIndex =
            (_currentMessageIndex + 1) % widget.messages.length;
        _currentCharIndex = 0;
        _displayedText = '';
        _isTyping = true;
      });

      _startTyping();
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 16,
      fontFamily: 'Montserrat',
      color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
      height: 1.4,
    );

    final textStyle = widget.style ?? defaultStyle;

    return Container(
      constraints: const BoxConstraints(minHeight: 24), // Dynamic height
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Main text
              Text(
                _displayedText,
                textAlign: TextAlign.center,
                style: textStyle,
                softWrap: true,
                maxLines: null,
              ),
              // Cursor positioned after text
              if (widget.showCursor)
                Positioned(
                  left: _calculateCursorPosition(context, textStyle),
                  top: 0,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: _cursorOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _cursorOpacity.value,
                        child: Text(
                          '|',
                          style: textStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _calculateCursorPosition(BuildContext context, TextStyle style) {
    if (_displayedText.isEmpty) return 0;

    final textPainter = TextPainter(
      text: TextSpan(text: _displayedText, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    return textPainter.width;
  }
}
