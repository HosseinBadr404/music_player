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
        title: Text(currentTrack['title']!),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: currentTrack['image']!.startsWith('assets/')
                            ? Image.asset(
                          currentTrack['image']!,
                          width: double.infinity,
                          height: 370,
                          fit: BoxFit.cover,
                        )
                            : Image.file(
                          File(currentTrack['image']!),
                          width: double.infinity,
                          height: 370,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Text(
                        currentTrack['title']!,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        currentTrack['artist']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              Text(
                "${audioModel.position.inMinutes}:${(audioModel.position.inSeconds % 60).toString().padLeft(2, '0')} / "
                    "${audioModel.duration.inMinutes}:${(audioModel.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Slider(
                value: audioModel.position.inSeconds.toDouble(),
                max: audioModel.duration.inSeconds.toDouble() > 0 ? audioModel.duration.inSeconds.toDouble() : 1.0,
                onChanged: (value) => audioModel.seekTo(Duration(seconds: value.toInt())),
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white),
                    onPressed: audioModel.currentIndex > 0 ? audioModel.playPrevious : null,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      audioModel.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      size: 80,
                      color: Colors.white,
                    ),
                    onPressed: audioModel.togglePlayPause,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
                    onPressed: audioModel.currentIndex < playlist.length - 1 ? audioModel.playNext : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
