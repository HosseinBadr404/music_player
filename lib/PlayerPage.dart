import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_player_model.dart';
import 'dart:io';

class PlayerPage extends StatelessWidget {
  final List<Map<String, String>> playlist;
  final int currentIndex;

  const PlayerPage({
    super.key,
    required this.playlist,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final audioModel = Provider.of<AudioPlayerModel>(context);

    if (audioModel.currentTrack == null &&
        !audioModel.isPlaying &&
        currentIndex >= 0 &&
        currentIndex < playlist.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        audioModel.playTrack(playlist[currentIndex]['audioPath']!, playlist, currentIndex);
      });
    }

    final currentTrack = audioModel.currentTrack;

    if (currentTrack == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('No Track'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'No track selected',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          currentTrack['title']!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            // Album art with stylish container
            const SizedBox(height: 35),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              height: 350,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(140),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: currentTrack['image']!.startsWith('assets/')
                    ? Image.asset(
                  currentTrack['image']!,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(currentTrack['image']!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                currentTrack['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              currentTrack['artist']!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),

            // Progress bar and timing
            Padding(
              padding: const EdgeInsets.only(top: 10,right: 15,bottom: 25,left: 15),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                      thumbColor: Colors.white,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade800,
                      overlayColor: Colors.white.withOpacity(0.1),
                    ),
                    child: Slider(
                      value: audioModel.position.inSeconds.toDouble(),
                      max: audioModel.duration.inSeconds.toDouble() > 0 ? audioModel.duration.inSeconds.toDouble() : 1.0,
                      onChanged: (value) => audioModel.seekTo(Duration(seconds: value.toInt())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${audioModel.position.inMinutes}:${(audioModel.position.inSeconds % 60).toString().padLeft(2, '0')}",
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        Text(
                          "${audioModel.duration.inMinutes}:${(audioModel.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Spacer to push controls to bottom
            const SizedBox(height: 25),

            // All control buttons in one row
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle button
                  IconButton(
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: audioModel.isShuffleEnabled ? Colors.white : Colors.grey[600],
                      size: 28,
                    ),
                    onPressed: audioModel.toggleShuffle,
                  ),

                  // Previous button
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
                    onPressed: audioModel.playPrevious,
                  ),

                  // Play/Pause button
                  Container(
                    width: 65,
                    height: 65,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade200, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        audioModel.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.black,
                      ),
                      onPressed: audioModel.togglePlayPause,
                    ),
                  ),

                  // Next button
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
                    onPressed: audioModel.playNext,
                  ),

                  // Repeat button
                  IconButton(
                    icon: Icon(
                      audioModel.repeatMode == RepeatMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      color: audioModel.repeatMode != RepeatMode.off ? Colors.white : Colors.grey[600],
                      size: 28,
                    ),
                    onPressed: audioModel.toggleRepeat,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
