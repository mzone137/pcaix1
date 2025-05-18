// Vereinfachte landing_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navigation_drawer.dart';
import '../utils/app_theme.dart';

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
      // AppBar hinzufügen mit Menü-Button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryAccent),
        // Die AppBar transparent und minimalistisch halten
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Heller Hintergrund
                Container(
                  color: AppTheme.creamBackground,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),

                          // Title ohne Glitch-Effekt
                          Center(
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppTheme.primaryAccent,
                                    AppTheme.primaryAccent.withOpacity(0.7),
                                    AppTheme.primaryAccent,
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                'NEURAL NEXUS',
                                style: AppTheme.titleStyle,
                                textAlign: TextAlign.center,
                              ),
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

                          // Beschreibungstext statt Buttons
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Welcome to Neural Nexus',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Explore our interactive experiences through the menu. Swipe from the left edge or tap the menu icon to navigate.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.primaryText.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                // Icon zur Verdeutlichung, dass es eine Seitenleiste gibt
                                Icon(
                                  Icons.menu,
                                  color: AppTheme.primaryAccent,
                                  size: 36,
                                ),
                              ],
                            ),
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
          // Footer bleibt unverändert
          const AppFooter(),
        ],
      ),
      // Hier die Navigation Drawer einbinden
      drawer: AppNavigationDrawer(),
    );
  }

}