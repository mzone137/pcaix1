// lib/painters/game_painter.dart
import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GamePainter extends CustomPainter {
  final List<List<CellState>> grid;
  final double cellSize;
  final Color cellColor;
  final double speedModifier;

  GamePainter({
    required this.grid,
    required this.cellSize,
    this.cellColor = Colors.lightGreenAccent,
    this.speedModifier = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint alivePaint = Paint()..color = cellColor;

    final int rows = grid.length;
    final int columns = grid[0].length;

    // Zentrieren des Grids auf dem Canvas
    final double offsetX = (size.width - columns * cellSize) / 2;
    final double offsetY = (size.height - rows * cellSize) / 2;

    // Zeichnen der Zellen
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (grid[i][j] == CellState.alive) {
          final Rect rect = Rect.fromLTWH(
            offsetX + j * cellSize,
            offsetY + i * cellSize,
            cellSize,
            cellSize,
          );

          // Abgerundete Ränder für einen moderner Look
          final RRect roundedRect = RRect.fromRectAndRadius(
            rect,
            Radius.circular(cellSize * 0.2), // Leicht abgerundete Ecken
          );

          canvas.drawRRect(roundedRect, alivePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true; // Immer neu zeichnen für Animationen
  }
}