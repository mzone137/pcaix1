
// lib/widgets/drag_drop_word_game_widget.dart - Angepasst für randomisierte Wortanordnung

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_game_models.dart';
import '../utils/app_theme.dart';
import '../services/audio_service.dart';
import 'draggable_word_widget.dart';
import 'droppable_word_slot_widget.dart';

class DragDropWordGameWidget extends StatefulWidget {
  final VoidCallback onSolutionCorrect;

  const DragDropWordGameWidget({
    Key? key,
    required this.onSolutionCorrect,
  }) : super(key: key);

  @override
  _DragDropWordGameWidgetState createState() => _DragDropWordGameWidgetState();
}

class _DragDropWordGameWidgetState extends State<DragDropWordGameWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  // Zuordnung von Positionen zu Worten (für die UI-Darstellung)
  Map<int, String> _targetSlots = {};

  // Status der Platzierungen (richtig/falsch)
  Map<int, bool> _placementStatus = {};

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordGameStateModel>(
      builder: (context, gameState, _) {
        final sentence = gameState.currentSentence;

        if (sentence == null) {
          return Center(
            child: Text(
              'No sentence available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Animate when the new sentence is shown
        if (!_controller.isAnimating && _controller.isCompleted) {
          // Reset target slots when a new sentence is loaded
          _targetSlots = {};
          _placementStatus = {};

          _controller.reset();
          _controller.forward();
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.neonBlue.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Anweisungstext
                Text(
                  'Drag words with numbers to arrange them in correct order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Orbitron',
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24),

                // Zielbereich für die Wörter (Drop-Targets)
                Container(
                  height: 80,
                  margin: EdgeInsets.symmetric(vertical: 16),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.neonBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: buildTargetArea(sentence, gameState),
                ),

                // Reset-Button
                TextButton.icon(
                  onPressed: () {
                    _resetTargetSlots();
                    sentence.resetSolution();
                    setState(() {});
                  },
                  icon: Icon(Icons.refresh, color: Colors.white70),
                  label: Text(
                    'Reset',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                SizedBox(height: 16),

                // Quellbereich für die Wörter (Draggables) - RANDOMISIERT
                Expanded(
                  child: buildSourceArea(sentence, gameState),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Reset der Ziel-Slots (für UI-Darstellung)
  void _resetTargetSlots() {
    setState(() {
      _targetSlots = {};
      _placementStatus = {};
    });
  }

  // Baut den Zielbereich auf, wo Wörter abgelegt werden
  Widget buildTargetArea(WordGameSentence sentence, WordGameStateModel gameState) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sentence.words.length,
                (position) {
              // Prüfe, ob an dieser Position bereits ein Wort platziert ist
              String? placedWord;
              int? originalIndex;
              bool isCorrect = true; // Standard: korrekt

              // Suche nach dem Wort, das an dieser Position platziert ist
              for (int i = 0; i < sentence.words.length; i++) {
                if (sentence.isWordPlaced(i) &&
                    _targetSlots.containsKey(position) &&
                    _targetSlots[position] == sentence.words[i]) {
                  placedWord = sentence.words[i];
                  originalIndex = i;
                  // Überprüfe, ob die Position korrekt ist
                  isCorrect = _placementStatus[position] ?? true;
                  break;
                }
              }

              return DroppableWordSlotWidget(
                position: position,
                word: placedWord,
                isCorrect: isCorrect,
                onAccept: (originalWordIndex, targetPosition) {
                  // Aktualisiere das Spielmodell und prüfe, ob die Platzierung korrekt ist
                  final isCorrect = gameState.placeWord(originalWordIndex, targetPosition);

                  // Aktualisiere die UI
                  setState(() {
                    _targetSlots[targetPosition] = sentence.words[originalWordIndex];
                    _placementStatus[targetPosition] = isCorrect;
                  });

                  // Spiele Sound entsprechend dem Ergebnis
                  if (isCorrect) {
                    AudioService().playSuccessSound();
                  } else {
                    AudioService().playErrorSound();
                  }

                  // Prüfe, ob die Lösung korrekt ist
                  if (sentence.isSolutionCorrect()) {
                    // Rufe den Callback auf
                    widget.onSolutionCorrect();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Baut den Quellbereich auf, aus dem Wörter gezogen werden - RANDOMISIERT
  Widget buildSourceArea(WordGameSentence sentence, WordGameStateModel gameState) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Wrap(
          spacing: 8,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: sentence.randomizedWordsWithIndices.entries.map((entry) {
            // Verwende die randomisierte Anordnung
            final int originalIndex = entry.value.key;
            final String word = entry.value.value;
            final int displayNumber = sentence.getDisplayNumberForWord(originalIndex);

            final bool isPlaced = sentence.isWordPlaced(originalIndex);

            return DraggableWordWidget(
              word: word,
              originalIndex: originalIndex,
              randomizedIndex: displayNumber,
              isPlaced: isPlaced,
              onRemove: isPlaced ? () {
                // Entferne das Wort aus dem Zielbereich
                gameState.removeWord(originalIndex);

                // Aktualisiere die UI
                setState(() {
                  // Finde und entferne den Eintrag aus _targetSlots und _placementStatus
                  int? positionToRemove;
                  _targetSlots.forEach((pos, w) {
                    if (w == word) positionToRemove = pos;
                  });

                  if (positionToRemove != null) {
                    _targetSlots.remove(positionToRemove);
                    _placementStatus.remove(positionToRemove);
                  }
                });
              } : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}