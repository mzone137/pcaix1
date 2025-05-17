// lib/widgets/chapter_selection_widget.dart

import 'package:flutter/material.dart';
import '../models/word_game_models.dart';
import '../utils/app_theme.dart';

class ChapterSelectionWidget extends StatelessWidget {
  final WordGameLevel level;
  final Function(WordGameChapter) onChapterSelected;

  const ChapterSelectionWidget({
    Key? key,
    required this.level,
    required this.onChapterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level.title,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          
          SizedBox(height: 8),
          
          Text(
            'Select a chapter to begin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          
          SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: level.chapters.length,
              itemBuilder: (context, index) {
                final chapter = level.chapters[index];
                return _buildChapterCard(context, chapter, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, WordGameChapter chapter, int index) {
    // Berechne den Status des Kapitels
    final bool isCompleted = chapter.completionTime != null;
    final int sentenceCount = chapter.sentences.length;
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green.withOpacity(0.7) : AppTheme.neonBlue.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onChapterSelected(chapter),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.neonBlue.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kapitel-Nummer
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.withOpacity(0.2) : AppTheme.neonBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? Colors.green.withOpacity(0.7) : AppTheme.neonBlue.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Orbitron',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Kapitel-Informationen
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        SizedBox(height: 8),
                        
                        Text(
                          '$sentenceCount sentences',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        
                        if (isCompleted) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status-Icon
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.play_circle_fill,
                    color: isCompleted ? Colors.green : AppTheme.neonBlue,
                    size: 28,
                  ),
                ],
              ),
              
              if (isCompleted) ...[
                SizedBox(height: 16),
                // Statistiken anzeigen
                _buildStatistics(chapter),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(WordGameChapter chapter) {
    final totalTime = chapter.completionTime ?? Duration.zero;
    final avgTime = chapter.averageSentenceTime;
    
    // Formatierung der Zeiten
    final totalMinutes = totalTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final totalSeconds = totalTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    final avgSeconds = avgTime.inSeconds.remainder(60);
    final avgMilliseconds = (avgTime.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.timer_outlined,
            label: 'Total',
            value: '$totalMinutes:$totalSeconds',
          ),
          _buildStatItem(
            icon: Icons.speed_outlined,
            label: 'Avg/Sent',
            value: '$avgSeconds.$avgMilliseconds s',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}