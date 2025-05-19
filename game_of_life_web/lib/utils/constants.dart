// utils/constants.dart - Ohne Game of Life Konstanten
import 'package:flutter/material.dart';

class AppConstants {
  // Privater Konstruktor, um Instanziierung zu verhindern
  AppConstants._();

  // App-Informationen
  static const String appTitle = 'Neural Nexus';
  static const String appVersion = '1.0.0';
  static const String appCopyright = '© 2025 NEURAL NEXUS SYSTEMS';

  // Game of Life Konstanten entfernt

  // Word Game Konstanten
  static const Duration sentenceTransitionDelay = Duration(milliseconds: 500);
  static const Duration correctSolutionDisplayTime = Duration(seconds: 2);
  static const Duration wordGameTimerInterval = Duration(milliseconds: 100);

  // Animation Konstanten
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration feedbackAnimationDuration = Duration(milliseconds: 600);
  static const Duration glitchFrequency = Duration(seconds: 3);
  static const Duration glitchDuration = Duration(milliseconds: 200);

  // Layout Konstanten
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double roundedCornerRadius = 12.0;

  // Font-Größen
  static const double fontSizeSmall = 12.0;
  static const double fontSizeDefault = 16.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeLarge = 24.0;
  static const double fontSizeXLarge = 30.0;

  // Asset-Pfade
  static const String backgroundImagePath = 'assets/images/grid_background.jpg';

  // Game of Life Patterns entfernt

  // Route Namen
  static const String routeLanding = '/';
  static const String routeWordGameLevels = '/word-game-levels';
  static const String routeWordGame = '/word-game';
  static const String routeImpressum = '/impressum';
}

/// UI-Komponenten Hilfsmethoden
class AppWidgets {
  // Privater Konstruktor
  AppWidgets._();

  /// Standardisierte Überschrift
  static Widget buildScreenHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppConstants.largePadding,
        bottom: AppConstants.defaultPadding,
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

// Weitere Widget-Builder bleiben unverändert...

  /// Erstellt einen standardisierten Container für Inhalte.
  static Widget buildContentContainer({
    required Widget child,
    Color backgroundColor = Colors.white,
    EdgeInsets? padding,
  }) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  /// Erstellt einen standardisierten Primär-Button.
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: icon != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: AppConstants.smallPadding),
          Text(text),
        ],
      )
          : Text(text),
    );
  }

  /// Erstellt einen standardisierten Loading-Indikator.
  static Widget buildLoadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeDefault,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Erstellt einen standardisierten Fehler-Anzeiger.
  static Widget buildErrorIndicator({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            message,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeDefault,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}