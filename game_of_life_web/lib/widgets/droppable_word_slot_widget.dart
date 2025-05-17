// lib/widgets/droppable_word_slot_widget.dart - Neues Widget für Drag & Drop-Slots

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/audio_service.dart';

class DroppableWordSlotWidget extends StatelessWidget {
  final int position;
  final String? word;
  final Function(int, int) onAccept;

  const DroppableWordSlotWidget({
    Key? key,
    required this.position,
    this.word,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      // Diese Funktion wird aufgerufen, wenn ein Draggable über diesem Widget schwebt
      // Gibt an, ob das Draggable akzeptiert wird
      onWillAccept: (data) => true,  // Akzeptiere alle Wörter
      
      // Diese Funktion wird aufgerufen, wenn ein Draggable abgelegt wird
      onAccept: (originalWordIndex) {
        onAccept(originalWordIndex, position);
        AudioService().playWordDropSound();
      },
      
      // Builder für das Widget
      builder: (context, candidateData, rejectedData) {
        // Wenn ein Drop-Kandidat vorhanden ist, zeige Highlight
        final bool isActive = candidateData.isNotEmpty;
        
        // Wenn ein Wort platziert ist, zeige es an
        if (word != null) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              word!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        
        // Ansonsten zeige leeren Slot
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: 40,
          width: 100,  // Minimal-Breite für leeren Slot
          decoration: BoxDecoration(
            color: isActive 
                ? AppTheme.neonBlue.withOpacity(0.2) 
                : Colors.black45,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive 
                  ? AppTheme.neonBlue 
                  : AppTheme.neonBlue.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.neonBlue.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isActive
                ? Icon(
                    Icons.add,
                    color: AppTheme.neonBlue,
                  )
                : null,
          ),
        );
      },
    );
  }
}