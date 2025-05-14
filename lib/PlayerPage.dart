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
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.isPlaying;
    _position = widget.position;

    widget.audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });
    widget.audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
    widget.audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await widget.audioPlayer.pause();
    } else {
      await widget.audioPlayer.seek(_position);
      await widget.audioPlayer.play();
    }
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
        padding: EdgeInsets.all(20),
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
            SizedBox(height: 30),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              widget.artist,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / "
                  "${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}",
              style: TextStyle(color: Colors.white),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                size: 80,
                color: Colors.white,
              ),
              onPressed: _togglePlayPause,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}