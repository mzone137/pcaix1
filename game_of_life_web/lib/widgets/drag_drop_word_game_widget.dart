// lib/widgets/drag_drop_word_game_widget.dart - Bugfixes für Zurücksetzungsprobleme

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
  // Key: Position im UI, Value: Tuple aus (Originalindex, Wort, Korrektheit)
  Map<int, (int, String, bool)> _placedWords = {};

  // Referenz zum aktuellen Satz, um Änderungen zu erkennen
  String? _currentSentenceId;
  int _lastSentenceIndex = -1;

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
        final currentSentenceIndex = gameState.currentSentenceIndex;

        if (sentence == null) {
          return Center(
            child: Text(
              'No sentence available',
              style: TextStyle(color: AppTheme.primaryText),
            ),
          );
        }

        // Generiere eine eindeutige ID für den aktuellen Satz
        final sentenceId = "${sentence.originalText}-$currentSentenceIndex";

        // Überprüfe, ob sich der Satz geändert hat oder der Index geändert hat
        if (_currentSentenceId != sentenceId || _lastSentenceIndex != currentSentenceIndex) {
          // Neuer Satz oder Index geladen, setze den Zustand zurück
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _placedWords = {};
                _currentSentenceId = sentenceId;
                _lastSentenceIndex = currentSentenceIndex;

                // Stelle auch sicher, dass die Wörter im Spielmodell zurückgesetzt sind
                sentence.resetSolution();
              });

              // Starte die Animation neu
              _controller.reset();
              _controller.forward();
            }
          });
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
              color: Colors.white, // Heller Hintergrund
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryAccent.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Anweisungstext
                Text(
                  'Drag words with numbers to arrange them in correct order',
                  style: TextStyle(
                    color: AppTheme.primaryText, // Dunkler Text für besseren Kontrast
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
                    color: Colors.grey[100], // Hellerer Hintergrund wie bei Number Input
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: buildTargetArea(sentence, gameState),
                ),

                // Reset-Button
                TextButton.icon(
                  onPressed: () {
                    _resetState(sentence);
                  },
                  icon: Icon(Icons.refresh, color: AppTheme.primaryText.withOpacity(0.7)),
                  label: Text(
                    'Reset',
                    style: TextStyle(color: AppTheme.primaryText.withOpacity(0.7)),
                  ),
                ),

                SizedBox(height: 16),

                // Quellbereich für die Wörter (Draggables) - RANDOMISIERT
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Hellerer Hintergrund wie bei Number Input
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: buildSourceArea(sentence, gameState),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Setzt den Zustand zurück
  void _resetState(WordGameSentence sentence) {
    setState(() {
      _placedWords = {};
      sentence.resetSolution();
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
              final hasPlacedWord = _placedWords.containsKey(position);
              String? placedWord;
              bool isCorrect = true;
              int? originalIndex;

              if (hasPlacedWord) {
                final data = _placedWords[position]!;
                originalIndex = data.$1;
                placedWord = data.$2;
                isCorrect = data.$3;
              }

              return DroppableWordSlotWidget(
                position: position,
                word: placedWord,
                isCorrect: isCorrect,
                onAccept: (originalWordIndex, targetPosition) {
                  // Aktualisiere das Spielmodell und prüfe, ob die Platzierung korrekt ist
                  final isCorrect = gameState.placeWord(originalWordIndex, targetPosition);
                  final word = sentence.words[originalWordIndex];

                  // Aktualisiere die UI mit dem neuen Wort an dieser Position
                  setState(() {
                    // Wenn das Wort bereits woanders platziert war, entferne es von dort
                    for (int pos = 0; pos < sentence.words.length; pos++) {
                      if (_placedWords.containsKey(pos) && _placedWords[pos]!.$1 == originalWordIndex) {
                        _placedWords.remove(pos);
                        break;
                      }
                    }

                    // Füge das Wort an der neuen Position hinzu
                    _placedWords[targetPosition] = (originalWordIndex, word, isCorrect);
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
    // Sammle alle bereits platzierten Originalindices
    final placedOriginalIndices = _placedWords.values.map((data) => data.$1).toSet();

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: sentence.randomizedWordsWithIndices.entries.map((entry) {
          // Verwende die randomisierte Anordnung
          final int originalIndex = entry.value.key;
          final String word = entry.value.value;
          final int displayNumber = sentence.getDisplayNumberForWord(originalIndex);

          // Prüfe, ob dieses Wort bereits in einem der Zielslots platziert wurde
          final bool isPlaced = placedOriginalIndices.contains(originalIndex);

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
                // Finde und entferne den Eintrag aus _placedWords
                for (int pos = 0; pos < sentence.words.length; pos++) {
                  if (_placedWords.containsKey(pos) && _placedWords[pos]!.$1 == originalIndex) {
                    _placedWords.remove(pos);
                    break;
                  }
                }
              });
            } : null,
          );
        }).toList(),
      ),
    );
  }
}