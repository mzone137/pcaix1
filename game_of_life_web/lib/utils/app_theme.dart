// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color deepBlue = Color(0xFF0A1929);
  static const Color neonBlue = Color(0xFF40C4FF);
  static const Color matrixGreen = Color(0xFF00FF41);

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 38,
    fontWeight: FontWeight.bold,
    letterSpacing: 3.0,
    height: 1.1,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 14,
    letterSpacing: 2.0,
    color: Colors.white70,
    height: 1.2,
  );

  static const TextStyle menuItemTitleStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.5,
  );

  static const TextStyle menuItemSubtitleStyle = TextStyle(
    fontSize: 12,
    color: Colors.white60,
    letterSpacing: 0.5,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 10,
    color: Colors.white38,
    letterSpacing: 2.0,
  );

  // Decoration
  static BoxDecoration panelDecoration = BoxDecoration(
    color: Colors.black87,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: neonBlue.withOpacity(0.5), width: 1),
    boxShadow: [
      BoxShadow(
        color: neonBlue.withOpacity(0.2),
        blurRadius: 10.0,
        spreadRadius: 1.0,
      ),
    ],
  );

  // Button Style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: neonBlue,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: const TextStyle(
      fontFamily: 'Orbitron',
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    ),
  );
}