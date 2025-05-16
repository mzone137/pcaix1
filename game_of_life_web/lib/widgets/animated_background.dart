// lib/widgets/animated_background.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<DigitalRain> _rains = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate multiple rain columns
    for (int i = 0; i < 40; i++) {
      _rains.add(DigitalRain(
        speed: _random.nextDouble() * 80 + 20,
        xPosition: _random.nextDouble() * 400,
        startOffset: _random.nextDouble() * 2000,
        fontSize: _random.nextDouble() * 14 + 12,
        opacity: _random.nextDouble() * 0.7 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage('assets/images/grid_background.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppTheme.deepBlue.withOpacity(0.7),
            BlendMode.hardLight,
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: DigitalRainPainter(
              rains: _rains,
              animationValue: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class DigitalRain {
  final double speed;
  final double xPosition;
  final double startOffset;
  final double fontSize;
  final double opacity;

  DigitalRain({
    required this.speed,
    required this.xPosition,
    required this.startOffset,
    required this.fontSize,
    required this.opacity,
  });
}

class DigitalRainPainter extends CustomPainter {
  final List<DigitalRain> rains;
  final double animationValue;
  final Random _random = Random();
  final List<String> _matrixChars = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'A', 'B', 'C', 'D', 'E', 'F', 'Φ', 'Ψ', 'Ω', '∑', '∞', '⟨', '⟩'
  ];

  DigitalRainPainter({
    required this.rains,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var rain in rains) {
      final startY = (rain.startOffset - (animationValue * rain.speed * 100)) % (size.height + 500) - 500;

      for (int i = 0; i < 20; i++) {
        final y = startY + (i * rain.fontSize * 1.5);
        if (y < -50 || y > size.height + 50) continue;

        final char = _matrixChars[_random.nextInt(_matrixChars.length)];
        final opacity = rain.opacity * (1 - (i / 20));

        final textPainter = TextPainter(
          text: TextSpan(
            text: char,
            style: TextStyle(
              color: AppTheme.neonBlue.withOpacity(opacity),
              fontSize: rain.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(rain.xPosition % size.width, y),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DigitalRainPainter oldDelegate) {
    return true;
  }
}