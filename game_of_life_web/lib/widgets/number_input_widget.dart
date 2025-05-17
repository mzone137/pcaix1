// lib/widgets/number_input_widget.dart - Komplett überarbeitet mit einfachem NumPad

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_game_models.dart';
import '../utils/app_theme.dart';
import '../services/audio_service.dart';

class NumberInputWidget extends StatefulWidget {
  final VoidCallback onSolutionCorrect;

  const NumberInputWidget({
    Key? key,
    required this.onSolutionCorrect,
  }) : super(key: key);

  @override
  _NumberInputWidgetState createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  // Benutzersequenz als String
  String _userSequence = "";

  // Feedback-Status
  bool? _isSequenceCorrect;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordGameStateModel>(
      builder: (context, gameState, _) {
        final sentence = gameState.currentSentence;

        if (sentence == null) {
          return Center(
            child: Text(
              'No sentence available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Bestimme die maximale Anzahl an Ziffern (= Anzahl der Wörter)
        final int maxDigits = sentence.words.length;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.neonBlue.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Anweisungstext
              Text(
                'Enter the sequence of numbers for correct word order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Orbitron',
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24),

              // Anzeige des Satzes mit Wörtern und Zahlen - RANDOMISIERT
              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.neonBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: buildWordListDisplay(sentence),
              ),

              SizedBox(height: 20),

              // Eingabefeld für die Sequenz - VEREINFACHT
              Container(
                height: 70,
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: _isSequenceCorrect == null
                      ? Colors.black45
                      : _isSequenceCorrect == true
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSequenceCorrect == null
                        ? AppTheme.neonBlue
                        : _isSequenceCorrect == true
                        ? Colors.green
                        : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _userSequence.isEmpty
                            ? 'Enter number sequence...'
                            : _userSequence,
                        style: TextStyle(
                          color: _userSequence.isEmpty
                              ? Colors.white54
                              : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_userSequence.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.backspace_outlined, color: Colors.white70),
                        onPressed: () {
                          setState(() {
                            if (_userSequence.isNotEmpty) {
                              _userSequence = _userSequence.substring(0, _userSequence.length - 1);
                              _isSequenceCorrect = null;
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // EINFACHES NUMPAD
              Expanded(
                child: buildSimpleNumpad(maxDigits, gameState, sentence),
              ),

              // Reset-Button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _userSequence = "";
                    _isSequenceCorrect = null;
                  });
                },
                icon: Icon(Icons.refresh, color: Colors.white70),
                label: Text(
                  'Reset',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Baut die Anzeige der Wörter mit ihren Zahlen - RANDOMISIERT
  Widget buildWordListDisplay(WordGameSentence sentence) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: sentence.randomizedWordsWithIndices.entries.map((entry) {
        final int displayPosition = entry.key;
        final int originalIndex = entry.value.key;
        final String word = entry.value.value;
        final int displayNumber = sentence.getDisplayNumberForWord(originalIndex);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.deepBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              // Zeige die Nummer in einem Kreis an
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    displayNumber.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // VEREINFACHTES NUMPAD
  Widget buildSimpleNumpad(int maxDigits, WordGameStateModel gameState, WordGameSentence sentence) {
    // Erzeugen der Ziffern (beginnend bei 1 bis maxDigits)
    final List<int> digits = List.generate(maxDigits, (index) => index + 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 3x3 Numpad Layout (oder 2 Reihen für weniger Tasten)
        for (int row = 0; row < (digits.length / 3).ceil(); row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int col = 0; col < 3; col++)
                  if (row * 3 + col < digits.length)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildNumberButton(
                        digits[row * 3 + col],
                        onPressed: () {
                          setState(() {
                            // Füge die Ziffer zur Sequenz hinzu
                            _userSequence += digits[row * 3 + col].toString();
                            _isSequenceCorrect = null;

                            // Sound-Feedback
                            AudioService().playWordPickupSound();

                            // Automatisch prüfen, wenn die Länge der Sequenz der Anzahl der Wörter entspricht
                            if (_userSequence.length == maxDigits) {
                              _checkSequence(gameState, sentence);
                            }
                          });
                        },
                      ),
                    ),
              ],
            ),
          ),
        // Überprüfen-Button
        if (_userSequence.isNotEmpty && _userSequence.length < maxDigits)
          ElevatedButton(
            onPressed: () => _checkSequence(gameState, sentence),
            child: Text('Check'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonBlue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
      ],
    );
  }

  // Numpad-Button
  Widget _buildNumberButton(int number, {required VoidCallback onPressed}) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black45,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: AppTheme.neonBlue.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Überprüft, ob die eingegebene Sequenz korrekt ist
  void _checkSequence(WordGameStateModel gameState, WordGameSentence sentence) {
    // Hole die korrekte Sequenz vom Satz
    final String correctSequence = sentence.getCorrectSequence();

    // Vergleiche die Benutzereingabe mit der korrekten Sequenz
    final bool isCorrect = _userSequence == correctSequence;

    setState(() {
      _isSequenceCorrect = isCorrect;
    });

    if (isCorrect) {
      // Spiele Erfolgs-Sound ab
      AudioService().playSuccessSound();

      // Leite zum nächsten Satz weiter
      Future.delayed(Duration(milliseconds: 1000), () {
        widget.onSolutionCorrect();
      });
    } else {
      // Spiele Fehler-Sound ab
      AudioService().playErrorSound();
    }
  }
}