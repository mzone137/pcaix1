// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Neue Farben
  static const Color creamBackground = Color(0xFFF5F5F0);  // Creme-weißer Hintergrund
  static const Color primaryText = Color(0xFF1A1A1A);      // Fast-Schwarz für Text
  static const Color primaryAccent = Color(0xFF3D7AB3);    // Blauer Akzent (dezenter als zuvor)
  static const Color secondaryAccent = Color(0xFF4A7B42);

  // Colors
  static const Color deepBlue = Color(0xFF0A1929);
  static const Color neonBlue = Color(0xFF40C4FF);
  static const Color matrixGreen = Color(0xFF00FF41);

  // Text Styles aktualisiert
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 38,
    fontWeight: FontWeight.bold,
    letterSpacing: 3.0,
    height: 1.1,
    color: primaryText, // Schwarz statt weiß
  );


  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 14,
    letterSpacing: 2.0,
    color: Color(0xFF404040), // Dunkelgrau statt weiß
    height: 1.2,
  );


  static const TextStyle menuItemTitleStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryText, // Schwarz statt weiß
    letterSpacing: 1.5,
  );

  static const TextStyle menuItemSubtitleStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF505050), // Dunkelgrau statt weiß
    letterSpacing: 0.5,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 10,
    color: Color(0xFF606060), // Grau statt weiß
    letterSpacing: 2.0,
  );

  // Dekoration aktualisiert
  static BoxDecoration panelDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: primaryAccent.withOpacity(0.5), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10.0,
        spreadRadius: 1.0,
      ),
    ],
  );

  // Button Style aktualisiert
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryAccent,
    foregroundColor: Colors.white, // Weiß auf blau für guten Kontrast
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

  // Neue Drawer-spezifische Stile
  static BoxDecoration drawerHeaderDecoration = BoxDecoration(
    color: primaryAccent.withOpacity(0.1),
    border: Border(
      bottom: BorderSide(
        color: primaryAccent.withOpacity(0.2),
        width: 1.0,
      ),
    ),
  );

  static TextStyle drawerHeaderTextStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryAccent,
    letterSpacing: 2.0,
  );

  static TextStyle drawerItemTextStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 16,
    color: primaryText,
    letterSpacing: 1.0,
  );
}