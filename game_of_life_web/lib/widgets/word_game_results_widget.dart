// lib/widgets/word_game_results_widget.dart

import 'package:flutter/material.dart';
import '../domain/models/word_game_models.dart';
import '../utils/app_theme.dart';

class WordGameResultsWidget extends StatelessWidget {
  final WordGameChapter chapter;
  final VoidCallback onContinue;

  const WordGameResultsWidget({
    Key? key,
    required this.chapter,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Daten für die Ergebnisanzeige vorbereiten
    final totalTime = chapter.completionTime ?? Duration.zero;
    final averageTime = chapter.averageSentenceTime;
    final sentenceCount = chapter.sentences.length;
    
    // Formatierung der Zeiten
    final totalMinutes = totalTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final totalSeconds = totalTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    final avgSeconds = averageTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    final avgMilliseconds = (averageTime.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Überschrift
              const Text(
                'CHAPTER COMPLETED!',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Kapitel-Titel
              Text(
                chapter.title,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 20,
                  color: AppTheme.neonBlue,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Ergebniskarte
              Container(
                padding: const EdgeInsets.all(24),
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
                    const Text(
                      'YOUR RESULTS',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Gesamtzeit
                    _buildResultRow(
                      icon: Icons.timer,
                      label: 'Total Time:',
                      value: '$totalMinutes:$totalSeconds',
                      color: AppTheme.neonBlue,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Durchschnittliche Zeit pro Satz
                    _buildResultRow(
                      icon: Icons.speed,
                      label: 'Avg. Time per Sentence:',
                      value: '$avgSeconds.$avgMilliseconds s',
                      color: Colors.green,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Anzahl der Sätze
                    _buildResultRow(
                      icon: Icons.text_fields,
                      label: 'Sentences Completed:',
                      value: '$sentenceCount',
                      color: Colors.amber,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Bewertung anzeigen (basierend auf der Durchschnittszeit)
                    _buildRating(averageTime),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Weiter-Button
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppTheme.neonBlue.withOpacity(0.5),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRating(Duration averageTime) {
    // Bewertung basierend auf der Durchschnittszeit pro Satz
    String ratingText;
    Color ratingColor;
    String emoji;
    
    final avgMilliseconds = averageTime.inMilliseconds;
    
    if (avgMilliseconds < 5000) {
      ratingText = 'EXCELLENT!';
      ratingColor = Colors.green;
      emoji = '🏆';
    } else if (avgMilliseconds < 10000) {
      ratingText = 'VERY GOOD!';
      ratingColor = Colors.lightGreen;
      emoji = '👍';
    } else if (avgMilliseconds < 15000) {
      ratingText = 'GOOD!';
      ratingColor = Colors.amber;
      emoji = '😊';
    } else if (avgMilliseconds < 20000) {
      ratingText = 'KEEP PRACTICING!';
      ratingColor = Colors.orange;
      emoji = '💪';
    } else {
      ratingText = 'YOU CAN DO BETTER!';
      ratingColor = Colors.red;
      emoji = '🔄';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: ratingColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ratingColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Text(
            ratingText,
            style: TextStyle(
              color: ratingColor,
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}