import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerPage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final String title;
  final String artist;
  final String image;
  final String audioPath;
  final bool isPlaying;
  final Duration position;

  const PlayerPage({
    super.key,
    required this.audioPlayer,
    required this.title,
    required this.artist,
    required this.image,
    required this.audioPath,
    required this.isPlaying,
    required this.position,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  bool _isPlaying = false;
  bool _isShuffling = false;
  LoopMode _loopMode = LoopMode.off;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.isPlaying;
    _position = widget.position;

    _initializeAudio();

    widget.audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
      }
    });
    widget.audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
    widget.audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration ?? Duration.zero);
      }
    });
  }

  Future<void> _initializeAudio() async {
    try {
      await widget.audioPlayer.setAsset(widget.audioPath);
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await widget.audioPlayer.pause();
    } else {
      await widget.audioPlayer.seek(_position);
      await widget.audioPlayer.play();
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffling = !_isShuffling;
      widget.audioPlayer.setShuffleModeEnabled(_isShuffling);
    });
  }

  void _toggleLoop() {
    setState(() {
      _loopMode = _loopMode == LoopMode.off ? LoopMode.one : LoopMode.off;
      widget.audioPlayer.setLoopMode(_loopMode);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                widget.image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              widget.artist,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
              onChanged: (value) {
                final newPos = Duration(seconds: value.toInt());
                widget.audioPlayer.seek(newPos);
              },
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
            ),
            Text(
              "${_formatTime(_position)} / ${_formatTime(_duration)}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),

            /// --- Controls Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isShuffling ? Icons.shuffle_on : Icons.shuffle),
                  color: _isShuffling ? Colors.greenAccent : Colors.white,
                  onPressed: _toggleShuffle,
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: () async {
                    final newPosition = _position - const Duration(seconds: 10);
                    await widget.audioPlayer.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  ),
                  iconSize: 70,
                  color: Colors.white,
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: () async {
                    final newPosition = _position + const Duration(seconds: 10);
                    if (newPosition < _duration) {
                      await widget.audioPlayer.seek(newPosition);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    _loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                  ),
                  color: _loopMode == LoopMode.one ? Colors.greenAccent : Colors.white,
                  onPressed: _toggleLoop,
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// --- Volume Slider ---
            Column(
              children: [
                const Text(
                  'Volume',
                  style: TextStyle(color: Colors.white),
                ),
                Slider(
                  value: _volume,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                      widget.audioPlayer.setVolume(value);
                    });
                  },
                  min: 0,
                  max: 1,
                  divisions: 10,
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
