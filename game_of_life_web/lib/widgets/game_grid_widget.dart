// lib/widgets/game_grid_widget.dart
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../painters/game_painter.dart';

class GameGridWidget extends StatelessWidget {
  /// Bestimmt, ob das Grid gespiegelt dargestellt werden soll.
  final bool mirrored;

  /// Modifikator für die visuelle Geschwindigkeit (unabhängig vom tatsächlichen Timing).
  final double speedModifier;

  /// Farbe der lebenden Zellen.
  final Color cellColor;

  /// Größe der einzelnen Zellen.
  final double cellSize;

  /// Callback-Funktion, die beim Tippen ausgeführt wird.
  final VoidCallback? onTap;

  /// Das GameStateModel, das die Daten für das Grid enthält.
  final GameStateModel gameModel;

  const GameGridWidget({
    Key? key,
    required this.gameModel,
    this.mirrored = false,
    this.speedModifier = 1.0,
    this.cellColor = Colors.lightGreenAccent,
    this.cellSize = 10.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black,
        child: Transform(
          alignment: Alignment.center,
          // Wenn mirrored ist true, spiegele vertikal
          transform: mirrored
              ? (Matrix4.identity()..scale(1.0, -1.0))
              : Matrix4.identity(),
          child: CustomPaint(
            painter: GamePainter(
              grid: gameModel.grid,
              cellSize: cellSize,
              cellColor: cellColor,
              speedModifier: speedModifier,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}