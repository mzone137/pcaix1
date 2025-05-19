// main.dart - Refaktorierte Version ohne Game of Life
import 'package:flutter/material.dart';
import 'package:game_of_life_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'domain/models/word_game_models.dart';
import 'screens/landing_page.dart';
import 'services/chiptune_service.dart';

void main() {
  // Flutter-Widgets initialisieren
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // GameStateModel Provider entfernt
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Nexus',
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