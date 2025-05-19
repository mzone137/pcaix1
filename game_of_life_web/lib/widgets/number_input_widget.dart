// lib/widgets/number_input_widget.dart - Refaktorisierte Version, die WordGameInputBase verwendet

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/word_game_models.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'word_game_input_base.dart';

/// Eine Implementierung des WordGameInputBase für die Nummerneingabe-Variante.
class NumberInputWidget extends WordGameInputBase {
  const NumberInputWidget({
    Key? key,
    required super.onSolutionCorrect,
  }) : super(key: key);

  @override
  State<NumberInputWidget> createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends WordGameInputBaseState<NumberInputWidget> {
  // Benutzersequenz als String
  String _userSequence = "";

  @override
  Widget buildInstructionText() {
    return const Text(
      'Enter the sequence of numbers for correct word order',
      style: TextStyle(
        color: AppTheme.primaryText,
        fontSize: AppConstants.fontSizeMedium,
        fontFamily: 'Orbitron',
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void resetState() {
    setState(() {
      _userSequence = "";
    });

    // Explizit Fokus entfernen, um Fokus-Probleme zu vermeiden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  Widget buildContent(WordGameSentence sentence, WordGameStateModel gameState) {
    // Bestimme die maximale Anzahl an Ziffern (= Anzahl der Wörter)
    final int maxDigits = sentence.words.length;

    return Column(
      children: [
        // Anzeige des Satzes mit Wörtern und Zahlen
        Container(
          margin: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
            border: Border.all(
              color: AppTheme.primaryAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: _buildWordListDisplay(sentence),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Eingabefeld für die Sequenz
        Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _getInputFieldColor(),
            borderRadius: BorderRadius.circular(AppConstants.roundedCornerRadius),
            border: Border.all(
              color: _getInputFieldBorderColor(),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _userSequence.isEmpty ? 'Enter number sequence...' : _userSequence,
                  style: TextStyle(
                    color: _userSequence.isEmpty
                        ? AppTheme.primaryText.withOpacity(0.5)
                        : AppTheme.primaryText,
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_userSequence.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.backspace_outlined,
                      color: AppTheme.primaryText.withOpacity(0.7)),
                  onPressed: () {
                    setState(() {
                      if (_userSequence.isNotEmpty) {
                        _userSequence = _userSequence.substring(
                            0, _userSequence.length - 1);
                      }
                    });
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Numpad
        Expanded(
          child: _buildSimpleNumpad(maxDigits, gameState, sentence),
        ),
      ],
    );
  }

  // Hilfsmethode: Farbe für das Eingabefeld basierend auf Korrektheit
  Color _getInputFieldColor() {
    return isCorrect == null
        ? Colors.white
        : isCorrect == true
        ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1);
  }

  // Hilfsmethode: Randfarbe für das Eingabefeld basierend auf Korrektheit
  Color _getInputFieldBorderColor() {
    return isCorrect == null
        ? AppTheme.primaryAccent
        : isCorrect == true
        ? Colors.green
        : Colors.red;
  }

  // Baut die Anzeige der Wörter mit ihren Zahlen
  Widget _buildWordListDisplay(WordGameSentence sentence) {
    return Wrap(
      spacing: AppConstants.smallPadding,
      runSpacing: AppConstants.defaultPadding,
      alignment: WrapAlignment.center,
      children: sentence.randomizedWordsWithIndices.entries.map((entry) {
        final int originalIndex = entry.value.key;
        final String word = entry.value.value;
        final int displayNumber = sentence.getDisplayNumberForWord(originalIndex);

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word,
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: AppConstants.fontSizeDefault,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              // Zeige die Nummer in einem Kreis an
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryAccent.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    displayNumber.toString(),
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: AppConstants.fontSizeDefault,
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

  // Vereinfachtes Numpad
  Widget _buildSimpleNumpad(int maxDigits, WordGameStateModel gameState, WordGameSentence sentence) {
    // Erzeugen der Ziffern (beginnend bei 1 bis maxDigits)
    final List<int> digits = List.generate(maxDigits, (index) => index + 1);

    return LayoutBuilder(
        builder: (context, constraints) {
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
                              onPressed: () => _handleNumberPressed(
                                  digits[row * 3 + col],
                                  maxDigits,
                                  gameState,
                                  sentence),
                            ),
                          ),
                    ],
                  ),
                ),

              // Überprüfen-Button
              if (_userSequence.isNotEmpty && _userSequence.length < maxDigits)
                ElevatedButton(
                  onPressed: () => _checkSequence(gameState, sentence),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15),
                  ),
                  child: const Text('Check', style: TextStyle(color: Colors.white)),
                ),
            ],
          );
        }
    );
  }

  // Numpad-Button mit verbessertem Touch-Handling
  Widget _buildNumberButton(int number, {required VoidCallback onPressed}) {
    return SizedBox(
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryAccent.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handling für Nummer-Button-Tap
  void _handleNumberPressed(
      int number,
      int maxDigits,
      WordGameStateModel gameState,
      WordGameSentence sentence
      ) {
    // Entferne den Fokus
    FocusScope.of(context).unfocus();

    setState(() {
      // Füge die Ziffer zur Sequenz hinzu
      _userSequence += number.toString();

      // Play sound
      super.audioService.playWordPickupSound();

      // Automatisch prüfen, wenn die Länge der Sequenz der Anzahl der Wörter entspricht
      if (_userSequence.length == maxDigits) {
        _checkSequence(gameState, sentence);
      }
    });
  }

  // Überprüft die eingegebene Sequenz
  void _checkSequence(WordGameStateModel gameState, WordGameSentence sentence) {
    // Hole die korrekte Sequenz vom Satz
    final String correctSequence = sentence.getCorrectSequence();

    // Vergleiche die Benutzereingabe mit der korrekten Sequenz
    final bool isCorrect = _userSequence == correctSequence;

    if (isCorrect) {
      super.handleCorrectSolution();
    } else {
      super.handleIncorrectSolution();
    }
  }
}