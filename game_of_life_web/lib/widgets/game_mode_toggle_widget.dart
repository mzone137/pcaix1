// lib/widgets/game_mode_toggle_widget.dart - Angepasst für helleres Design

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/word_game_models.dart';
import '../utils/app_theme.dart';

class GameModeToggleWidget extends StatelessWidget {
  const GameModeToggleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WordGameStateModel>(
      builder: (context, gameState, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Mode',
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Toggle für Drag & Drop
                  _buildToggleOption(
                    context: context,
                    icon: Icons.touch_app,
                    label: 'Drag & Drop',
                    isSelected: gameState.useDragAndDrop,
                    onTap: () {
                      if (!gameState.useDragAndDrop) {
                        gameState.toggleDragAndDrop(true);
                      }
                    },
                  ),

                  // Toggle für Zahlen-Eingabe (Standard)
                  _buildToggleOption(
                    context: context,
                    icon: Icons.dialpad,
                    label: 'Number Input',
                    isSelected: !gameState.useDragAndDrop,
                    onTap: () {
                      if (gameState.useDragAndDrop) {
                        gameState.toggleDragAndDrop(false);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryAccent : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryAccent : AppTheme.primaryText.withOpacity(0.5),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryText : AppTheme.primaryText.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}