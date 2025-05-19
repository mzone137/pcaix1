// lib/painters/game_painter.dart - Refaktorisierte Version mit Optimierungen

import 'dart:math';

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

/// Painter für das Game of Life-Grid.
///
/// Diese Klasse ist für das Zeichnen des Game of Life-Grids verantwortlich
/// und bietet verschiedene Anpassungsmöglichkeiten wie Zellgröße, Farbe und Geschwindigkeit.
class GamePainter extends CustomPainter {
  /// Die aktuelle Grid-Konfiguration.
  final List<List<CellState>> grid;

  /// Die Größe jeder Zelle in Pixeln.
  final double cellSize;

  /// Die Farbe der lebenden Zellen.
  final Color cellColor;

  /// Modifikator für die Geschwindigkeit der Simulation (visuell).
  final double speedModifier;

  /// Die Form der Zellen (Kreis, abgerundetes Quadrat, Quadrat).
  final CellShape cellShape;

  /// Der Skalierungsfaktor für die Animation.
  final double animationScale;

  /// Bestimmt, ob das Grid mit Gitternetzlinien gezeichnet werden soll.
  final bool showGridLines;

  /// Die Farbe der Gitternetzlinien.
  final Color gridLineColor;

  /// Konstruktor für den GamePainter.
  ///
  /// [grid] ist das aktuelle Grid mit dem Zellzustand.
  /// [cellSize] bestimmt die Größe jeder Zelle in Pixeln.
  /// [cellColor] ist die Farbe der lebenden Zellen.
  /// [speedModifier] kann verwendet werden, um die visuelle Geschwindigkeit zu verändern.
  /// [cellShape] bestimmt die Form der Zellen (Standard: abgerundetes Quadrat).
  /// [animationScale] kann für Zoom-Effekte verwendet werden (Standard: 1.0).
  /// [showGridLines] bestimmt, ob Gitternetzlinien gezeichnet werden (Standard: false).
  /// [gridLineColor] ist die Farbe der Gitternetzlinien (Standard: grau mit 30% Opazität).
  GamePainter({
    required this.grid,
    this.cellSize = AppConstants.defaultCellSize,
    this.cellColor = Colors.lightGreenAccent,
    this.speedModifier = 1.0,
    this.cellShape = CellShape.roundedSquare,
    this.animationScale = 1.0,
    this.showGridLines = false,
    this.gridLineColor = const Color(0x4D000000), // 30% Opazität schwarz
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint alivePaint = Paint()..color = cellColor;
    final Paint gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final int rows = grid.length;
    final int columns = grid[0].length;

    // Berechne die tatsächliche Zellgröße basierend auf Animation und Geschwindigkeit
    final double actualCellSize = cellSize * animationScale;

    // Zentrieren des Grids auf dem Canvas
    final double offsetX = (size.width - columns * actualCellSize) / 2;
    final double offsetY = (size.height - rows * actualCellSize) / 2;

    // Zeichne Gitternetzlinien, wenn aktiviert
    if (showGridLines) {
      _drawGridLines(canvas, rows, columns, offsetX, offsetY, actualCellSize, gridPaint);
    }

    // Zeichnen der lebenden Zellen
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (grid[i][j] == CellState.alive) {
          final Rect rect = Rect.fromLTWH(
            offsetX + j * actualCellSize,
            offsetY + i * actualCellSize,
            actualCellSize,
            actualCellSize,
          );

          // Zeichne die Zelle basierend auf der gewählten Form
          _drawCell(canvas, rect, alivePaint);
        }
      }
    }
  }

  /// Zeichnet die Gitternetzlinien.
  void _drawGridLines(
      Canvas canvas,
      int rows,
      int columns,
      double offsetX,
      double offsetY,
      double actualCellSize,
      Paint paint,
      ) {
    // Zeichne horizontale Linien
    for (int i = 0; i <= rows; i++) {
      final y = offsetY + i * actualCellSize;
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(offsetX + columns * actualCellSize, y),
        paint,
      );
    }

    // Zeichne vertikale Linien
    for (int j = 0; j <= columns; j++) {
      final x = offsetX + j * actualCellSize;
      canvas.drawLine(
        Offset(x, offsetY),
        Offset(x, offsetY + rows * actualCellSize),
        paint,
      );
    }
  }

  /// Zeichnet eine einzelne Zelle basierend auf der gewählten Form.
  void _drawCell(Canvas canvas, Rect rect, Paint paint) {
    switch (cellShape) {
      case CellShape.square:
        canvas.drawRect(rect, paint);
        break;
      case CellShape.roundedSquare:
        final RRect roundedRect = RRect.fromRectAndRadius(
          rect,
          Radius.circular(rect.width * 0.2), // 20% Abrundung
        );
        canvas.drawRRect(roundedRect, paint);
        break;
      case CellShape.circle:
        final Offset center = rect.center;
        final double radius = rect.width / 2;
        canvas.drawCircle(center, radius, paint);
        break;
      case CellShape.hexagon:
        _drawHexagon(canvas, rect, paint);
        break;
    }
  }

  /// Zeichnet eine hexagonale Zelle.
  void _drawHexagon(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();
    final Offset center = rect.center;
    final double radius = rect.width / 2;

    // Berechne die sechs Punkte des Hexagons
    final points = List.generate(6, (index) {
      final angle = (index * 60 + 30) * 3.14159265359 / 180; // in Radians
      return Offset(
        center.dx + radius * 0.86602540378 * cos(angle), // ~ cos(angle)
        center.dy + radius * 0.86602540378 * sin(angle), // ~ sin(angle)
      );
    });

    // Zeichne das Hexagon
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < 6; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    // Optimierung: Nur neu zeichnen, wenn sich relevante Parameter geändert haben
    return oldDelegate.grid != grid ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.cellColor != cellColor ||
        oldDelegate.cellShape != cellShape ||
        oldDelegate.animationScale != animationScale ||
        oldDelegate.showGridLines != showGridLines ||
        oldDelegate.gridLineColor != gridLineColor;
  }
}

/// Verfügbare Formen für die Zellen im Game of Life.
enum CellShape {
  /// Quadratische Zellen.
  square,

  /// Quadratische Zellen mit abgerundeten Ecken.
  roundedSquare,

  /// Kreisförmige Zellen.
  circle,

  /// Hexagonale Zellen.
  hexagon,
}