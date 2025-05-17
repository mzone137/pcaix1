// lib/services/audio_service.dart - Mit echter Audio-Implementation

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Ein Service zur Verwaltung von Sound-Effekten im Spiel mit echter Audio-Implementation
/// über das audioplayers-Plugin.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  
  // Haupt-AudioPlayer für Sound-Effekte
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // AudioCache für das Vorladen von Sounds
  final AudioCache _audioCache = AudioCache(prefix: 'assets/sounds/');
  
  // Status für geladene Sounds
  bool _soundsLoaded = false;
  
  factory AudioService() {
    return _instance;
  }
  
  AudioService._internal();
  
  /// Lädt alle Sounds vor, um Latenz während des Spiels zu vermeiden.
  Future<void> preloadSounds() async {
    if (_soundsLoaded) return;
    
    try {
      // Stelle sicher, dass der Pfad korrekt ist und die Dateien existieren
      await _audioCache.loadAll([
        'success.mp3',
        'error.mp3',
        'level_complete.mp3',
        'word_drop.mp3',
        'word_pickup.mp3',
      ]);
      
      _soundsLoaded = true;
      print('Audio assets successfully preloaded!');
    } catch (e) {
      print('Failed to preload audio assets: $e');
      // Fehler beim Laden behandeln, aber App weiter laufen lassen
    }
  }
  
  /// Spielt einen Erfolgs-Sound ab, wenn ein Satz korrekt gelöst wurde.
  /// Dies ist der "epische 16-bit Sound" aus den Anforderungen.
  Future<void> playSuccessSound() async {
    try {
      // Haptisches Feedback für zusätzliche Bestätigung
      HapticFeedback.mediumImpact();
      
      // Stelle sicher, dass die Lautstärke angemessen ist
      await _audioPlayer.setVolume(0.7);
      
      // Spiele den Sound ab
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }
  
  /// Spielt einen Fehler-Sound ab, wenn eine falsche Aktion ausgeführt wird.
  Future<void> playErrorSound() async {
    try {
      HapticFeedback.lightImpact();
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      print('Error playing error sound: $e');
    }
  }
  
  /// Spielt einen Sound ab, wenn ein Kapitel abgeschlossen wurde.
  Future<void> playLevelCompleteSound() async {
    try {
      HapticFeedback.heavyImpact();
      await _audioPlayer.setVolume(0.8);
      await _audioPlayer.play(AssetSource('sounds/level_complete.mp3'));
    } catch (e) {
      print('Error playing level complete sound: $e');
    }
  }
  
  /// Spielt einen Sound ab, wenn ein Wort aufgehoben wird (Drag-Start).
  Future<void> playWordPickupSound() async {
    try {
      HapticFeedback.selectionClick();
      await _audioPlayer.setVolume(0.3);
      await _audioPlayer.play(AssetSource('sounds/word_pickup.mp3'));
    } catch (e) {
      print('Error playing word pickup sound: $e');
    }
  }
  
  /// Spielt einen Sound ab, wenn ein Wort abgelegt wird (Drop).
  Future<void> playWordDropSound() async {
    try {
      await _audioPlayer.setVolume(0.4);
      await _audioPlayer.play(AssetSource('sounds/word_drop.mp3'));
    } catch (e) {
      print('Error playing word drop sound: $e');
    }
  }
  
  /// Setzt alle Audio-Ressourcen frei.
  void dispose() {
    _audioPlayer.dispose();
  }
}