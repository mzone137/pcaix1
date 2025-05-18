// Vereinfachte Version für chiptune_controller.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chiptune_service.dart';
import '../utils/app_theme.dart';

class ChiptuneController extends StatelessWidget {
  const ChiptuneController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChiptuneService>(
      builder: (context, chiptuneService, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.neonBlue.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_note,
                color: _getTrackColor(chiptuneService.currentTrack),
                size: 18,
              ),
              const SizedBox(width: 8),

              // Track Name
              Text(
                chiptuneService.trackNames[chiptuneService.currentTrack] ?? 'Unknown',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(width: 12),

              // Play/Pause Button
              IconButton(
                icon: Icon(
                  chiptuneService.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppTheme.neonBlue,
                  size: 14,
                ),
                onPressed: () => chiptuneService.togglePlayback(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 24, height: 24),
              ),

              const SizedBox(width: 8),

              // Next Track Button
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: AppTheme.neonBlue,
                  size: 14,
                ),
                onPressed: () => chiptuneService.nextTrack(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 24, height: 24),
              ),

              const SizedBox(width: 10),

              // Volume Slider (vereinfacht)
              SizedBox(
                width: 60,
                child: Slider(
                  value: chiptuneService.volume,
                  onChanged: (newValue) => chiptuneService.setVolume(newValue),
                  activeColor: AppTheme.neonBlue,
                  inactiveColor: AppTheme.neonBlue.withOpacity(0.3),
                  min: 0.0,
                  max: 1.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Track-spezifische Farbe zurückgeben
  Color _getTrackColor(ChiptuneTrack track) {
    switch (track) {
      case ChiptuneTrack.zelda:
        return Colors.green;
      case ChiptuneTrack.pokemon:
        return Colors.yellow;
      case ChiptuneTrack.onePiece:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}