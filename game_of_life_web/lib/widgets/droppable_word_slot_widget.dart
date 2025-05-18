// lib/widgets/droppable_word_slot_widget.dart - Verbesserte Version mit besseren Animationen

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/audio_service.dart';

class DroppableWordSlotWidget extends StatefulWidget {
  final int position;
  final String? word;
  final Function(int, int) onAccept; // originalIndex, targetPosition
  final bool isCorrect;

  const DroppableWordSlotWidget({
    Key? key,
    required this.position,
    this.word,
    required this.onAccept,
    this.isCorrect = true,
  }) : super(key: key);

  @override
  State<DroppableWordSlotWidget> createState() => _DroppableWordSlotWidgetState();
}

class _DroppableWordSlotWidgetState extends State<DroppableWordSlotWidget> with SingleTickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  bool _isAnimating = false;
  bool _isDragOver = false;
  String? _previousWord;

  @override
  void initState() {
    super.initState();
    _previousWord = widget.word;

    // Initialisiere den AnimationController für Feedback
    _feedbackController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Animation für Farbwechsel (normal -> Feedback -> normal)
    _colorAnimation = ColorTween(
      begin: AppTheme.primaryAccent.withOpacity(0.7),
      end: widget.isCorrect ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
      reverseCurve: Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    // Animation für Skalierung (Pulsieren bei Feedback)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_feedbackController);

    // Animation für Schütteln (bei falscher Platzierung)
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -5.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -5.0, end: 5.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 5.0, end: -3.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -3.0, end: 3.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 3.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_feedbackController);

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

    // Reagiere, wenn ein neues Wort gesetzt wurde oder wenn sich der Korrektheitsstatus ändert
    if (oldWidget.word != widget.word || oldWidget.isCorrect != widget.isCorrect) {
      // Nur wenn sich das Wort ändert (nicht beim ersten Laden), starte die Animation
      if (widget.word != null && _previousWord != widget.word) {
        _updateFeedbackAnimation();
        _previousWord = widget.word;
      }
    }
  }

  void _updateFeedbackAnimation() {
    // Aktualisiere die Farbe der Animation
    _colorAnimation = ColorTween(
      begin: AppTheme.primaryAccent.withOpacity(0.7),
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
      onWillAccept: (data) {
        setState(() {
          _isDragOver = true;
        });
        return true;  // Akzeptiere alle Wörter
      },

      onLeave: (data) {
        setState(() {
          _isDragOver = false;
        });
      },

      // Diese Funktion wird aufgerufen, wenn ein Draggable abgelegt wird
      onAccept: (originalWordIndex) {
        setState(() {
          _isDragOver = false;
        });
        widget.onAccept(originalWordIndex, widget.position);
        AudioService().playWordDropSound();
      },

      // Builder für das Widget
      builder: (context, candidateData, rejectedData) {
        // Wenn ein Wort platziert ist, zeige es an
        if (widget.word != null) {
          return AnimatedBuilder(
            animation: _feedbackController,
            builder: (context, child) {
              // Bestimme Farbe und Animation basierend auf Zustand
              Color containerColor = _isAnimating
                  ? _colorAnimation.value ?? AppTheme.primaryAccent.withOpacity(0.7)
                  : widget.isCorrect
                  ? AppTheme.primaryAccent.withOpacity(0.7)
                  : Colors.red.withOpacity(0.7);

              double scale = _isAnimating ? _scaleAnimation.value : 1.0;
              double offsetX = widget.isCorrect ? 0.0 : (_isAnimating ? _shakeAnimation.value : 0.0);

              return Transform.translate(
                offset: Offset(offsetX, 0),
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
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
                  ),
                ),
              );
            },
          );
        }

        // Ansonsten zeige leeren Slot
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: 40,
          width: _isDragOver ? 120 : 100,  // Breite ändern, wenn Drag drüber
          decoration: BoxDecoration(
            color: _isDragOver
                ? AppTheme.primaryAccent.withOpacity(0.2)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDragOver
                  ? AppTheme.primaryAccent
                  : AppTheme.primaryAccent.withOpacity(0.3),
              width: _isDragOver ? 2 : 1,
            ),
            boxShadow: _isDragOver
                ? [
              BoxShadow(
                color: AppTheme.primaryAccent.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ]
                : [],
          ),
          child: Center(
            child: _isDragOver
                ? Icon(
              Icons.add,
              color: AppTheme.primaryAccent,
            )
                : null,
          ),
        );
      },
    );
  }
}