// lib/widgets/speed_indicator.dart
import 'package:flutter/material.dart';

class SpeedIndicator extends StatelessWidget {
  final double speedFactor;
  final String title;
  final Color color;

  const SpeedIndicator({
    Key? key,
    required this.speedFactor,
    this.title = 'Speed:',
    this.color = Colors.blueAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$title x${speedFactor.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            _getSpeedIcon(),
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  /// Gibt das passende Icon basierend auf der Geschwindigkeit zurück.
  IconData _getSpeedIcon() {
    if (speedFactor < 0.5) {
      return Icons.slow_motion_video;
    } else if (speedFactor > 2.0) {
      return Icons.speed;
    } else {
      return Icons.play_arrow;
    }
  }
}