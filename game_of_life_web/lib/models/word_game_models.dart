// lib/models/word_game_models.dart - Korrigierte Version mit richtiger Klassenstruktur

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

  /// Die randomisierten Wörter des Satzes mit ihren Original-Indizes.
  /// Key: Position im randomisierten Satz
  /// Value: MapEntry mit (Original-Index, Wort)
  late final Map<int, MapEntry<int, String>> randomizedWordsWithIndices;

  /// Mapping von Originalindex zu randomisiertem Index
  late final Map<int, int> _indexMapping;

  /// Umgekehrtes Mapping: von randomisiertem Index zu Originalindex
  late final Map<int, int> _reverseIndexMapping;

  /// Verfolgt die aktuelle Position jedes Wortes im Drag & Drop-Interface.
  /// Key: Die originale Position des Wortes (0-basiert)
  /// Value: Die aktuelle Position im UI (-1 wenn nicht platziert)
  final Map<int, int> _currentPositions = {};

  /// Trackt, welche Zielpositionen bereits belegt sind
  final Set<int> _occupiedTargetPositions = {};

  /// Für den Nummern-Eingabemodus: Speichert die Vermutungen des Nutzers
  late final List<int?> userGuesses;

  WordGameSentence({required this.words}) {
    _randomizeWords();
    _initializePositions();
    // Initialisiere die Nutzereingaben als leere Liste (null-Werte)
    userGuesses = List.filled(words.length, null);
  }

  /// Erstellt einen Satz aus einem Text-String.
  factory WordGameSentence.fromText(String text) {
    // Splitte den Text in Wörter
    final List<String> words = text.split(' ').where((word) => word.isNotEmpty).toList();
    return WordGameSentence(words: words);
  }

  /// Randomisiert die Wörter und erstellt ein Mapping zwischen Originalposition und randomisierter Position
  void _randomizeWords() {
    final random = Random();

    // Erstelle ein Mapping für die Randomisierung
    _indexMapping = {};
    _reverseIndexMapping = {};

    // Liste von originalen Indizes
    List<int> originalIndices = List.generate(words.length, (i) => i);

    // Mische die Indizes für die Anzeige
    originalIndices.shuffle(random);

    // Erzeuge Zahlen-Labels von 1 bis Wortanzahl
    List<int> displayNumbers = List.generate(words.length, (i) => i + 1);

    // Baue die randomisierten Wörter mit ihren Indizes auf
    randomizedWordsWithIndices = {};
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
    return sortedNumbers.join("");
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
    _occupiedTargetPositions.clear();
    _initializePositions();
    // Setze auch die Nutzereingaben zurück
    for (int i = 0; i < userGuesses.length; i++) {
      userGuesses[i] = null;
    }
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

  /// Ändert den Spielmodus (Drag & Drop vs. Zahlen-Eingabe)
  void toggleDragAndDrop(bool value) {
    _useDragAndDrop = value;
    notifyListeners();
  }

  /// Initialisiert das Spiel mit dem Level.
// In lib/models/word_game_models.dart - zur initGame Methode hinzufügen:
  void initGame(WordGameLevel level) {
    _currentLevel = level;
    _currentChapter = level.chapters.isNotEmpty ? level.chapters.first : null;
    _currentSentenceIndex = 0;
    _isGameActive = true;
    _stopwatch.reset();
    _stopwatch.start();

    // Stelle sicher, dass die aktuelle Lösung zurückgesetzt wird
    if (currentSentence != null) {
      currentSentence!.resetSolution();
    }

    notifyListeners();
  }

  /// Prüft eine komplette Zahlensequenz
  bool checkFullSequence(String sequence) {
    if (currentSentence == null) return false;

    bool isCorrect = currentSentence!.checkSequence(sequence);

    if (isCorrect) {
      // Verzögere den Übergang zum nächsten Satz
      Future.delayed(Duration(milliseconds: 500), () {
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
      Future.delayed(Duration(milliseconds: 500), () {
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
      Future.delayed(Duration(milliseconds: 500), () {
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