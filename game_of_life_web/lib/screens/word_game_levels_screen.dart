// lib/screens/word_game_levels_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/word_game_data.dart';
import '../models/word_game_models.dart';
import '../utils/app_theme.dart';
import 'word_game_screen.dart';

class WordGameLevelsScreen extends StatefulWidget {
  const WordGameLevelsScreen({Key? key}) : super(key: key);

  @override
  State<WordGameLevelsScreen> createState() => _WordGameLevelsScreenState();
}

class _WordGameLevelsScreenState extends State<WordGameLevelsScreen> with SingleTickerProviderStateMixin {
  List<WordGameLevel> _levels = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadLevels();
  }

  Future<void> _loadLevels() async {
    try {
      final levelData = await WordGameData.loadLevelData();

      setState(() {
        _levels = levelData.map((levelJson) {
          final List<WordGameChapter> chapters = [];

          for (final chapterJson in levelJson['chapters']) {
            final List<WordGameSentence> sentences = [];

            for (final sentenceText in chapterJson['sentences']) {
              sentences.add(WordGameSentence.fromText(sentenceText));
            }

            chapters.add(WordGameChapter(
              title: chapterJson['title'],
              sentences: sentences,
            ));
          }

          return WordGameLevel(
            id: levelJson['id'],
            title: levelJson['title'],
            chapters: chapters,
          );
        }).toList();

        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      print('Fehler beim Laden der Level: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worlds Wide Words Olympic Games',
            style: TextStyle(fontFamily: 'Orbitron')),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              AppTheme.deepBlue.withOpacity(0.8),
              Colors.black,
            ],
          ),
        ),
        child: _isLoading
            ? _buildLoadingIndicator()
            : _buildLevelSelection(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
          ),
          SizedBox(height: 20),
          Text(
            'Loading levels...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Orbitron',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Level',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  return _buildLevelCard(context, level);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, WordGameLevel level) {
    final gameState = Provider.of<WordGameStateModel>(context, listen: false);

    return Card(
      color: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.neonBlue.withOpacity(0.5),
          width: 1,
        ),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Animation für den Übergang
          _navigateToGame(context, level, gameState);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level.title,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                '${level.chapters.length} Chapters',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.play_circle_fill,
                  color: AppTheme.neonBlue,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, WordGameLevel level, WordGameStateModel gameState) {
    // 2-Sekunden Übergangsanimation
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: Container(color: Colors.black),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
    );

    // Initialisiere das Spiel und navigiere nach einer Verzögerung
    gameState.initGame(level);

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(); // Schließe den schwarzen Übergang

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => WordGameScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.easeOutQuint;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 600),
        ),
      );
    });
  }
}