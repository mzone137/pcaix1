// lib/screens/word_game_screen.dart - Angepasst für helleres Design
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/word_game_models.dart';
import '../utils/app_theme.dart';
import '../widgets/word_game_timer_widget.dart';
import '../widgets/word_game_results_widget.dart';
import '../widgets/chapter_selection_widget.dart';
import '../presentation/widgets/word_game/drag_drop_word_game_widget.dart';
import '../widgets/number_input_widget.dart';
import '../widgets/game_mode_toggle_widget.dart';
import '../services/audio/audio_service.dart';

class WordGameScreen extends StatefulWidget {
  const WordGameScreen({Key? key}) : super(key: key);

  @override
  _WordGameScreenState createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  // AudioService-Instanz
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _preloadSounds();
  }

  // Lade alle Sound-Effekte vor
  Future<void> _preloadSounds() async {
    await _audioService.preloadSounds();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordGameStateModel>(
      builder: (context, gameState, _) {
        // Wenn kein Kapitel ausgewählt ist, zeige Kapitelauswahl
        if (gameState.currentChapter == null) {
          return _buildChapterSelection(context, gameState);
        }

        // Wenn das Spiel beendet ist, zeige Ergebnisse
        if (!gameState.isGameActive) {
          return _buildResultsScreen(context, gameState);
        }

        // Ansonsten zeige das Spielfeld
        return _buildGameScreen(context, gameState);
      },
    );
  }

  Widget _buildChapterSelection(BuildContext context, WordGameStateModel gameState) {
    if (gameState.currentLevel == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: AppTheme.primaryAccent,
        ),
        body: Center(
          child: Text('No level selected', style: TextStyle(color: AppTheme.primaryText)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          gameState.currentLevel!.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            gameState.resetGame();
            Navigator.pop(context);
          },
        ),
      ),
      // Helles Hintergrund-Design wie in landing_page
      backgroundColor: AppTheme.creamBackground,
      body: Column(
        children: [
          // Game mode toggle (oberhalb der Kapitelauswahl)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GameModeToggleWidget(),
              ),
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ChapterSelectionWidget(
                level: gameState.currentLevel!,
                onChapterSelected: (chapter) {
                  gameState.selectChapter(chapter);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context, WordGameStateModel gameState) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          gameState.currentChapter!.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              _showExitConfirmation(context, gameState);
            },
          ),
        ],
      ),
      // Helles Hintergrund-Design wie in landing_page
      backgroundColor: AppTheme.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LinearProgressIndicator(
                value: gameState.currentSentenceIndex /
                    gameState.currentChapter!.sentences.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
              ),
            ),

            // Sentence counter and timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sentence ${gameState.currentSentenceIndex + 1} of ${gameState.currentChapter!.sentences.length}',
                    style: TextStyle(color: AppTheme.primaryText),
                  ),
                  WordGameTimerWidget(),
                ],
              ),
            ),

            SizedBox(height: 8),

            // Game Mode Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GameModeToggleWidget(),
                ),
              ),
            ),

            // Hauptspielbereich - basierend auf ausgewähltem Modus
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: gameState.useDragAndDrop
                    ? DragDropWordGameWidget(
                  onSolutionCorrect: () => _handleCorrectSolution(context, gameState),
                )
                    : NumberInputWidget(
                  onSolutionCorrect: () => _handleCorrectSolution(context, gameState),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context, WordGameStateModel gameState) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryAccent,
        automaticallyImplyLeading: false,
      ),
      // Helles Hintergrund-Design wie in landing_page
      backgroundColor: AppTheme.creamBackground,
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.creamBackground,
        ),
        child: WordGameResultsWidget(
          chapter: gameState.currentChapter!,
          onContinue: () {
            gameState.resetGame();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _handleCorrectSolution(BuildContext context, WordGameStateModel gameState) {
    // Bildschirm verdunkeln
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 500),
    );

    // Nach 2 Sekunden zum nächsten Satz
    Future.delayed(Duration(milliseconds: 2000), () {
      Navigator.of(context).pop();
      gameState.moveToNextSentence();
    });
  }

  void _showExitConfirmation(BuildContext context, WordGameStateModel gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Exit Game?',
          style: TextStyle(color: AppTheme.primaryText, fontFamily: 'Orbitron'),
        ),
        content: Text(
          'Your progress in this chapter will be lost.',
          style: TextStyle(color: AppTheme.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppTheme.primaryAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Schließe den Dialog
              gameState.resetGame();
              Navigator.pop(context); // Zurück zum Hauptmenü
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
            ),
            child: Text('EXIT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}