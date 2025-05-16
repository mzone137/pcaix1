// Update to lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/game_grid_widget.dart';
import '../utils/app_theme.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateModel>(
      builder: (context, gameModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('CONWAY\'S GAME OF LIFE'),
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // Top Panel - Normal Game of Life
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: AppTheme.panelDecoration,
                  child: GameGridWidget(
                    gameModel: gameModel,
                    mirrored: false,
                    cellColor: AppTheme.neonBlue,
                    onTap: () {
                      gameModel.halveSpeed();
                      _navigateToDetail(context, true);
                    },
                  ),
                ),
              ),

              // Description Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Tap the top panel to slow down or the bottom panel to speed up the simulation.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              ),

              // Bottom Panel - Mirrored Game of Life
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: AppTheme.panelDecoration,
                  child: GameGridWidget(
                    gameModel: gameModel,
                    mirrored: true,
                    speedModifier: 0.5,
                    cellColor: AppTheme.matrixGreen,
                    onTap: () {
                      gameModel.doubleSpeed();
                      _navigateToDetail(context, false);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, bool halfSpeed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(halfSpeed: halfSpeed),
      ),
    );
  }
}