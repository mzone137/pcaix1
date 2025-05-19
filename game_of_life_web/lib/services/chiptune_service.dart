// lib/services/chiptune_service.dart - Refaktorisierte Version

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Definition der verfügbaren Musik-Tracks in der Anwendung.
enum ChiptuneTrack {
  zelda,
  pokemon,
  onePiece,
}

/// Interface für den Chiptune-Service, um Entkopplung für Tests zu ermöglichen.
abstract class IChiptuneService extends ChangeNotifier {
  /// Der aktuell ausgewählte Track.
  ChiptuneTrack get currentTrack;

  /// Gibt an, ob die Musik gerade abgespielt wird.
  bool get isPlaying;

  /// Die aktuelle Lautstärke (0.0 - 1.0).
  double get volume;

  /// Gibt den Namen des aktuellen Tracks zurück.
  String get currentTrackName;

  /// Startet oder pausiert die Wiedergabe.
  void togglePlayback();

  /// Wechselt zum nächsten Track.
  void nextTrack();

  /// Stellt die Lautstärke ein (0.0 - 1.0).
  void setVolume(double volume);

  /// Wechselt zu einem bestimmten Track.
  void selectTrack(ChiptuneTrack track);
}

/// Implementierung des Chiptune-Services mit realer Audio-Wiedergabe.
class ChiptuneService extends ChangeNotifier implements IChiptuneService {
  // Singleton-Implementierung
  static final ChiptuneService _instance = ChiptuneService._internal();

  factory ChiptuneService() => _instance;

  ChiptuneService._internal() {
    _initializePlayer();
  }

  // AudioPlayer für die Hintergrundmusik
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Track-Informationen
  ChiptuneTrack _currentTrack = ChiptuneTrack.zelda;
  bool _isPlaying = false;
  double _volume = 0.5;
  bool _hasErrors = false;
  bool _isInitialized = false;

  // Track-Namen zur Anzeige
  final Map<ChiptuneTrack, String> _trackNames = {
    ChiptuneTrack.zelda: 'Zelda Theme',
    ChiptuneTrack.pokemon: 'Pokemon Battle',
    ChiptuneTrack.onePiece: 'One Piece Main',
  };

  /// Getter für die Track-Namen
  Map<ChiptuneTrack, String> get trackNames => _trackNames;

  // Track-Dateipfade
  final Map<ChiptuneTrack, String> _trackPaths = {
    ChiptuneTrack.zelda: 'music/zelda_theme.mp3',
    ChiptuneTrack.pokemon: 'music/pokemon_battle.mp3',
    ChiptuneTrack.onePiece: 'music/one_piece_main.mp3',
  };

  // Getter-Implementierungen
  @override
  ChiptuneTrack get currentTrack => _currentTrack;

  @override
  bool get isPlaying => _isPlaying;

  @override
  double get volume => _volume;

  @override
  String get currentTrackName => _trackNames[_currentTrack] ?? 'Unknown Track';

  /// Initialisiert den AudioPlayer und setzt die grundlegenden Eigenschaften.
  void _initializePlayer() {
    try {
      // Initialisiere den AudioPlayer für Looping
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _audioPlayer.setVolume(_volume);

      // Event-Listener für Ende des Tracks
      _audioPlayer.onPlayerComplete.listen((_) {
        if (!_hasErrors) {
          nextTrack(); // Automatisch zum nächsten Track
        }
      });

      _isInitialized = true;
      debugPrint('ChiptuneService initialized successfully');
    } catch (e) {
      _hasErrors = true;
      debugPrint('Error initializing ChiptuneService: $e');
    }
  }

  /// Initialisiert den Service, wenn er noch nicht initialisiert wurde.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _initializePlayer();
  }

  @override
  void togglePlayback() async {
    if (_hasErrors) {
      _isPlaying = !_isPlaying;
      notifyListeners();
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _playCurrentTrack();
      }

      _isPlaying = !_isPlaying;
      notifyListeners();
    } catch (e) {
      // Ändere den Status trotzdem, damit das UI reagiert
      _isPlaying = !_isPlaying;
      debugPrint('Error toggling playback: $e');
      notifyListeners();
    }
  }

  @override
  void nextTrack() async {
    // Zyklischer Wechsel zum nächsten Track
    final values = ChiptuneTrack.values;
    final nextIndex = (values.indexOf(_currentTrack) + 1) % values.length;
    _currentTrack = values[nextIndex];

    if (_isPlaying && !_hasErrors) {
      try {
        await _playCurrentTrack();
      } catch (e) {
        debugPrint('Error playing next track: $e');
      }
    }

    notifyListeners();
  }

  @override
  void selectTrack(ChiptuneTrack track) async {
    if (_currentTrack == track) return;

    _currentTrack = track;

    if (_isPlaying && !_hasErrors) {
      try {
        await _playCurrentTrack();
      } catch (e) {
        debugPrint('Error playing selected track: $e');
      }
    }

    notifyListeners();
  }

  @override
  void setVolume(double volume) {
    // Stell sicher, dass die Lautstärke zwischen 0.0 und 1.0 liegt
    _volume = volume.clamp(0.0, 1.0);

    if (!_hasErrors) {
      try {
        _audioPlayer.setVolume(_volume);
      } catch (e) {
        debugPrint('Error setting volume: $e');
      }
    }

    notifyListeners();
  }

  /// Spielt den aktuellen Track ab.
  Future<void> _playCurrentTrack() async {
    if (_hasErrors) return;

    final path = _trackPaths[_currentTrack];
    if (path == null) {
      debugPrint('No track path defined for: $_currentTrack');
      return;
    }

    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('Error playing track: $e');
      _hasErrors = true;
    }
  }

  /// Gibt alle Ressourcen frei.
  @override
  void dispose() {
    try {
      _audioPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing ChiptuneService: $e');
    }
    super.dispose();
  }
}

/// Mock-Implementierung des Chiptune-Services für Tests.
class MockChiptuneService extends ChangeNotifier implements IChiptuneService {
  ChiptuneTrack _currentTrack = ChiptuneTrack.zelda;
  bool _isPlaying = false;
  double _volume = 0.5;

  @override
  ChiptuneTrack get currentTrack => _currentTrack;

  @override
  bool get isPlaying => _isPlaying;

  @override
  double get volume => _volume;

  @override
  String get currentTrackName => 'Mock ${_currentTrack.name}';

  @override
  void togglePlayback() {
    _isPlaying = !_isPlaying;
    debugPrint('MockChiptuneService: toggled playback to $_isPlaying');
    notifyListeners();
  }

  @override
  void nextTrack() {
    final values = ChiptuneTrack.values;
    final nextIndex = (values.indexOf(_currentTrack) + 1) % values.length;
    _currentTrack = values[nextIndex];
    debugPrint('MockChiptuneService: switched to next track $_currentTrack');
    notifyListeners();
  }

  @override
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    debugPrint('MockChiptuneService: set volume to $_volume');
    notifyListeners();
  }

  @override
  void selectTrack(ChiptuneTrack track) {
    _currentTrack = track;
    debugPrint('MockChiptuneService: selected track $_currentTrack');
    notifyListeners();
  }
}