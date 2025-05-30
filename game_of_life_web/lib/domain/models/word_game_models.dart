// lib/domain/models/word_game_models.dart - Refaktorisierte Version

import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../utils/constants.dart';

/// Status eines WordGame-Kapitels
enum ChapterStatus {
  /// Kapitel ist noch nicht begonnen oder zurückgesetzt
  notStarted,

  /// Kapitel ist gerade in Bearbeitung
  inProgress,

  /// Kapitel wurde abgeschlossen
  completed
}

/// Repräsentiert ein Level im Wortspiel mit mehreren Kapiteln.
class WordGameLevel {
  /// Eindeutige ID des Levels
  final String id;

  /// Anzeigename des Levels
  final String title;

  /// Liste der Kapitel in diesem Level
  final List<WordGameChapter> chapters;

  WordGameLevel({
    required this.id,
    required this.title,
    required this.chapters,
  });

  /// Berechnet den Fortschritt durch das Level (0.0 - 1.0)
  double calculateProgress() {
    if (chapters.isEmpty) return 0.0;

    int completedChapters = chapters
        .where((chapter) => chapter.status == ChapterStatus.completed)
        .length;

    return completedChapters / chapters.length;
  }

  /// Gibt an, ob das Level vollständig abgeschlossen ist
  bool get isCompleted => chapters.every(
          (chapter) => chapter.status == ChapterStatus.completed);

  /// Gibt das nächste nicht abgeschlossene Kapitel zurück oder null, wenn alle abgeschlossen sind
  WordGameChapter? get nextUncompletedChapter {
    for (var chapter in chapters) {
      if (chapter.status != ChapterStatus.completed) {
        return chapter;
      }
    }
    return null;
  }
}

/// Repräsentiert ein Kapitel mit mehreren Sätzen.
class WordGameChapter {
  /// Titel des Kapitels
  final String title;

  /// Liste der Sätze in diesem Kapitel
  final List<WordGameSentence> sentences;

  /// Status des Kapitels
  ChapterStatus _status = ChapterStatus.notStarted;

  /// Statistiken
  Duration? completionTime;
  List<Duration> sentenceTimes = [];

  // Getter und Setter
  ChapterStatus get status => _status;

  set status(ChapterStatus value) {
    _status = value;
  }

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

  /// Gibt den Fortschritt im Kapitel an (0.0 - 1.0)
  double calculateSentenceProgress(int currentSentenceIndex) {
    if (sentences.isEmpty) return 0.0;
    return currentSentenceIndex / sentences.length;
  }

  /// Setzt das Kapitel komplett zurück
  void reset() {
    completionTime = null;
    sentenceTimes.clear();
    _status = ChapterStatus.notStarted;

    // Alle Sätze im Kapitel zurücksetzen
    for (var sentence in sentences) {
      sentence.resetSolution();
    }
  }

  /// Speichert einen Zeitwert für einen abgeschlossenen Satz
  void recordSentenceTime(Duration time) {
    sentenceTimes.add(time);
  }

  /// Speichert die Gesamtzeit für den Abschluss des Kapitels
  void complete(Duration totalTime) {
    completionTime = totalTime;
    _status = ChapterStatus.completed;
  }

  /// Startet das Kapitel
  void start() {
    if (_status == ChapterStatus.notStarted) {
      _status = ChapterStatus.inProgress;
    }
  }
}

/// Repräsentiert einen einzelnen Satz mit seiner Randomisierungslogik.
class WordGameSentence {
  /// Die originalen Wörter des Satzes in korrekter Reihenfolge.
  final List<String> words;

  /// Die randomisierten Wörter des Satzes mit ihren Original-Indizes.
  /// Key: Position im randomisierten Satz
  /// Value: MapEntry mit (Original-Index, Wort)
  Map<int, MapEntry<int, String>> randomizedWordsWithIndices = {};

  /// Mapping von Originalindex zu randomisiertem Index
  Map<int, int> _indexMapping = {};

  /// Umgekehrtes Mapping: von randomisiertem Index zu Originalindex
  Map<int, int> _reverseIndexMapping = {};

  /// Verfolgt die aktuelle Position jedes Wortes im Drag & Drop-Interface.
  /// Key: Die originale Position des Wortes (0-basiert)
  /// Value: Die aktuelle Position im UI (-1 wenn nicht platziert)
  final Map<int, int> _currentPositions = {};

