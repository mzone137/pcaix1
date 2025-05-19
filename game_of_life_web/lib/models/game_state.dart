// lib/models/game_state.dart - Refaktorisierte Version

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Definiert den Zustand einer Zelle im Game of Life.
enum CellState { dead, alive }

/// Konfiguration für die Game of Life-Simulation.
class GameConfig {
  final int rows;
  final int columns;
  final double initialDensity;
  final Duration baseUpdateInterval;

  const GameConfig({
    this.rows = 40,
    this.columns = 30,
    this.initialDensity = 0.3,
    this.baseUpdateInterval = const Duration(milliseconds: 200),
  });
}

/// Enthält die Regeln für Conway's Game of Life.
abstract class GameRules {
  /// Prüft ob eine Zelle im nächsten Zustand lebendig sein wird.
  ///
  /// [isCurrentlyAlive] gibt an, ob die Zelle aktuell lebendig ist.
  /// [aliveNeighbors] gibt die Anzahl der lebenden Nachbarzellen an.
  static bool willCellLive(bool isCurrentlyAlive, int aliveNeighbors) {
    if (isCurrentlyAlive) {
      // Eine lebende Zelle überlebt, wenn sie 2 oder 3 lebende Nachbarn hat
      return aliveNeighbors == 2 || aliveNeighbors == 3;
    } else {
      // Eine tote Zelle wird geboren, wenn sie genau 3 lebende Nachbarn hat
      return aliveNeighbors == 3;
    }
  }
}

/// Model-Klasse für Conway's Game of Life Simulation.
///
/// Diese Klasse implementiert den Algorithmus für Conway's Game of Life
/// und bietet eine API zum Steuern der Simulation.
class GameStateModel extends ChangeNotifier {
  late List<List<CellState>> _grid;
  Timer? _timer;
  double _speedFactor = 1.0;
  final GameConfig _config;
  bool _isRunning = false;

  /// Erstellt ein neues GameStateModel mit der angegebenen Konfiguration.
  GameStateModel({GameConfig? config})
      : _config = config ?? const GameConfig() {
    _initializeGrid(_config.initialDensity);
  }

  /// Getter für das aktuelle Grid.
  List<List<CellState>> get grid => _grid;

  /// Getter für den aktuellen Geschwindigkeitsfaktor.
  double get speedFactor => _speedFactor;

  /// Getter für die Anzahl der Zeilen.
  int get rows => _config.rows;

  /// Getter für die Anzahl der Spalten.
  int get columns => _config.columns;

  /// Gibt an, ob die Simulation gerade läuft.
  bool get isRunning => _isRunning;

  /// Initialisiert das Grid mit zufälligen lebendigen Zellen.
  ///
  /// [density] bestimmt die Wahrscheinlichkeit, dass eine Zelle lebendig ist (0.0-1.0).
  void _initializeGrid(double density) {
    final random = Random();
    _grid = List.generate(
      _config.rows,
          (_) => List.generate(
        _config.columns,
            (_) => random.nextDouble() < density
            ? CellState.alive
            : CellState.dead,
      ),
    );
    notifyListeners();
  }

  /// Startet die Simulation mit dem aktuellen Geschwindigkeitsfaktor.
  void startSimulation() {
    if (_isRunning) return;

    _isRunning = true;
    _timer?.cancel();

    final int updateInterval = (_config.baseUpdateInterval.inMilliseconds / _speedFactor).round();
    _timer = Timer.periodic(Duration(milliseconds: updateInterval), (_) {
      _updateGrid();
    });

    notifyListeners();
  }

  /// Pausiert die Simulation.
  void pauseSimulation() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer?.cancel();
    _timer = null;

