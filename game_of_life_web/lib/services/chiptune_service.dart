// lib/services/chiptune_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

// Enum für die verschiedenen Tracks
enum ChiptuneTrack {
  zelda,
  pokemon,
  onePiece,
}

class ChiptuneService extends ChangeNotifier {
  static final ChiptuneService _instance = ChiptuneService._internal();

  // AudioPlayer für die Hintergrundmusik
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Track-Informationen
  ChiptuneTrack _currentTrack = ChiptuneTrack.zelda;
  bool _isPlaying = false;
  double _volume = 0.5;

  // Track-Namen zur Anzeige
  final Map<ChiptuneTrack, String> trackNames = {
    ChiptuneTrack.zelda: 'Zelda Theme',
    ChiptuneTrack.pokemon: 'Pokemon Battle',
    ChiptuneTrack.onePiece: 'One Piece Main',
  };

  // Track-Dateipfade
  final Map<ChiptuneTrack, String> _trackPaths = {
    ChiptuneTrack.zelda: 'music/zelda_theme.mp3',
    ChiptuneTrack.pokemon: 'music/pokemon_battle.mp3',
    ChiptuneTrack.onePiece: 'music/one_piece_main.mp3',
  };

  // Getter
  ChiptuneTrack get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;

  factory ChiptuneService() {
    return _instance;
  }

  ChiptuneService._internal() {
    // Initialisierung
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Musik in Schleife abspielen
    _audioPlayer.setVolume(_volume);

    // Event-Listener für Ende des Tracks
    _audioPlayer.onPlayerComplete.listen((_) {
      nextTrack(); // Automatisch zum nächsten Track
    });
  }

  // Lädt alle Musik-Dateien vor
  Future<void> preloadMusic() async {
    try {
      // Hier könnte man alle Tracks vorladen
      print('Music assets preloaded!');
    } catch (e) {
      print('Failed to preload music assets: $e');
    }
  }

  // Startet oder pausiert die Wiedergabe
  void togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _playCurrentTrack();
    }

    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  // Wechselt zum nächsten Track
  void nextTrack() async {
    // Zyklischer Wechsel zum nächsten Track
    final values = ChiptuneTrack.values;
    final nextIndex = (values.indexOf(_currentTrack) + 1) % values.length;
    _currentTrack = values[nextIndex];

    if (_isPlaying) {
      await _playCurrentTrack();
    }

    notifyListeners();
  }

  // Stellt die Lautstärke ein
  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  // Spielt den aktuellen Track ab
  Future<void> _playCurrentTrack() async {
    final path = _trackPaths[_currentTrack];
    if (path != null) {
      await _audioPlayer.play(AssetSource(path));
    }
  }

  // Cleanup-Ressourcen
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}