  /// Trackt, welche Zielpositionen bereits belegt sind
  final Set<int> _occupiedTargetPositions = {};

  /// Für den Nummern-Eingabemodus: Speichert die Vermutungen des Nutzers
  List<int?> userGuesses = [];

  /// Random-Generator für konsistente Zufälligkeit
  final Random _random;

  WordGameSentence({required this.words, Random? random})
      : _random = random ?? Random() {
    // Initialisiere die Nutzereingaben als leere Liste (null-Werte)
    userGuesses = List.filled(words.length, null);
    // Initialisiere die Wortpositionen
    _initializePositions();
    // Randomisiere die Wörter für das erste Mal
    _randomizeWords();
  }

  /// Erstellt einen Satz aus einem Text-String.
  factory WordGameSentence.fromText(String text, {Random? random}) {
    // Splitte den Text in Wörter
    final List<String> words = text.split(' ')
        .where((word) => word.isNotEmpty).toList();
    return WordGameSentence(words: words, random: random);
  }

  /// Randomisiert die Wörter und erstellt ein Mapping zwischen Originalposition und randomisierter Position
  void _randomizeWords() {
    // Leere die vorhandenen Mappings anstatt sie neu zu initialisieren
    _indexMapping.clear();
    _reverseIndexMapping.clear();
    randomizedWordsWithIndices.clear();

    // Liste von originalen Indizes
    List<int> originalIndices = List.generate(words.length, (i) => i);

    // Mische die Indizes für die Anzeige
    originalIndices.shuffle(_random);

    // Erzeuge Zahlen-Labels von 1 bis Wortanzahl
    List<int> displayNumbers = List.generate(words.length, (i) => i + 1);

    // Baue die randomisierten Wörter mit ihren Indizes auf
    for (int i = 0; i < words.length; i++) {
      int originalIndex = originalIndices[i];
      int displayNumber = displayNumbers[i];

      // Speichere das Mapping von Original-Index zu Anzeigenummer
      _indexMapping[originalIndex] = displayNumber;
      _reverseIndexMapping[displayNumber] = originalIndex;

      // Speichere das randomisierte Wort mit Original-Index und Anzeige-Position
      randomizedWordsWithIndices[i] = MapEntry(originalIndex, words[originalIndex]);
    }
  }

  /// Gibt den angezeigten Zahlen-Label für ein Wort an der Originalposition zurück
  int getDisplayNumberForWord(int originalPosition) {
    return _indexMapping[originalPosition] ?? -1;
  }

  /// Gibt für eine angezeigte Nummer den Originalindex des Wortes zurück
  int getOriginalIndexForDisplayNumber(int displayNumber) {
    return _reverseIndexMapping[displayNumber] ?? -1;
  }

  /// Gibt die korrekte Zahlensequenz zurück, die der Benutzer eingeben muss
  String getCorrectSequence() {
    // Sortiere die Wörter nach Originalindex
    List<int> sortedNumbers = [];
    for (int i = 0; i < words.length; i++) {
      // Finde die Anzeigenummer für den originalen Index
      sortedNumbers.add(_indexMapping[i] ?? -1);
    }
    return sortedNumbers.join('');
  }

  /// Überprüft, ob eine eingegebene Zahlensequenz korrekt ist
  bool checkSequence(String sequence) {
    return sequence == getCorrectSequence();
  }

  /// Initialisiert die Positionen aller Wörter als "nicht platziert"
  void _initializePositions() {
    for (int i = 0; i < words.length; i++) {
      _currentPositions[i] = -1; // -1 bedeutet "nicht platziert"
    }
    _occupiedTargetPositions.clear();
  }

  /// Platziert ein Wort an einer bestimmten Position im Lösungsbereich
  ///
  /// [originalIndex] ist der Index des Wortes in der ursprünglichen Wortliste
  /// [targetPosition] ist die Position, an der es im UI platziert wird
  ///
  /// Gibt zurück, ob die Platzierung korrekt ist (true = richtige Position)
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

