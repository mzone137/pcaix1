// lib/widgets/drag_drop_word_game_widget.dart - Hauptwidget für das Drag & Drop-Spiel

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
                  'Arrange the words in correct order',
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
                  child: buildTargetArea(sentence),
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
                
                // Quellbereich für die Wörter (Draggables)
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
    });
  }

  // Baut den Zielbereich auf, wo Wörter abgelegt werden
  Widget buildTargetArea(WordGameSentence sentence) {
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
              
              // Suche nach dem Wort, das an dieser Position platziert ist
              for (int i = 0; i < sentence.words.length; i++) {
                if (sentence.isWordPlaced(i) && 
                    _targetSlots.containsKey(position) && 
                    _targetSlots[position] == sentence.words[i]) {
                  placedWord = sentence.words[i];
                  originalIndex = i;
                  break;
                }
              }
              
              return DroppableWordSlotWidget(
                position: position,
                word: placedWord,
                onAccept: (originalWordIndex, targetPosition) {
                  // Aktualisiere das Spielmodell
                  final success = Provider.of<WordGameStateModel>(context, listen: false)
                      .placeWord(originalWordIndex, targetPosition);
                  
                  // Aktualisiere die UI
                  if (success) {
                    setState(() {
                      _targetSlots[targetPosition] = sentence.words[originalWordIndex];
                    });
                    
                    // Prüfe, ob die Lösung korrekt ist
                    if (sentence.isSolutionCorrect()) {
                      // Spiele Erfolgs-Sound ab
                      AudioService().playSuccessSound();
                      
                      // Rufe den Callback auf
                      widget.onSolutionCorrect();
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Baut den Quellbereich auf, aus dem Wörter gezogen werden
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
          children: sentence.randomizedWords.map((entry) {
            final int index = entry.key - 1; // Original-Index (0-basiert)
            final String word = entry.value;
            final bool isPlaced = sentence.isWordPlaced(index);
            
            return DraggableWordWidget(
              word: word,
              originalIndex: index,
              isPlaced: isPlaced,
              onRemove: isPlaced ? () {
                // Entferne das Wort aus dem Zielbereich
                gameState.removeWord(index);
                
                // Aktualisiere die UI
                setState(() {
                  // Finde und entferne den Eintrag aus _targetSlots
                  _targetSlots.removeWhere((key, value) => value == word);
                });
              } : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}