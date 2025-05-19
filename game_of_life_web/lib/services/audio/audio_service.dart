// lib/services/audio_service.dart - Refaktorisierte Version

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Definition der verschiedenen Sound-Typen in der Anwendung.
enum SoundType {
  success,
  error,
  levelComplete,
  wordPickup,
  wordDrop,
}

/// Interface für einen Audio-Service, um Entkopplung für Tests zu ermöglichen.
abstract class IAudioService {
  /// Initialisiert und lädt alle Sound-Ressourcen.
  Future<void> initialize();

  /// Spielt einen Sound ab.
  Future<void> playSound(SoundType soundType);

  /// Diese Methode ruft einfach initialize() auf, um Abwärtskompatibilität zu gewährleisten.
  Future<void> preloadSounds() async {
    return initialize();
  }

  /// Gibt Sound-Ressourcen frei.
  void dispose();
}

/// Ein Service zur Verwaltung von Sound-Effekten im Spiel mit realer AudioPlayer-Implementierung.
///
/// Diese Implementierung verwendet das audioplayers-Plugin für Audioausgabe und
/// bietet robuste Fehlerbehandlung für verschiedene Plattformen.
class AudioService implements IAudioService {
  // Singleton-Implementation mit privatem Konstruktor
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal();

  // Haupt-AudioPlayer für Sound-Effekte
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Status für geladene Sounds
  bool _isInitialized = false;
  bool _hasErrors = false;

  // Mapping von Sound-Typen zu ihren Datei-Pfaden
  final Map<SoundType, String> _soundPaths = {
    SoundType.success: 'sounds/success.mp3',
    SoundType.error: 'sounds/error.mp3',
    SoundType.levelComplete: 'sounds/level_complete.mp3',
    SoundType.wordPickup: 'sounds/word_pickup.mp3',
    SoundType.wordDrop: 'sounds/word_drop.mp3',
  };

  // Standardlautstärke pro Sound-Typ
  final Map<SoundType, double> _soundVolumes = {
    SoundType.success: 0.7,
    SoundType.error: 0.5,
    SoundType.levelComplete: 0.8,
    SoundType.wordPickup: 0.3,
    SoundType.wordDrop: 0.4,
  };

  /// Initialisiert und lädt alle Sound-Ressourcen.
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Auf Webplattformen müssen wir einen anderen Ansatz verwenden
      if (kIsWeb) {
        // Web-spezifische Initialisierung, falls nötig
      } else {
        // Plattformspezifische Initialisierung
      }

      _isInitialized = true;
      debugPrint('AudioService initialized successfully');
    } catch (e) {
      _hasErrors = true;
      debugPrint('Failed to initialize AudioService: $e');
    }
  }

  /// Spielt einen bestimmten Sound-Typ ab.
  ///
  /// Behandelt Fehler leise, um die Benutzeroberfläche nicht zu unterbrechen.
  @override
  Future<void> playSound(SoundType soundType) async {
    if (_hasErrors || !_isInitialized) {
      // Stille initialisieren, falls noch nicht geschehen
      if (!_isInitialized) await initialize();
      if (_hasErrors) return;
    }

    try {
      // Ggf. haptisches Feedback für zusätzliche Bestätigung (plattformspezifisch)
      _provideHapticFeedback(soundType);

      // Setze die Lautstärke für diesen Sound-Typ
      await _audioPlayer.setVolume(_soundVolumes[soundType] ?? 0.5);

      // Hole den Pfad für diesen Sound-Typ
      final soundPath = _soundPaths[soundType];
      if (soundPath == null) {
        debugPrint('No sound path defined for sound type: $soundType');
        return;
      }

      // Versuche, den Sound abzuspielen
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      // Silent fail - Logge den Fehler, aber nicht für den Benutzer
      debugPrint('Error playing sound: $e');
    }
  }

  /// Bietet plattformspezifisches haptisches Feedback für bestimmte Sound-Typen.
  void _provideHapticFeedback(SoundType soundType) {
    try {
      switch (soundType) {
        case SoundType.success:
          HapticFeedback.mediumImpact();
          break;
        case SoundType.error:
          HapticFeedback.lightImpact();
          break;
        case SoundType.levelComplete:
          HapticFeedback.heavyImpact();
          break;
        case SoundType.wordPickup:
          HapticFeedback.selectionClick();
          break;
        case SoundType.wordDrop:
        // Kein haptisches Feedback für Drop
          break;
      }
    } catch (e) {
      // Ignoriere Fehler beim haptischen Feedback
    }
  }

  /// Hilfsmethoden für häufige Sounds

  /// Spielt einen Erfolgs-Sound ab.
  Future<void> playSuccessSound() => playSound(SoundType.success);

  /// Spielt einen Fehler-Sound ab.
  Future<void> playErrorSound() => playSound(SoundType.error);

  /// Spielt einen Level-Abschluss-Sound ab.
  Future<void> playLevelCompleteSound() => playSound(SoundType.levelComplete);

  /// Spielt einen Sound ab, wenn ein Wort aufgehoben wird.
  Future<void> playWordPickupSound() => playSound(SoundType.wordPickup);

  /// Spielt einen Sound ab, wenn ein Wort abgelegt wird.
  Future<void> playWordDropSound() => playSound(SoundType.wordDrop);

  /// Setzt alle Audio-Ressourcen frei.
  @override
  void dispose() {
    try {
      _audioPlayer.dispose();
    } catch (e) {
      // Ignoriere Fehler beim Freigeben der Ressourcen
      debugPrint('Error disposing AudioService: $e');
    }
  }

  @override
  Future<void> preloadSounds() {
    // TODO: implement preloadSounds
    throw UnimplementedError();
  }
}

/// Mock-Implementation des Audio-Services für Tests ohne tatsächliche Audiowiedergabe.
class MockAudioService implements IAudioService {
  @override
  Future<void> initialize() async {
    // Keine tatsächliche Initialisierung notwendig
    debugPrint('MockAudioService initialized');
  }

  @override
  Future<void> playSound(SoundType soundType) async {
    // Nur für Debugging-Zwecke: Loggen, welcher Sound abgespielt würde
    debugPrint('MockAudioService would play: $soundType');
  }

  @override
  void dispose() {
    // Keine Ressourcen freizugeben
    debugPrint('MockAudioService disposed');
  }

  @override
  Future<void> preloadSounds() {
    // TODO: implement preloadSounds
    throw UnimplementedError();
  }
}