    // Prüfe, ob die Position korrekt ist (Originalindex = Zielposition)
    return targetPosition == originalIndex;
  }

  /// Prüft die Nummer für eine bestimmte Position
  ///
  /// [position] ist die Position im UI (0-basiert)
  /// [guessedNumber] ist die geratene Zahl (1-basiert randomisierter Index)
  ///
  /// Gibt zurück, ob die Eingabe korrekt ist
  bool checkNumberGuess(int position, int guessedNumber) {
    // Finde das Original-Wort an dieser Position
    for (int i = 0; i < words.length; i++) {
      if (_indexMapping[i] == guessedNumber) {
        // Speichere die Vermutung des Benutzers
        userGuesses[position] = guessedNumber;

        // Ist die Position korrekt? (Originalindex sollte der Position entsprechen)
        return i == position;
      }
    }

    return false; // Keine passende Zahl gefunden
  }

  /// Entfernt ein Wort aus dem Lösungsbereich und markiert es als nicht platziert
  void removeWord(int originalIndex) {
    int position = _currentPositions[originalIndex] ?? -1;
    if (position != -1) {
      _occupiedTargetPositions.remove(position);
      _currentPositions[originalIndex] = -1;
    }
  }

  /// Entfernt die Vermutung des Nutzers an einer bestimmten Position (für den Zahlen-Eingabemodus)
  void removeNumberGuess(int position) {
    userGuesses[position] = null;
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

  /// Prüft, ob alle Zahlen korrekt eingegeben wurden (für den Zahlen-Eingabemodus)
  bool isNumberInputCorrect() {
    // Prüfe, ob alle Felder ausgefüllt sind
    if (userGuesses.contains(null)) {
      return false;
    }

    // Prüfe, ob jede Position die richtige Zahl hat
    for (int i = 0; i < words.length; i++) {
      final correctIndex = i;
      final correctRandomizedNumber = _indexMapping[correctIndex] ?? -1;

      if (userGuesses[i] != correctRandomizedNumber) {
        return false;
      }
    }

    return true;
  }

  /// Gibt den Originalsatz als String zurück.
  String get originalText => words.join(' ');

  /// Setzt die Lösung zurück
  void resetSolution() {
    // Zurücksetzen der Platzierungen
    _occupiedTargetPositions.clear();
    _initializePositions();

    // Setze auch die Nutzereingaben zurück
    for (int i = 0; i < userGuesses.length; i++) {
      userGuesses[i] = null;
    }

    // Randomisiere die Wörter neu
    _randomizeWords();
  }
}

/// Verwaltet den Zustand des Wortspiels.
class WordGameStateModel extends ChangeNotifier {
  // Zustandsvariablen
  WordGameLevel? _currentLevel;
  WordGameChapter? _currentChapter;
  int _currentSentenceIndex = 0;
  bool _isGameActive = false;

  // Toggle für Drag & Drop vs. Zahlen-Eingabe-Modus
  bool _useDragAndDrop = false; // Standard: Zahlen-Eingabe-Modus

  // Timer-Variablen
  Stopwatch _stopwatch = Stopwatch();
  Duration _lastSentenceTime = Duration.zero;

  // Callbacks
  VoidCallback? _onChapterCompleted;
  VoidCallback? _onLevelCompleted;

  // Getter
  WordGameLevel? get currentLevel => _currentLevel;
  WordGameChapter? get currentChapter => _currentChapter;
  int get currentSentenceIndex => _currentSentenceIndex;
  bool get isGameActive => _isGameActive;
  Duration get currentTime => _stopwatch.elapsed;
  bool get useDragAndDrop => _useDragAndDrop;

  WordGameSentence? get currentSentence {
    if (_currentChapter == null ||
        _currentSentenceIndex >= _currentChapter!.sentences.length) {
      return null;
    }
    return _currentChapter!.sentences[_currentSentenceIndex];
  }

  /// Registriert einen Callback für den Abschluss eines Kapitels
  void setOnChapterCompleted(VoidCallback callback) {
    _onChapterCompleted = callback;
  }

  /// Registriert einen Callback für den Abschluss eines Levels
  void setOnLevelCompleted(VoidCallback callback) {
    _onLevelCompleted = callback;
  }

  /// Ändert den Spielmodus (Drag & Drop vs. Zahlen-Eingabe)
  void toggleDragAndDrop(bool value) {
    _useDragAndDrop = value;
    notifyListeners();
  }

