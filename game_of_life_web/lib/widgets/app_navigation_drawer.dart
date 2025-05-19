// app_navigation_drawer.dart - Ohne Game of Life Menüpunkt
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
// HomeScreen Import entfernt
import '../screens/word_game_levels_screen.dart';
import '../screens/impressum_screen.dart';

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({Key? key}) : super(key: key);

  @override
  _AppNavigationDrawerState createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
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
                  Icons.psychology,
                  size: 36,
                  color: AppTheme.primaryAccent,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'NEURAL NEXUS',
                      style: AppTheme.drawerHeaderTextStyle.copyWith(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Home
                ListTile(
                  leading: Icon(Icons.home, color: AppTheme.primaryAccent),
                  title: Text('Home', style: AppTheme.drawerItemTextStyle),
                  onTap: () {
                    Navigator.pop(context);
                    if (ModalRoute.of(context)?.settings.name == '/') {
                      return;
                    }
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),

                // Word Game - jetzt direkt statt unter Games
                ListTile(
                  leading: Icon(Icons.text_fields, color: AppTheme.primaryAccent),
                  title: Text('Word Game', style: AppTheme.drawerItemTextStyle),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WordGameLevelsScreen()),
                    );
                  },
                ),

                // Settings
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
                        Navigator.pop(context);
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
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Display Settings - Coming soon')),
                        );
                      },
                    ),
                  ],
                ),

                // Impressum
                ListTile(
                  leading: Icon(Icons.info, color: AppTheme.primaryAccent),
                  title: Text('Impressum', style: AppTheme.drawerItemTextStyle),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ImpressumScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer
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