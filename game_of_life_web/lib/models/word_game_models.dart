// lib/models/word_game_models.dart - Angepasst für Drag & Drop

import 'dart:math';
import 'package:flutter/foundation.dart';

/// Repräsentiert ein Level im Wortspiel mit mehreren Kapiteln.
class WordGameLevel {
  final String id;
  final String title;
  final List<WordGameChapter> chapters;

  WordGameLevel({
    required this.id,
    required this.title,
    required this.chapters,
  });
}

/// Repräsentiert ein Kapitel mit mehreren Sätzen.
class WordGameChapter {
  final String title;
  final List<WordGameSentence> sentences;
  
  // Statistiken
  Duration? completionTime;
  List<Duration> sentenceTimes = [];

  WordGameChapter({
    required this.title,
    required this.sentences,
  });
  
  /// Berechnet die durchschnittliche Zeit pro Satz.
  Duration get averageSentenceTime {
    if (sentenceTimes.isEmpty) return Duration.zero;
    
    final totalMilliseconds = sentenceTimes.fold<int>(
      0, (sum, duration) => sum + duration.inMilliseconds);
    
    return Duration(milliseconds: totalMilliseconds ~/ sentenceTimes.length);
  }
}

/// Repräsentiert einen einzelnen Satz mit seiner Randomisierungslogik.
class WordGameSentence {
  /// Die originalen Wörter des Satzes in korrekter Reihenfolge.
  final List<String> words;
  
  /// Die Wörter mit ihren randomisierten Indizes.
  /// Der Key ist der randomisierte Index, der Value ist das Wort an seiner ursprünglichen Position.
  late final List<MapEntry<int, String>> randomizedWords;
  
  /// Verfolgt die aktuelle Position jedes Wortes im Drag & Drop-Interface.
  /// Key: Die originale Position des Wortes
  /// Value: Die aktuelle Position im UI (-1 wenn nicht platziert)
  final Map<int, int> _currentPositions = {};
  
  /// Trackt, welche Zielpositionen bereits belegt sind
  final Set<int> _occupiedTargetPositions = {};

  WordGameSentence({required this.words}) {
    _randomizeIndices();
    _initializePositions();
  }

  /// Erstellt einen Satz aus einem Text-String.
  factory WordGameSentence.fromText(String text) {
    // Splitte den Text in Wörter
    final List<String> words = text.split(' ').where((word) => word.isNotEmpty).toList();
    return WordGameSentence(words: words);
  }

  /// Randomisiert die Indizes der Wörter, behält aber die Wortreihenfolge bei.
  void _randomizeIndices() {
    // Erstelle eine Liste mit den originalen Indizes (1-basiert)
    final List<int> indices = List.generate(words.length, (i) => i + 1);
    
    // Mische die Indizes mit Fisher-Yates Algorithmus
    final random = Random();
    for (int i = indices.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      // Tausche indices[i] und indices[j]
      int temp = indices[i];
      indices[i] = indices[j];
      indices[j] = temp;
    }
    
    // Erstelle die randomisierten Wörter mit gemischten Indizes
    randomizedWords = List.generate(
      words.length, 
      (i) => MapEntry(indices[i], words[i])
    );
  }
  
  /// Initialisiert die Positionen aller Wörter als "nicht platziert"
  void _initializePositions() {
    for (int i = 0; i < words.length; i++) {
      _currentPositions[i] = -1; // -1 bedeutet "nicht platziert"
    }
  }
  
  /// Platziert ein Wort an einer bestimmten Position im Lösungsbereich
  /// 
  /// [originalIndex] ist der Index des Wortes in der ursprünglichen Wortliste
  /// [targetPosition] ist die Position, an der es im UI platziert wird
  /// 
  /// Gibt zurück, ob die Platzierung erfolgreich war
  bool placeWord(int originalIndex, int targetPosition) {
    // Überprüfe, ob der Zielplatz bereits belegt ist
    if (_occupiedTargetPositions.contains(targetPosition)) {
      return false;
    }
    
    // Wenn das Wort bereits woanders platziert war, entferne es von dort
    int previousPosition = _currentPositions[originalIndex] ?? -1;
    if (previousPosition != -1) {
      _occupiedTargetPositions.remove(previousPosition);
    }
    
    // Platziere das Wort an der neuen Position
    _currentPositions[originalIndex] = targetPosition;
    _occupiedTargetPositions.add(targetPosition);
    
    return true;
  }
  
  /// Entfernt ein Wort aus dem Lösungsbereich und markiert es als nicht platziert
  void removeWord(int originalIndex) {
    int position = _currentPositions[originalIndex] ?? -1;
    if (position != -1) {
      _occupiedTargetPositions.remove(position);
      _currentPositions[originalIndex] = -1;
    }
  }
  
  /// Prüft, ob das Wort bereits platziert wurde
  bool isWordPlaced(int originalIndex) {
    return (_currentPositions[originalIndex] ?? -1) != -1;
  }
  
