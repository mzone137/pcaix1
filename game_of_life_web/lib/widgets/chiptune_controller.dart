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
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withOpacity(0.2),
                blurRadius: 10.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pixelated Note Icon
              _buildPixelatedIcon(
                Icons.music_note,
                color: _getTrackColor(chiptuneService.currentTrack),
                size: 18,
              ),
              const SizedBox(width: 8),
              
              // Track Name mit Glitch-Effekt
              _buildTrackName(chiptuneService),
              
              const SizedBox(width: 12),
              
              // Play/Pause Button
              _buildPixelatedButton(
                icon: chiptuneService.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppTheme.neonBlue,
                onPressed: () => chiptuneService.togglePlayback(),
                tooltip: chiptuneService.isPlaying ? 'Pause' : 'Play',
              ),
              
              const SizedBox(width: 8),
              
              // Next Track Button
              _buildPixelatedButton(
                icon: Icons.skip_next,
                color: AppTheme.neonBlue,
                onPressed: () => chiptuneService.nextTrack(),
                tooltip: 'Next Track',
              ),
              
              const SizedBox(width: 10),
              
              // Volume Slider
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
        return AppTheme.matrixGreen;
    }
  }

  // Pixelated Icon für 16-Bit Look
  Widget _buildPixelatedIcon(IconData icon, {required Color color, required double size}) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }

  // Pixelated Button für 16-Bit Look
  Widget _buildPixelatedButton({
    required IconData icon, 
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _buildPixelatedIcon(icon, color: color, size: 14),
          ),
        ),
      ),
    );
  }

  // Track-Name mit 16-Bit Stilisierung
  Widget _buildTrackName(ChiptuneService service) {
    final trackName = service.trackNames[service.currentTrack] ?? 'Unknown';
    final color = _getTrackColor(service.currentTrack);
    
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ).createShader(bounds);
      },
      child: Text(
        trackName,
        style: const TextStyle(
          fontFamily: 'Courier', // Typewriter/Pixelated Look
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
