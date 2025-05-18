// lib/widgets/number_input_widget.dart - mit korrigiertem State-Management
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

  // Eindeutige Identifikatoren für aktuelles Level und Satz
  // Änderung: Nutze eine Kombination aus Kapitel und Satz ID
  String _currentIdentifier = "";

  @override
  void initState() {
    super.initState();
    // Sicherstellen, dass Sequenz zu Beginn leer ist
    _userSequence = "";
    _isSequenceCorrect = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final gameState = Provider.of<WordGameStateModel>(context, listen: false);

    // Erstelle einen eindeutigen Identifier aus Kapitel und Satz
    final chapter = gameState.currentChapter;
    final sentenceIndex = gameState.currentSentenceIndex;

    // Eindeutiger Identifier für die aktuelle Kombination aus Kapitel und Satz
    final newIdentifier = "${chapter?.hashCode}-$sentenceIndex";

    // Wenn sich der Identifier geändert hat, setze die Sequenz zurück
    if (_currentIdentifier != newIdentifier) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _userSequence = "";
            _isSequenceCorrect = null;
            _currentIdentifier = newIdentifier;
          });
        }
      });
    }
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
              style: TextStyle(color: AppTheme.primaryText),
            ),
          );
        }

        // Bestimme die maximale Anzahl an Ziffern (= Anzahl der Wörter)
        final int maxDigits = sentence.words.length;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, // Hellerer Hintergrund im Stil von landing_page
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryAccent.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              // Anweisungstext
              Text(
                'Enter the sequence of numbers for correct word order',
                style: TextStyle(
                  color: AppTheme.primaryText, // Dunkler Text für besseren Kontrast
                  fontSize: 18,
                  fontFamily: 'Orbitron',
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24),

              // Anzeige des Satzes mit Wörtern und Zahlen - Angepasstes Design
              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Hellerer Hintergrund
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryAccent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: buildWordListDisplay(sentence),
              ),

              SizedBox(height: 20),

              // Eingabefeld für die Sequenz - Angepasstes Design
              Container(
                height: 70,
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: _isSequenceCorrect == null
                      ? Colors.white
                      : _isSequenceCorrect == true
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSequenceCorrect == null
                        ? AppTheme.primaryAccent
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
                              ? AppTheme.primaryText.withOpacity(0.5)
                              : AppTheme.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_userSequence.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.backspace_outlined, color: AppTheme.primaryText.withOpacity(0.7)),
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

              // EINFACHES NUMPAD - Angepasstes Design
              Expanded(
                child: buildSimpleNumpad(maxDigits, gameState, sentence),
              ),

              // Reset-Button - Verbesserte Implementation
              TextButton.icon(
                onPressed: () {
                  // Lösung für Bug 2: Kompletter Reset und UI-aktualisierung
                  setState(() {
                    _userSequence = "";
                    _isSequenceCorrect = null;
                  });

                  // Fokus entfernen um eventuell hängende Fokus-Probleme zu lösen
                  FocusScope.of(context).unfocus();

                  // Erzwinge UI-Update nach kurzem Delay
                  Future.delayed(Duration.zero, () {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                },
                icon: Icon(Icons.refresh, color: AppTheme.primaryText.withOpacity(0.7)),
                label: Text(
                  'Reset',
                  style: TextStyle(color: AppTheme.primaryText.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Baut die Anzeige der Wörter mit ihren Zahlen - Angepasstes Design
  Widget buildWordListDisplay(WordGameSentence sentence) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: sentence.randomizedWordsWithIndices.entries.map((entry) {
        final int originalIndex = entry.value.key;
        final String word = entry.value.value;
        final int displayNumber = sentence.getDisplayNumberForWord(originalIndex);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent.withOpacity(0.1), // Helles Blau
            borderRadius: BorderRadius.circular(16),
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

  // VEREINFACHTES NUMPAD - Angepasstes Design
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
                          // Bug-Fix: Sicherstellen, dass Button-Klicks korrekt verarbeitet werden
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
            child: Text('Check', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
      ],
    );
  }

  // Numpad-Button - Angepasstes Design
  Widget _buildNumberButton(int number, {required VoidCallback onPressed}) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryText,
          shape: CircleBorder(),
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: AppTheme.primaryAccent.withOpacity(0.5),
            width: 2,
          ),
          elevation: 3, // Leichter Schatten für 3D-Effekt
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

      // Lösung für Bug 1: Setze die Sequenz zurück, BEVOR zum nächsten Satz gewechselt wird
      setState(() {
        _userSequence = "";
        _isSequenceCorrect = null;
      });

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