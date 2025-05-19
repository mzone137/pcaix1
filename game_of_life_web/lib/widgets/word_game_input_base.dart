// lib/widgets/word_game_input_base.dart - Neue abstrakte Basisklasse für Eingabe-Widgets

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/word_game_models.dart';
import '../services/audio/audio_service.dart';
import '../utils/constants.dart';

/// Abstrakte Basisklasse für Word Game Eingabe-Widgets.
///
/// Diese Klasse dient als Basis für verschiedene Eingabemethoden im Word Game,
/// wie Drag & Drop oder Nummerneingabe. Sie bietet gemeinsame Funktionalität
/// und eine einheitliche API für die verschiedenen Eingabevarianten.
abstract class WordGameInputBase extends StatefulWidget {
  /// Wird aufgerufen, wenn die Lösung korrekt ist.
  final VoidCallback onSolutionCorrect;

  const WordGameInputBase({
    Key? key,
    required this.onSolutionCorrect,
  }) : super(key: key);
}

/// Abstrakte Basisklasse für den State von Word Game Eingabe-Widgets.
abstract class WordGameInputBaseState<T extends WordGameInputBase> extends State<T> {
  /// Referenz zum Audio-Service für Soundeffekte.
  final AudioService audioService = AudioService();

  /// Tracking-Variable für den aktuellen Satz, um Änderungen zu erkennen.
  String? _currentSentenceId;

  /// Der aktuelle Index des Satzes.
  int _currentSentenceIndex = -1;

  /// Gibt an, ob die aktuelle Lösung korrekt ist.
  bool? _isCorrect;

  /// Getter für den Korrektheits-Status.
  bool? get isCorrect => _isCorrect;

  /// Setter für den Korrektheits-Status.
  set isCorrect(bool? value) {
    setState(() {
      _isCorrect = value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final gameState = Provider.of<WordGameStateModel>(context, listen: false);
    _checkForSentenceChange(gameState);
  }

  /// Überprüft, ob sich der aktuelle Satz geändert hat und setzt ggf. den State zurück.
  ///
  /// [gameState] ist der aktuelle Spielzustand.
  void _checkForSentenceChange(WordGameStateModel gameState) {
    final sentence = gameState.currentSentence;
    final currentIndex = gameState.currentSentenceIndex;

    if (sentence == null) return;

    // Erstelle eine eindeutige ID für diesen Satz
    final newSentenceId = "${sentence.originalText}-$currentIndex";

    // Wenn sich der Satz geändert hat, setze den State zurück
    if (_currentSentenceId != newSentenceId || _currentSentenceIndex != currentIndex) {
      resetState();

      setState(() {
        _currentSentenceId = newSentenceId;
        _currentSentenceIndex = currentIndex;
        _isCorrect = null;
      });
    }
  }

  /// Behandelt eine korrekte Lösung.
  ///
  /// Spielt den Erfolgs-Sound, setzt den State zurück und ruft den Callback auf.
  void handleCorrectSolution() {
    setState(() {
      _isCorrect = true;
    });

    // Spiele Erfolgs-Sound ab
    audioService.playSuccessSound();

    // Verzögerung für visuelles Feedback
    Future.delayed(AppConstants.correctSolutionDisplayTime, () {
      if (mounted) {
        widget.onSolutionCorrect();
        resetState();
      }
    });
  }

  /// Behandelt eine falsche Lösung.
  ///
  /// Spielt den Fehler-Sound und markiert die Lösung als falsch.
  void handleIncorrectSolution() {
    setState(() {
      _isCorrect = false;
    });

    // Spiele Fehler-Sound ab
    audioService.playErrorSound();
  }

  /// Setzt den Zustand des Widgets zurück.
  ///
  /// Diese Methode muss von abgeleiteten Klassen implementiert werden, um
  /// ihren spezifischen Zustand zurückzusetzen.
  void resetState();

  /// Erstellt das Content-Widget des Input-Widgets.
  ///
  /// Diese Methode muss von abgeleiteten Klassen implementiert werden, um
  /// ihr spezifisches UI zu erstellen.
  ///
  /// [sentence] ist der aktuelle Satz.
  /// [gameState] ist der aktuelle Spielzustand.
  Widget buildContent(WordGameSentence sentence, WordGameStateModel gameState);

  @override
  Widget build(BuildContext context) {
    return Consumer<WordGameStateModel>(
      builder: (context, gameState, _) {
        final sentence = gameState.currentSentence;

        // Überprüfe, ob ein Satz verfügbar ist
        if (sentence == null) {
          return AppWidgets.buildErrorIndicator(
            message: 'No sentence available',
          );
        }

        // Überprüfe, ob sich der Satz geändert hat
        _checkForSentenceChange(gameState);

        // Erstelle das Widget mit einheitlichem Container
        return AppWidgets.buildContentContainer(
          child: Column(
            children: [
              // Anweisungstext
              buildInstructionText(),

              SizedBox(height: AppConstants.defaultPadding),

              // Hauptinhalt des Widgets (von abgeleiteten Klassen implementiert)
              Expanded(
                child: buildContent(sentence, gameState),
              ),

              // Reset-Button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    resetState();
                    sentence.resetSolution();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Erstellt den Anweisungstext für das Widget.
  ///
  /// Kann von abgeleiteten Klassen überschrieben werden, um einen
  /// spezifischen Anweisungstext zu erstellen.
  Widget buildInstructionText() {
    return const Text(
      'Arrange the words in the correct order',
      style: TextStyle(
        fontSize: AppConstants.fontSizeMedium,
        fontFamily: 'Orbitron',
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    // Hier könnten zusätzliche Bereinigungsaktionen stattfinden
    super.dispose();
  }
}