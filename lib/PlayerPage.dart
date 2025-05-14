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
  final List<Map<String, String>>? playlist;
  final int currentIndex;

  const PlayerPage({
    super.key,
    required this.audioPlayer,
    required this.title,
    required this.artist,
    required this.image,
    required this.audioPath,
    required this.isPlaying,
    required this.position,
    this.playlist,
    this.currentIndex = 0,
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
    // گوش دادن به اتمام آهنگ
    widget.audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && mounted) {
        _playNext();
      }
    });

    // تنظیم آهنگ اولیه
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    if (widget.audioPath.isNotEmpty) {
      try {
        await widget.audioPlayer.setFilePath(widget.audioPath);
        await widget.audioPlayer.seek(widget.position);
        if (widget.isPlaying) {
          await widget.audioPlayer.play();
        }
      } catch (e) {
        print('Error initializing audio: $e');
      }
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

  Future<void> _seekTo(double value) async {
    final newPosition = Duration(seconds: value.toInt());
    await widget.audioPlayer.seek(newPosition);
  }

  Future<void> _playPrevious() async {
    if (widget.playlist == null || widget.currentIndex <= 0) return;
    final prevIndex = widget.currentIndex - 1;
    final prevTrack = widget.playlist![prevIndex];
    await widget.audioPlayer.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          audioPlayer: widget.audioPlayer,
          title: prevTrack['title']!,
          artist: prevTrack['artist']!,
          image: prevTrack['image']!,
          audioPath: prevTrack['audioPath']!,
          isPlaying: true,
          position: Duration.zero,
          playlist: widget.playlist,
          currentIndex: prevIndex,
        ),
      ),
    );
  }

  Future<void> _playNext() async {
    if (widget.playlist == null || widget.currentIndex >= widget.playlist!.length - 1) {
      await widget.audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
      return;
    }
    final nextIndex = widget.currentIndex + 1;
    final nextTrack = widget.playlist![nextIndex];
    await widget.audioPlayer.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          audioPlayer: widget.audioPlayer,
          title: nextTrack['title']!,
          artist: nextTrack['artist']!,
          image: nextTrack['image']!,
          audioPath: nextTrack['audioPath']!,
          isPlaying: true,
          position: Duration.zero,
          playlist: widget.playlist,
          currentIndex: nextIndex,
        ),
      ),
    );
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
                height: 370,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 35),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 15),
            Text(
              widget.artist,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 25),
            Text(
              "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / "
                  "${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
              onChanged: (value) => _seekTo(value),
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, size: 40, color: Colors.white),
                  onPressed: widget.currentIndex > 0 ? _playPrevious : null,
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 80,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 40, color: Colors.white),
                  onPressed: widget.playlist != null &&
                      widget.currentIndex < widget.playlist!.length - 1
                      ? _playNext
                      : null,
                ),
              ],
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}