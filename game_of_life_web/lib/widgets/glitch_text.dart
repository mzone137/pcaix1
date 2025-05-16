// lib/widgets/glitch_text.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration glitchFrequency;
  final Duration glitchDuration;

  const GlitchText(
      this.text, {
        Key? key,
        required this.style,
        this.glitchFrequency = const Duration(seconds: 3),
        this.glitchDuration = const Duration(milliseconds: 200),
      }) : super(key: key);

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> {
  String _currentText = '';
  bool _isGlitching = false;
  Timer? _frequencyTimer;
  Timer? _glitchTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentText = widget.text;
    _startGlitchTimer();
  }

  @override
  void dispose() {
    _frequencyTimer?.cancel();
    _glitchTimer?.cancel();
    super.dispose();
  }

  void _startGlitchTimer() {
    _frequencyTimer = Timer.periodic(widget.glitchFrequency, (_) {
      if (!mounted) return;
      _triggerGlitch();
    });
  }

  void _triggerGlitch() {
    setState(() {
      _isGlitching = true;
      _currentText = _generateGlitchedText();
    });

    _glitchTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentText = _generateGlitchedText();
      });

      if (timer.tick > widget.glitchDuration.inMilliseconds ~/ 50) {
        timer.cancel();
        setState(() {
          _isGlitching = false;
          _currentText = widget.text;
        });
      }
    });
  }

  String _generateGlitchedText() {
    if (!_isGlitching) return widget.text;

    final glitchChars = '!@#\$%^&*()_+-={}[]|;:,.<>?/~`ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final result = StringBuffer();

    for (int i = 0; i < widget.text.length; i++) {
      if (_random.nextDouble() < 0.2) {
        // Replace with a random character from our glitch set
        result.write(glitchChars[_random.nextInt(glitchChars.length)]);
      } else {
        // Keep the original character
        result.write(widget.text[i]);
      }
    }

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.lightBlue.shade200,
            Colors.white,
          ],
        ).createShader(bounds);
      },
      child: Stack(
        children: [
          // Base text
          Text(
            _currentText,
            style: widget.style,
            textAlign: TextAlign.center,
          ),

          // Glitch effect layer (conditional)
          if (_isGlitching)
            Positioned(
              left: _random.nextDouble() * 4 - 2,
              top: _random.nextDouble() * 4 - 2,
              child: Text(
                _currentText,
                style: widget.style.copyWith(
                  color: Colors.red.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),

          if (_isGlitching)
            Positioned(
              left: _random.nextDouble() * 4 - 2,
              top: _random.nextDouble() * 4 - 2,
              child: Text(
                _currentText,
                style: widget.style.copyWith(
                  color: Colors.lightBlue.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}