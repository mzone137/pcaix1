// lib/widgets/droppable_word_slot_widget.dart - Aktualisiert für Feedback bei richtigen/falschen Platzierungen

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/audio_service.dart';

class DroppableWordSlotWidget extends StatefulWidget {
  final int position;
  final String? word;
  final Function(int, int) onAccept; // originalIndex, targetPosition
  final bool isCorrect; // Neues Feld für visuelles Feedback

  const DroppableWordSlotWidget({
    Key? key,
    required this.position,
    this.word,
    required this.onAccept,
    this.isCorrect = true, // Standardmäßig nehmen wir an, es ist korrekt
  }) : super(key: key);

  @override
  State<DroppableWordSlotWidget> createState() => _DroppableWordSlotWidgetState();
}

class _DroppableWordSlotWidgetState extends State<DroppableWordSlotWidget> with SingleTickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<Color?> _colorAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // Initialisiere den AnimationController für Feedback
    _feedbackController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Animation für Farbwechsel (normal -> Feedback -> normal)
    _colorAnimation = ColorTween(
      begin: AppTheme.neonBlue.withOpacity(0.7),
      end: widget.isCorrect ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
      reverseCurve: Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _feedbackController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _feedbackController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(DroppableWordSlotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Wenn sich der isCorrect-Status ändert, aktualisiere die Animation
    if (oldWidget.isCorrect != widget.isCorrect || oldWidget.word != widget.word) {
      _updateFeedbackAnimation();
    }
  }

  void _updateFeedbackAnimation() {
    // Aktualisiere die Farbe der Animation
    _colorAnimation = ColorTween(
      begin: AppTheme.neonBlue.withOpacity(0.7),
      end: widget.isCorrect ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
      reverseCurve: Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    // Nur starte die Animation, wenn ein Wort vorhanden ist
    if (widget.word != null && !_isAnimating) {
      setState(() {
        _isAnimating = true;
      });
      _feedbackController.forward();
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      // Diese Funktion wird aufgerufen, wenn ein Draggable über diesem Widget schwebt
      // Gibt an, ob das Draggable akzeptiert wird
      onWillAccept: (data) => true,  // Akzeptiere alle Wörter

      // Diese Funktion wird aufgerufen, wenn ein Draggable abgelegt wird
      onAccept: (originalWordIndex) {
        widget.onAccept(originalWordIndex, widget.position);
        AudioService().playWordDropSound();
      },

      // Builder für das Widget
      builder: (context, candidateData, rejectedData) {
        // Wenn ein Drop-Kandidat vorhanden ist, zeige Highlight
        final bool isActive = candidateData.isNotEmpty;

        // Wenn ein Wort platziert ist, zeige es an
        if (widget.word != null) {
          return AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              // Verwende die animierte Farbe, wenn die Animation läuft, sonst die statische Farbe
              Color containerColor = _isAnimating
                  ? _colorAnimation.value ?? AppTheme.neonBlue.withOpacity(0.7)
                  : widget.isCorrect
                  ? AppTheme.neonBlue.withOpacity(0.7)
                  : Colors.red.withOpacity(0.7);

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: containerColor.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  widget.word!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
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