    notifyListeners();
  }

  /// Schaltet die Simulation zwischen Laufen und Pause um.
  void toggleSimulation() {
    _isRunning ? pauseSimulation() : startSimulation();
  }

  /// Aktualisiert das Grid nach den Regeln von Conway's Game of Life.
  ///
  /// Diese Methode implementiert einen optimierten Algorithmus für
  /// Conway's Game of Life mit toroidalem Grid (Ränder verbinden sich).
  void _updateGrid() {
    // Optimiert: Wir erstellen ein neues Grid für die nächste Generation
    final newGrid = List.generate(
      _config.rows,
          (_) => List.generate(_config.columns, (_) => CellState.dead),
    );

    // Iteriere über alle Zellen und wende die Game of Life Regeln an
    for (int i = 0; i < _config.rows; i++) {
      for (int j = 0; j < _config.columns; j++) {
        final aliveNeighbors = _countAliveNeighbors(i, j);
        final isCurrentlyAlive = _grid[i][j] == CellState.alive;

        // Wende die Conway's Game of Life Regeln an
        final willLive = GameRules.willCellLive(isCurrentlyAlive, aliveNeighbors);
        newGrid[i][j] = willLive ? CellState.alive : CellState.dead;
      }
    }

    _grid = newGrid;
    notifyListeners();
  }

  /// Zählt die Anzahl der lebenden Nachbarzellen.
  ///
  /// [row] und [col] spezifizieren die Position der Zelle.
  /// Berücksichtigt ein toroidales Grid, bei dem die Ränder verbunden sind.
  int _countAliveNeighbors(int row, int col) {
    int count = 0;
    final directions = [
      (-1, -1), (-1, 0), (-1, 1),
      (0, -1),           (0, 1),
      (1, -1),  (1, 0),  (1, 1),
    ];

    for (final (dRow, dCol) in directions) {
      // Toroidales Grid (Ränder verbinden sich)
      final newRow = (row + dRow + _config.rows) % _config.rows;
      final newCol = (col + dCol + _config.columns) % _config.columns;

      if (_grid[newRow][newCol] == CellState.alive) count++;
    }

    return count;
  }

  /// Ändert den Geschwindigkeitsfaktor der Simulation.
  ///
  /// [factor] ist der neue Geschwindigkeitsfaktor, der auf bestimmte
  /// Grenzen beschränkt wird.
  void setSpeedFactor(double factor) {
    // Stelle sicher, dass der Faktor in vernünftigen Grenzen bleibt
    _speedFactor = factor.clamp(0.25, 4.0);

    // Falls die Simulation läuft, starte sie neu mit dem neuen Faktor
    if (_isRunning) {
      _timer?.cancel();
      startSimulation();
    }

    notifyListeners();
  }

  /// Verdoppelt die aktuelle Geschwindigkeit.
  void doubleSpeed() => setSpeedFactor(_speedFactor * 2);

  /// Halbiert die aktuelle Geschwindigkeit.
  void halveSpeed() => setSpeedFactor(_speedFactor / 2);

  /// Aktiviert oder deaktiviert eine bestimmte Zelle.
  ///
  /// [row] und [col] geben die Position der Zelle an.
  /// Gibt zurück, ob die Zelle nach der Änderung lebendig ist.
  bool toggleCell(int row, int col) {
    if (row < 0 || row >= _config.rows || col < 0 || col >= _config.columns) {
      return false;
    }

    _grid[row][col] = _grid[row][col] == CellState.alive
        ? CellState.dead
        : CellState.alive;

    notifyListeners();
    return _grid[row][col] == CellState.alive;
  }

  /// Setzt das Spiel mit zufälligen Zellen zurück.
  ///
  /// [density] gibt die Dichte der lebendigen Zellen an.
  /// Stoppt die laufende Simulation.
  void resetGame([double? density]) {
    _timer?.cancel();
    _isRunning = false;
    _initializeGrid(density ?? _config.initialDensity);
  }

  /// Setzt das Spiel mit einem leeren Gitter zurück.
  void clearGrid() {
    _timer?.cancel();
    _isRunning = false;
    _grid = List.generate(
      _config.rows,
          (_) => List.generate(_config.columns, (_) => CellState.dead),
    );
    notifyListeners();
  }

  /// Erzeugt ein vordefiniertes Muster im Grid.
  ///
  /// [pattern] ist ein 2D-Array von boolschen Werten, wobei true einen lebendigen Zustand darstellt.
  /// [row] und [col] sind die Koordinaten der oberen linken Ecke des Musters.
  void setPattern(List<List<bool>> pattern, int row, int col) {
    // Stelle sicher, dass die Simulation angehalten ist
    pauseSimulation();

    // Überprüfe, ob das Muster passt
    if (row < 0 || row + pattern.length > _config.rows ||
        col < 0 || col + pattern[0].length > _config.columns) {
      return;
    }

    // Platziere das Muster
    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[i].length; j++) {
        _grid[row + i][col + j] = pattern[i][j] ? CellState.alive : CellState.dead;
      }
    }

    notifyListeners();
  }

  /// Bereinigungsmethode, die den Timer beendet, wenn das Modell nicht mehr benötigt wird.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}