  /// Initialisiert das Spiel mit dem Level.
  void initGame(WordGameLevel level) {
    _currentLevel = level;

    // Sicherstellen, dass jedes Kapitel zurückgesetzt ist
    for (var chapter in level.chapters) {
      chapter.reset();
    }

    _currentChapter = level.chapters.isNotEmpty ? level.chapters.first : null;
    _currentSentenceIndex = 0; // Start bei 0 für korrekte Zählung
    _isGameActive = true;
    _stopwatch.reset();
    _stopwatch.start();

    // Stelle sicher, dass die aktuelle Lösung zurückgesetzt wird
    if (currentSentence != null) {
      currentSentence!.resetSolution();
    }

    // Setze den Status des Kapitels auf "in Bearbeitung"
    if (_currentChapter != null) {
      _currentChapter!.start();
    }

    notifyListeners();
  }

  /// Prüft eine komplette Zahlensequenz
  bool checkFullSequence(String sequence) {
    if (currentSentence == null) return false;

    bool isCorrect = currentSentence!.checkSequence(sequence);

    if (isCorrect) {
      // Verzögere den Übergang zum nächsten Satz
      Future.delayed(AppConstants.sentenceTransitionDelay, () {
        moveToNextSentence();
      });
    }

    return isCorrect;
  }

  /// Prüft, ob ein Wort platziert werden kann und tut dies, wenn möglich
  bool placeWord(int originalWordIndex, int targetPosition) {
    if (currentSentence == null) return false;

    bool isCorrect = currentSentence!.placeWord(originalWordIndex, targetPosition);
    notifyListeners();

    // Prüfe, ob die gesamte Lösung korrekt ist (alle Worte am richtigen Platz)
    if (currentSentence!.isSolutionCorrect()) {
      // Verzögerung, um dem Nutzer Zeit zu geben, die korrekte Lösung zu sehen
      Future.delayed(AppConstants.sentenceTransitionDelay, () {
        moveToNextSentence();
      });
    }

    return isCorrect;
  }

  /// Überprüft eine Zahleneingabe für eine bestimmte Position (Zahlen-Eingabemodus)
  bool checkNumberInput(int position, int number) {
    if (currentSentence == null) return false;

    bool isCorrect = currentSentence!.checkNumberGuess(position, number);
    notifyListeners();

    // Prüfe, ob alle Zahlen korrekt eingegeben wurden
    if (currentSentence!.isNumberInputCorrect()) {
      // Verzögerung, um dem Nutzer Zeit zu geben, die korrekte Lösung zu sehen
      Future.delayed(AppConstants.sentenceTransitionDelay, () {
        moveToNextSentence();
      });
    }

    return isCorrect;
  }

  /// Entfernt eine Zahleneingabe (Zahlen-Eingabemodus)
  void removeNumberInput(int position) {
    if (currentSentence != null) {
      currentSentence!.removeNumberGuess(position);
      notifyListeners();
    }
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
    _currentChapter!.recordSentenceTime(_lastSentenceTime);

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
      _currentChapter!.complete(_stopwatch.elapsed);

      // Rufe den Callback auf, wenn vorhanden
      if (_onChapterCompleted != null) {
        _onChapterCompleted!();
      }

      // Prüfe, ob das Level komplett ist
      if (_currentLevel != null && _currentLevel!.isCompleted) {
        if (_onLevelCompleted != null) {
          _onLevelCompleted!();
        }
      }
    }

    // Hier könnte Code zum Speichern der Statistiken stehen

    _isGameActive = false;
    notifyListeners();
  }

  /// Wechselt zu einem bestimmten Kapitel.
  void selectChapter(WordGameChapter chapter) {
    _currentChapter = chapter;
    _currentSentenceIndex = 0; // Starte immer bei 0

    // Setze das Kapitel nur zurück, wenn es noch nicht abgeschlossen ist
    if (chapter.status != ChapterStatus.completed) {
      chapter.reset();
      chapter.start();
    }

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

  /// Setzt das aktuelle Kapitel zurück und startet es neu.
  void restartCurrentChapter() {
    if (_currentChapter == null) return;

    _currentChapter!.reset();
    _currentChapter!.start();
    _currentSentenceIndex = 0;
    _stopwatch.reset();
    _stopwatch.start();
    _isGameActive = true;

    if (currentSentence != null) {
      currentSentence!.resetSolution();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}