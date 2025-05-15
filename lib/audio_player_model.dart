import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, String>> _playlist = [];
  int _currentIndex = -1;
  String _currentAudioPath = '';
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Map<String, String>> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  String get currentAudioPath => _currentAudioPath;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;

  Map<String, String>? get currentTrack =>
      _currentIndex >= 0 && _currentIndex < _playlist.length ? _playlist[_currentIndex] : null;

  AudioPlayerModel() {
    _audioPlayer.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Future<void> playTrack(String audioPath, List<Map<String, String>> playlist, int index) async {
    try {
      if (index < 0 || index >= playlist.length) {
        return;
      }
      if (_currentAudioPath == audioPath && _isPlaying) {
        return;
      }
      if (_currentAudioPath == audioPath && !_isPlaying) {
        await _audioPlayer.play();
      } else {
        await _audioPlayer.stop();
        _currentAudioPath = audioPath;
        _playlist = List.from(playlist);
        _currentIndex = index;
        await _audioPlayer.setFilePath(audioPath);
        await _audioPlayer.play();
      }
      notifyListeners();
    } catch (e) {}
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      final nextIndex = _currentIndex + 1;
      await playTrack(_playlist[nextIndex]['audioPath']!, _playlist, nextIndex);
    } else {
      await _audioPlayer.stop();
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    }
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      final prevIndex = _currentIndex - 1;
      await playTrack(_playlist[prevIndex]['audioPath']!, _playlist, prevIndex);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}