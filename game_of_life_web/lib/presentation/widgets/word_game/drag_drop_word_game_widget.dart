// lib/presentation/widgets/word_game/drag_drop_word_game_widget.dart - Refaktorisierte Version

import 'package:flutter/material.dart';
import '../../../domain/models/word_game_models.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../widgets/word_game_input_base.dart';
import '../../../widgets/draggable_word_widget.dart';
import '../../../widgets/droppable_word_slot_widget.dart';

/// Eine Implementierung des WordGameInputBase für die Drag & Drop-Variante.
class DragDropWordGameWidget extends WordGameInputBase {
  const DragDropWordGameWidget({
    Key? key,
    required super.onSolutionCorrect,
  }) : super(key: key);

  @override
  State<DragDropWordGameWidget> createState() => _DragDropWordGameWidgetState();
}

class _DragDropWordGameWidgetState extends WordGameInputBaseState<DragDropWordGameWidget>
    with SingleTickerProviderStateMixin {
  // Animation Controller für Einfade-/Skalierungseffekte
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  // Zuordnung von Positionen zu Worten (für die UI-Darstellung)
  // Key: Position im UI, Value: Tuple aus (Originalindex, Wort, Korrektheit)
  final Map<int, (int, String, bool)> _placedWords = {};

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppConstants.longAnimationDuration,
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
  Widget buildInstructionText() {
    return const Text(
      'Drag words with numbers to arrange them in correct order',
      style: TextStyle(
        color: AppTheme.primaryText,
        fontSize: AppConstants.fontSizeMedium,
        fontFamily: 'Orbitron',
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void resetState() {
    setState(() {
      _placedWords.clear();
    });

    // Starte Animationen neu
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget buildContent(WordGameSentence sentence, WordGameStateModel gameState) {
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
      child: Column(
        children: [
          // Zielbereich für die Wörter (Drop-Targets)
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(
              vertical: AppConstants.defaultPadding,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding,
              vertical: AppConstants.defaultPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
              border: Border.all(
                color: AppTheme.primaryAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: _buildTargetArea(sentence, gameState),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Quellbereich für die Wörter (Draggables) - RANDOMISIERT
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                border: Border.all(
                  color: AppTheme.primaryAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: _buildSourceArea(sentence, gameState),
            ),
          ),
        ],
      ),
    );
  }

  // Baut den Zielbereich auf, wo Wörter abgelegt werden
  Widget _buildTargetArea(WordGameSentence sentence, WordGameStateModel gameState) {
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
                onAccept: (originalWordIndex, targetPosition) =>
                    _handleWordPlacement(
                      originalWordIndex,
                      targetPosition,
                      sentence,
                      gameState,
                    ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Behandelt die Platzierung eines Wortes in einem Zielslot
  void _handleWordPlacement(
      int originalWordIndex,
      int targetPosition,
      WordGameSentence sentence,
      WordGameStateModel gameState,
      ) {
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
      super.audioService.playSuccessSound();
    } else {
      super.audioService.playErrorSound();
    }

    // Prüfe, ob die Lösung korrekt ist
    if (sentence.isSolutionCorrect()) {
      super.handleCorrectSolution();
    }
  }

  // Baut den Quellbereich auf, aus dem Wörter gezogen werden - RANDOMISIERT
  Widget _buildSourceArea(WordGameSentence sentence, WordGameStateModel gameState) {
    // Sammle alle bereits platzierten Originalindices
    final placedOriginalIndices = _placedWords.values.map((data) => data.$1).toSet();

    return Center(
      child: Wrap(
        spacing: AppConstants.smallPadding,
        runSpacing: AppConstants.defaultPadding,
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
            onRemove: isPlaced
                ? () => _handleWordRemoval(originalIndex, sentence, gameState)
                : null,
          );
        }).toList(),
      ),
    );
  }

  // Behandelt das Entfernen eines Wortes aus dem Zielbereich
  void _handleWordRemoval(
      int originalWordIndex,
      WordGameSentence sentence,
      WordGameStateModel gameState,
      ) {
    // Entferne das Wort aus dem Zielbereich
    gameState.removeWord(originalWordIndex);

    // Aktualisiere die UI
    setState(() {
      // Finde und entferne den Eintrag aus _placedWords
      for (int pos = 0; pos < sentence.words.length; pos++) {
        if (_placedWords.containsKey(pos) && _placedWords[pos]!.$1 == originalWordIndex) {
          _placedWords.remove(pos);
          break;
        }
      }
    });

    // Sound-Feedback
    super.audioService.playWordPickupSound();
  }
}