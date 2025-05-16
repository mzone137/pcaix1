// lib/models/game_state.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Definiert den Zustand einer Zelle im Spiel.
enum CellState { dead, alive }

/// Model-Klasse für Conway's Game of Life Simulation.
class GameStateModel extends ChangeNotifier {
  late List<List<CellState>> _grid;
  Timer? _timer;
  double _speedFactor = 1.0;
  final int _rows;
  final int _columns;

  /// Getter für das aktuelle Grid.
  List<List<CellState>> get grid => _grid;

  /// Getter für den aktuellen Geschwindigkeitsfaktor.
  double get speedFactor => _speedFactor;

  /// Getter für die Anzahl der Zeilen.
  int get rows => _rows;

  /// Getter für die Anzahl der Spalten.
  int get columns => _columns;

  /// Erstellt ein neues GameStateModel mit angegebener Größe.
  ///
  /// [rows] ist die Anzahl der Reihen.
  /// [columns] ist die Anzahl der Spalten.
  /// [initialDensity] ist die Anfangswahrscheinlichkeit für lebende Zellen (0.0-1.0).
  GameStateModel({
    int rows = 40,
    int columns = 30,
    double initialDensity = 0.3,
  }) : _rows = rows,
        _columns = columns {
    _initializeGrid(initialDensity);
    _startSimulation();
  }

  /// Initialisiert das Grid mit zufälligen lebenden Zellen.
  void _initializeGrid(double density) {
    final random = Random();
    _grid = List.generate(
      _rows,
          (_) => List.generate(
        _columns,
            (_) => random.nextDouble() < density
            ? CellState.alive
            : CellState.dead,
      ),
    );
    notifyListeners();
  }

  /// Startet die Simulation mit dem aktuellen Geschwindigkeitsfaktor.
  void _startSimulation() {
    _timer?.cancel();

    final int updateInterval = (200 / _speedFactor).round();
    _timer = Timer.periodic(Duration(milliseconds: updateInterval), (_) {
      _updateGrid();
    });
  }

  /// Aktualisiert das Grid nach den Regeln von Conway's Game of Life.
  void _updateGrid() {
    final newGrid = List.generate(
      _rows,
          (_) => List.generate(_columns, (_) => CellState.dead),
    );

    for (int i = 0; i < _rows; i++) {
      for (int j = 0; j < _columns; j++) {
        final aliveNeighbors = _countAliveNeighbors(i, j);
        final isCurrentlyAlive = _grid[i][j] == CellState.alive;

        // Conway's Game of Life Regeln anwenden
        if (isCurrentlyAlive) {
          // Eine lebende Zelle überlebt, wenn sie 2 oder 3 lebende Nachbarn hat
          newGrid[i][j] = (aliveNeighbors == 2 || aliveNeighbors == 3)
              ? CellState.alive
              : CellState.dead;
        } else {
          // Eine tote Zelle wird geboren, wenn sie genau 3 lebende Nachbarn hat
          newGrid[i][j] = (aliveNeighbors == 3)
              ? CellState.alive
              : CellState.dead;
        }
      }
    }

    _grid = newGrid;
    notifyListeners();
  }

  /// Zählt die Anzahl der lebenden Nachbarzellen.
  int _countAliveNeighbors(int row, int col) {
    int count = 0;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue; // Zelle selbst überspringen

        // Toroidales Grid (Ränder verbinden sich)
        final newRow = (row + i + _rows) % _rows;
        final newCol = (col + j + _columns) % _columns;

        if (_grid[newRow][newCol] == CellState.alive) count++;
      }
    }

    return count;
  }

  /// Ändert den Geschwindigkeitsfaktor der Simulation.
  ///
  /// [factor] ist der neue Geschwindigkeitsfaktor, der auf bestimmte
  /// Grenzen beschränkt wird.
  void setSpeedFactor(double factor) {
    _speedFactor = factor.clamp(0.25, 4.0);
    _startSimulation();
    notifyListeners();
  }

  /// Verdoppelt die aktuelle Geschwindigkeit.
  void doubleSpeed() {
    setSpeedFactor(_speedFactor * 2);
  }

  /// Halbiert die aktuelle Geschwindigkeit.
  void halveSpeed() {
    setSpeedFactor(_speedFactor / 2);
  }

  /// Setzt das Spiel mit zufälligen Zellen zurück.
  void resetGame([double? density]) {
    _initializeGrid(density ?? 0.3);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}