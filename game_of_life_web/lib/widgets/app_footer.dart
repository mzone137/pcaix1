import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'chiptune_controller.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border(
          top: BorderSide(
            color: AppTheme.neonBlue.withOpacity(0.3),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© ${DateTime.now().year} NEURAL NEXUS SYSTEMS',
            style: AppTheme.captionStyle,
          ),
          const ChiptuneController(),
        ],
      ),
    );
  }
}
