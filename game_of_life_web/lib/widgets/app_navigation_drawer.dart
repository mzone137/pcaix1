// lib/widgets/app_navigation_drawer.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/word_game_levels_screen.dart';
import '../screens/impressum_screen.dart'; // Diese Datei erstellen wir in Aufgabe 4

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({Key? key}) : super(key: key);

  @override
  _AppNavigationDrawerState createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  // Zustand der Expansion von Menüpunkten
  bool _isGamesExpanded = false;
  bool _isSettingsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: AppTheme.drawerHeaderDecoration,
            child: Row(
              children: [
                Icon(
                  Icons.psychology, // Neural Network Icon
                  size: 42,
                  color: AppTheme.primaryAccent,
                ),
                SizedBox(width: 16),
                Text(
                  'NEURAL NEXUS',
                  style: AppTheme.drawerHeaderTextStyle,
                ),
              ],
            ),
          ),

          // Liste der Navigationspunkte
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Home
                ListTile(
                  leading: Icon(Icons.home, color: AppTheme.primaryAccent),
                  title: Text('Home', style: AppTheme.drawerItemTextStyle),
                  onTap: () {
                    Navigator.pop(context); // Schließe Drawer
                    // Wenn bereits auf Home, mache nichts
                    if (ModalRoute.of(context)?.settings.name == '/') {
                      return;
                    }
                    // Navigiere zur Startseite
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),

                // Aufklappbarer Games-Menüpunkt
                ExpansionTile(
                  leading: Icon(Icons.games, color: AppTheme.primaryAccent),
                  title: Text('Games', style: AppTheme.drawerItemTextStyle),
                  initiallyExpanded: _isGamesExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isGamesExpanded = expanded;
                    });
                  },
                  children: [
                    // Game of Life Unterpunkt
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 56, right: 16),
                      leading: Icon(Icons.grid_4x4, color: AppTheme.primaryAccent),
                      title: Text('Game of Life', style: AppTheme.drawerItemTextStyle.copyWith(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context); // Schließe Drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                    ),

                    // Word Game Unterpunkt
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 56, right: 16),
                      leading: Icon(Icons.text_fields, color: AppTheme.primaryAccent),
                      title: Text('Word Game', style: AppTheme.drawerItemTextStyle.copyWith(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context); // Schließe Drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WordGameLevelsScreen()),
                        );
                      },
                    ),
                  ],
                ),

                // Aufklappbarer Settings-Menüpunkt
                ExpansionTile(
                  leading: Icon(Icons.settings, color: AppTheme.primaryAccent),
                  title: Text('Settings', style: AppTheme.drawerItemTextStyle),
                  initiallyExpanded: _isSettingsExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isSettingsExpanded = expanded;
                    });
                  },
                  children: [
                    // Sound Settings
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 56, right: 16),
                      leading: Icon(Icons.volume_up, color: AppTheme.primaryAccent),
                      title: Text('Sound Settings', style: AppTheme.drawerItemTextStyle.copyWith(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context); // Schließe Drawer
                        // Hier könnte eine Sound-Einstellungsseite angezeigt werden
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sound Settings - Coming soon')),
                        );
                      },
                    ),

                    // Display Settings
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 56, right: 16),
                      leading: Icon(Icons.display_settings, color: AppTheme.primaryAccent),
                      title: Text('Display Settings', style: AppTheme.drawerItemTextStyle.copyWith(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context); // Schließe Drawer
                        // Hier könnte eine Display-Einstellungsseite angezeigt werden
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Display Settings - Coming soon')),
                        );
                      },
                    ),
                  ],
                ),

                // Impressum - nicht aufklappbar
                ListTile(
                  leading: Icon(Icons.info, color: AppTheme.primaryAccent),
                  title: Text('Impressum', style: AppTheme.drawerItemTextStyle),
                  onTap: () {
                    Navigator.pop(context); // Schließe Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ImpressumScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer im Drawer
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppTheme.primaryAccent.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.copyright,
                  color: AppTheme.primaryText.withOpacity(0.5),
                  size: 14,
                ),
                SizedBox(width: 8),
                Text(
                  '${DateTime.now().year} Neural Nexus',
                  style: TextStyle(
                    color: AppTheme.primaryText.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}