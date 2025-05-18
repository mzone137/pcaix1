// lib/main.dart - Fokussiert auf Game of Life
import 'package:flutter/material.dart';
import 'package:game_of_life_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart';
import 'models/word_game_models.dart';
import 'screens/landing_page.dart';
import 'services/chiptune_service.dart';

void main() {
  // Stellen Sie sicher, dass Flutter-Widgets initialisiert sind
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameStateModel()),
        ChangeNotifierProvider(create: (context) => WordGameStateModel()),
        ChangeNotifierProvider(create: (context) => ChiptuneService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Nexus - Game of Life',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppTheme.primaryAccent,
        scaffoldBackgroundColor: AppTheme.creamBackground,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppTheme.primaryText),
          bodyMedium: TextStyle(color: AppTheme.primaryText),
        ),
      ),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }

}