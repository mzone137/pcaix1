// lib/main.dart - Angepasst für AudioService-Initialisierung

import 'package:flutter/material.dart';
import 'package:game_of_life_app/services/chiptune_service.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart';
import 'models/word_game_models.dart';
import 'screens/landing_page.dart';
import 'services/audio_service.dart';

void main() async {
  // Stellen Sie sicher, dass Flutter-Widgets initialisiert sind
  WidgetsFlutterBinding.ensureInitialized();

  // Vorladen der Audio-Assets kann hier geschehen, wird aber zur Sicherheit auch
  // beim ersten Aufruf des Word-Games durchgeführt
  try {
    await AudioService().preloadSounds();
  } catch (e) {
    print('Warning: Could not preload audio assets: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameStateModel()),
        ChangeNotifierProvider(create: (context) => WordGameStateModel()),
        ChangeNotifierProvider(create: (_) => ChiptuneService()),
        Provider<AudioService>(create: (_) => AudioService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Nexus - Game of Life',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}