// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/game_grid_widget.dart';
import '../widgets/speed_indicator.dart';

class DetailScreen extends StatelessWidget {
  final bool halfSpeed;

  const DetailScreen({Key? key, required this.halfSpeed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateModel>(
        builder: (context, gameModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(halfSpeed
                  ? 'Langsamere Animation'
                  : 'Schnellere Animation'),
              backgroundColor: Colors.black87,
              elevation: 0,
            ),
            backgroundColor: Colors.black,
            body: Column(
              children: [
                // Top Panel - Normal Game of Life
                Expanded(
                  child: Stack(
                    children: [
                      GameGridWidget(
                        gameModel: gameModel,
                        mirrored: false,
                        cellColor: Colors.lightBlueAccent,
                        onTap: () {
                          gameModel.halveSpeed();
                        },
                      ),
                      // Speed Indicator
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: SpeedIndicator(
                          speedFactor: gameModel.speedFactor,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 2,
                  color: Colors.blueGrey[800],
                ),

                // Bottom Panel - Mirrored Game of Life
                Expanded(
                  child: Stack(
                    children: [
                      GameGridWidget(
                        gameModel: gameModel,
                        mirrored: true,
                        speedModifier: 0.5,
                        cellColor: Colors.lightGreenAccent,
                        onTap: () {
                          gameModel.doubleSpeed();
                        },
                      ),
                      // Mirrored Speed Indicator
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: SpeedIndicator(
                          speedFactor: gameModel.speedFactor * 0.5,
                          title: 'Mirrored Speed:',
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
              tooltip: 'Zurück zum Startbildschirm',
              backgroundColor: Colors.blueGrey[700],
            ),
          );
        }
    );
  }
}