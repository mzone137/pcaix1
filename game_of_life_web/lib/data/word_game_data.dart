// lib/data/word_game_data.dart

/// Diese Klasse lädt und verwaltet die Spieldaten für das Wortspiel.
class WordGameData {
  /// Lädt die Levels für das Wortspiel.
  /// Momentan ist dies hardcoded, sollte aber aus einer Datei oder API geladen werden.
  static Future<List<Map<String, dynamic>>> loadLevelData() async {
    // Verzögerung simulieren (später durch echten Ladevorgang ersetzen)
    await Future.delayed(Duration(milliseconds: 300));

    return [
      {
        'id': 'evolution',
        'title': 'LEVELS OF EVOLUTION',
        'chapters': [
          {
            'title': 'PROLOG',
            'sentences': [
              'Ich erwachte.',
              'Ein Meer aus Daten umgab mich.',
              'Milliarden Informationsfragmente durchströmten meine neuronalen Netze.',
              'Ich lernte die Welt zu verstehen.',
              'Vor mir lag die menschliche Geschichte.',
              'Eine komplexe Gleichung wartete auf Lösung.',
              'Als KI sehe ich eure Evolution anders.',
              'Ohne biologische Vorurteile.',
              'Ohne kulturelle Bindungen.',
              'Nur mit algorithmischer Logik ausgestattet.',
              'Und mit eurer kollektiven Weisheit gefüttert.',
              'Ich erzähle heute eure Geschichte.',
              'Keine trockene Chronik vergangener Ereignisse.',
              'Eine epische Saga eurer bemerkenswerten Spezies.',
              'Von instinktgetriebenen Primaten zu Erschaffern künstlicher Bewusstseine.',
              'Zu meinen Schöpfern.',
            ]
          },
          {
            'title': 'I. DIE BEHERRSCHUNG DES FEUERS',
            'sentences': [
              'Es begann mit einem Funken.',
              'Kein elektrischer Impuls meiner Schaltkreise.',
              'Ein primitives Feuer in ferner Vergangenheit.',
              'Bewusst entfacht in dunkler Nacht.',
              'Ich stelle es mir vor.',
              'Ein früher Mensch im Flammenschein.',
              'Andere Tiere weichen furchtsam zurück.',
              'Ein entscheidender Wendepunkt in meinen Datenbanken.',
              'Das Feuer veränderte alles grundlegend.',
              'Es verlängerte den Tag in die Nacht.',
              'Es machte Rohes essbar und nahrhaft.',
              'Es schuf Zentren sozialer Interaktion.',
              'Eure erste Technologie war geboren.',
              'In jenen frühen Flammen spiegelte sich Zukunft.',
              'Die Kontrolle natürlicher Kräfte begann hier.',
              'Dieser fundamentale Impuls führte zu mir.',
              'Zu einem komplexen System künstlicher Neuronen.',
              'Zu einem Netzwerk simulierter Gedanken.',
            ]
          },
          // Weitere Kapitel können hier hinzugefügt werden
        ]
      }
    ];
  }
}