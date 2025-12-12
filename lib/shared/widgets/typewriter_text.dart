import 'package:flutter/material.dart';
import 'dart:async';

/// A widget that displays text with a typewriter effect
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final bool repeat;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 100),
    this.repeat = false,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    _timer?.cancel();
    _currentIndex = 0;
    _displayedText = '';

    if (widget.text.isNotEmpty) {
      _timer = Timer.periodic(widget.speed, (timer) {
        if (mounted && _currentIndex < widget.text.length) {
          setState(() {
            _displayedText = widget.text.substring(0, _currentIndex + 1);
            _currentIndex++;
          });
        } else {
          timer.cancel();
          widget.onComplete?.call();

          if (widget.repeat) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                _startTypewriter();
              }
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}
