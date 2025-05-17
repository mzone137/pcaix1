// lib/widgets/draggable_word_widget.dart - Neues Widget für Drag & Drop-Funktionalität

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/audio_service.dart';

class DraggableWordWidget extends StatelessWidget {
  final String word;
  final int originalIndex;
  final bool isPlaced;
  final VoidCallback? onRemove;

  const DraggableWordWidget({
    Key? key,
    required this.word,
    required this.originalIndex,
    this.isPlaced = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wenn das Wort bereits platziert ist und in der Quell-Liste angezeigt wird,
    // zeige es ausgegraut an
    if (isPlaced) {
      return _buildPlacedWord();
    }

    // Ansonsten erstelle ein draggable Widget
    return Draggable<int>(
      // Der Wert, der beim Drag übergeben wird, ist der Original-Index des Wortes
      data: originalIndex,
      
      // Feedback wird angezeigt, während das Wort gezogen wird
      feedback: Material(
        color: Colors.transparent,
        child: _buildWordContainer(
          context: context, 
          color: AppTheme.neonBlue.withOpacity(0.9),
          scale: 1.1,
          shadowIntensity: 0.4,
        ),
      ),
      
      // Widget im Ruhezustand
      child: _buildWordContainer(
        context: context,
        color: AppTheme.deepBlue,
      ),
      
      // Widget an der Originalposition während des Ziehens
      childWhenDragging: _buildWordContainer(
        context: context,
        color: Colors.grey.withOpacity(0.3),
        textOpacity: 0.5,
      ),
      
      // Callbacks
      onDragStarted: () {
        // Sound beim Aufheben des Wortes abspielen
        AudioService().playWordPickupSound();
      },
      onDragEnd: (details) {
        // Wenn das Wort nirgendwo abgelegt wurde, spiele einen Fehler-Sound ab
        if (!details.wasAccepted) {
          AudioService().playErrorSound();
        }
      },
    );
  }

  Widget _buildPlacedWord() {
    return GestureDetector(
      onTap: onRemove,
      child: _buildWordContainer(
        context: null,
        color: Colors.grey.withOpacity(0.5),
        textOpacity: 0.6,
      ),
    );
  }

  Widget _buildWordContainer({
    BuildContext? context,
    required Color color,
    double textOpacity = 1.0,
    double scale = 1.0,
    double shadowIntensity = 0.2,
  }) {
    return Transform.scale(
      scale: scale,
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonBlue.withOpacity(shadowIntensity),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          word,
          style: TextStyle(
            color: Colors.white.withOpacity(textOpacity),
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}