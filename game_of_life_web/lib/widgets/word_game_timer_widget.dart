// lib/widgets/word_game_timer_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_game_models.dart';
import '../utils/app_theme.dart';

class WordGameTimerWidget extends StatefulWidget {
  const WordGameTimerWidget({Key? key}) : super(key: key);

  @override
  _WordGameTimerWidgetState createState() => _WordGameTimerWidgetState();
}

class _WordGameTimerWidgetState extends State<WordGameTimerWidget> {
  late ValueNotifier<Duration> _timeNotifier;
  
  @override
  void initState() {
    super.initState();
    _timeNotifier = ValueNotifier<Duration>(Duration.zero);
    
    // Starten des Timer-Updates
    _startTimer();
  }
  
  void _startTimer() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      final gameState = Provider.of<WordGameStateModel>(context, listen: false);
      _timeNotifier.value = gameState.currentTime;
      
      if (gameState.isGameActive) {
        _startTimer(); // Rekursiver Aufruf für kontinuierliches Updating
      }
    });
  }

  @override
  void dispose() {
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonBlue.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: ValueListenableBuilder<Duration>(
        valueListenable: _timeNotifier,
        builder: (context, duration, _) {
          // Formatierung der Zeit als MM:SS:ms
          final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
          final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
          final milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: AppTheme.neonBlue,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '$minutes:$seconds:$milliseconds',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}