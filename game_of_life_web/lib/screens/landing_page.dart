import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_game_models.dart';
import '../widgets/animated_background.dart';
import '../widgets/glitch_text.dart';
import '../utils/app_theme.dart';
import '../widgets/app_footer.dart';
import 'home_screen.dart';
import 'word_game_levels_screen.dart'; // Neue Import-Anweisung

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Animated Matrix-style Background
                const AnimatedBackground(),

                // Overlay with Semi-transparent Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        AppTheme.deepBlue.withOpacity(0.8),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Content
                SafeArea(
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),

                          // Title with Glitch Effect
                          Center(
                            child: GlitchText(
                              'NEURAL NEXUS',
                              style: AppTheme.titleStyle,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Subtitle
                          Center(
                            child: Text(
                              'EMERGENT INTELLIGENCE SYSTEMS',
                              style: AppTheme.subtitleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 80),

                          // Menu Items
                          _buildMenuItem(
                            icon: Icons.grid_4x4,
                            title: 'GAME OF LIFE',
                            subtitle: 'Interactive cellular automaton',
                            onTap: () => _navigateToGameOfLife(context),
                          ),

                          // Neu: Word Game Menüpunkt
                          _buildMenuItem(
                            icon: Icons.text_fields,
                            title: 'WORLDS WIDE WORDS OLYMPIC GAMES',
                            subtitle: 'Interactive word sequencing challenge',
                            onTap: () => _navigateToWordGame(context),
                          ),

                          _buildMenuItem(
                            icon: Icons.auto_graph,
                            title: 'NEURAL PATTERNS',
                            subtitle: 'Explore network topologies',
                            onTap: () => _showComingSoon(context),
                          ),

                          _buildMenuItem(
                            icon: Icons.biotech,
                            title: 'SYNTHETIC INTELLIGENCE',
                            subtitle: 'Simulated cognition experiments',
                            onTap: () => _showComingSoon(context),
                          ),

                          _buildMenuItem(
                            icon: Icons.data_array,
                            title: 'DATA MATRIX',
                            subtitle: 'Visualization framework',
                            onTap: () => _showComingSoon(context),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer now separated from the Stack
          const AppFooter(),
        ],
      ),
    );
  }


  void _navigateToWordGame(BuildContext context) {
    // Animation für den Übergang
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: Container(color: Colors.black),
        );
      },
      transitionDuration: Duration(milliseconds: 600),
    );

    Future.delayed(Duration(milliseconds: 2000), () {
      Navigator.of(context).pop(); // Schließe den schwarzen Übergang

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: Provider.of<WordGameStateModel>(context, listen: false)),
                ],
                child: const WordGameLevelsScreen(),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.easeOutQuint;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    });
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            border: Border.all(
              color: AppTheme.neonBlue.withOpacity(0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.neonBlue,
                size: 28.0,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.menuItemTitleStyle,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: AppTheme.menuItemSubtitleStyle,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGameOfLife(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.deepBlue,
        title: const Text(
          'COMING SOON',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This feature is currently in development.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: AppTheme.neonBlue),
            ),
          ),
        ],
      ),
    );
  }
}