  /// Prüft, ob die aktuelle Platzierung der Wörter korrekt ist
  bool isSolutionCorrect() {
    // Prüfe, ob alle Wörter platziert wurden
    if (_occupiedTargetPositions.length != words.length) {
      return false;
    }
    
    // Prüfe, ob jedes Wort an der richtigen Position ist
    for (int i = 0; i < words.length; i++) {
      if (_currentPositions[i] != i) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Gibt den Originalsatz als String zurück.
  String get originalText => words.join(' ');
  
  /// Setzt die Lösung zurück
  void resetSolution() {
    _occupiedTargetPositions.clear();
    _initializePositions();
  }
}

/// Verwaltet den Zustand des Wortspiels.
class WordGameStateModel extends ChangeNotifier {
  // Zustandsvariablen
  WordGameLevel? _currentLevel;
  WordGameChapter? _currentChapter;
  int _currentSentenceIndex = 0;
  bool _isGameActive = false;
  
  // Timer-Variablen
  Stopwatch _stopwatch = Stopwatch();
  Duration _lastSentenceTime = Duration.zero;
  
  // Getter
  WordGameLevel? get currentLevel => _currentLevel;
  WordGameChapter? get currentChapter => _currentChapter;
  int get currentSentenceIndex => _currentSentenceIndex;
  bool get isGameActive => _isGameActive;
  Duration get currentTime => _stopwatch.elapsed;
  
  WordGameSentence? get currentSentence {
    if (_currentChapter == null || 
        _currentSentenceIndex >= _currentChapter!.sentences.length) {
      return null;
    }
    return _currentChapter!.sentences[_currentSentenceIndex];
  }
  
  /// Initialisiert das Spiel mit dem Level.
  void initGame(WordGameLevel level) {
    _currentLevel = level;
    _currentChapter = level.chapters.isNotEmpty ? level.chapters.first : null;
    _currentSentenceIndex = 0;
    _isGameActive = true;
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();
  }
  
  /// Prüft, ob ein Wort platziert werden kann und tut dies, wenn möglich
  bool placeWord(int originalWordIndex, int targetPosition) {
    if (currentSentence == null) return false;
    
    bool success = currentSentence!.placeWord(originalWordIndex, targetPosition);
    if (success) {
      notifyListeners();
      
      // Wenn die Lösung korrekt ist, automatisch zum nächsten Satz gehen
      if (currentSentence!.isSolutionCorrect()) {
        // Verzögerung, um dem Nutzer Zeit zu geben, die korrekte Lösung zu sehen
        Future.delayed(Duration(milliseconds: 500), () {
          moveToNextSentence();
        });
        return true;
      }
    }
    return success;
  }
  
  /// Entfernt ein Wort aus dem Lösungsbereich
  void removeWord(int originalWordIndex) {
    if (currentSentence != null) {
      currentSentence!.removeWord(originalWordIndex);
      notifyListeners();
    }
  }
  
  /// Prüft, ob die aktuelle Lösung korrekt ist
  bool checkSolution() {
    return currentSentence?.isSolutionCorrect() ?? false;
  }
  
  /// Wechselt zum nächsten Satz oder Kapitel.
  void moveToNextSentence() {
    if (_currentChapter == null) return;
    
    // Speichere die Zeit für den aktuellen Satz
    _lastSentenceTime = _stopwatch.elapsed;
    _currentChapter!.sentenceTimes.add(_lastSentenceTime);
    
    // Setze Timer zurück
    _stopwatch.reset();
    _stopwatch.start();
    
    // Erhöhe den Satz-Index
    _currentSentenceIndex++;
    
    // Prüfe, ob das Kapitel abgeschlossen ist
    if (_currentSentenceIndex >= _currentChapter!.sentences.length) {
      _completeChapter();
    }
    
    if (currentSentence != null) {
      currentSentence!.resetSolution();
    }
    
    notifyListeners();
  }
  
  /// Schließt das aktuelle Kapitel ab und speichert Statistiken.
  void _completeChapter() {
    if (_currentChapter != null) {
      _stopwatch.stop();
      _currentChapter!.completionTime = _stopwatch.elapsed;
    }
    
    // Hier könnte Code zum Speichern der Statistiken in SharedPreferences oder ähnlichem stehen
    
    _isGameActive = false;
    notifyListeners();
  }
  
  /// Wechselt zu einem bestimmten Kapitel.
  void selectChapter(WordGameChapter chapter) {
    _currentChapter = chapter;
    _currentSentenceIndex = 0;
    _stopwatch.reset();
    _stopwatch.start();
    _isGameActive = true;
    notifyListeners();
  }
  
  /// Setzt das Spiel zurück zur Level-Auswahl.
  void resetGame() {
    _currentLevel = null;
    _currentChapter = null;
    _currentSentenceIndex = 0;
    _isGameActive = false;
    _stopwatch.stop();
    _stopwatch.reset();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}