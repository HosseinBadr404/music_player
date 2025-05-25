import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// Enum to represent different repeat modes for the player
enum RepeatMode {
  off,
  all,
  one,
}

class AudioPlayerModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, String>> _playlist = [];
  int _currentIndex = -1;
  String _currentAudioPath = '';
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<int> _shuffledIndices = [];
  AudioPlayer get audioPlayer => _audioPlayer;
  List<Map<String, String>> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  String get currentAudioPath => _currentAudioPath;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  Map<String, String>? get currentTrack =>
      _currentIndex >= 0 && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;

  // Constructor that sets up audio player listeners
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
        _onPlayerComplete();
      }
    });
  }

  //shuffle mode on,off
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    if (_isShuffleEnabled) {
      _generateShuffledPlaylist();
    }
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  //Generate a shuffled version of the playlist indices
  void _generateShuffledPlaylist() {
    _shuffledIndices = List.generate(_playlist.length, (index) => index);
    _shuffledIndices.shuffle();

    // If a track is currently playing move it to the front of the shuffled list
    if (_currentIndex >= 0 && _currentIndex < _shuffledIndices.length) {
      int currentTrackIndex = _shuffledIndices.indexOf(_currentIndex);
      if (currentTrackIndex != -1) {
        _shuffledIndices.removeAt(currentTrackIndex);
        _shuffledIndices.insert(0, _currentIndex);
      }
    }
  }

  int _getNextIndex() {
    if (_playlist.isEmpty) return -1;
    if (_isShuffleEnabled) {
      if (_shuffledIndices.isEmpty) {
        _generateShuffledPlaylist();
      }
      int currentShuffleIndex = _shuffledIndices.indexOf(_currentIndex);
      if (currentShuffleIndex < _shuffledIndices.length - 1) {
        return _shuffledIndices[currentShuffleIndex + 1];
      } else {
        if (_repeatMode == RepeatMode.all) {
          _generateShuffledPlaylist();
          return _shuffledIndices.first;
        }
        return -1; //End of playlist (no repeat)
      }
    } else {
      if (_currentIndex < _playlist.length - 1) {
        return _currentIndex + 1;
      } else if (_repeatMode == RepeatMode.all) {
        return 0;
      }
      return -1;
    }
  }

  int _getPreviousIndex() {
    if (_playlist.isEmpty) return -1;
    if (_isShuffleEnabled) {
      if (_shuffledIndices.isEmpty) {
        _generateShuffledPlaylist();
      }
      int currentShuffleIndex = _shuffledIndices.indexOf(_currentIndex);
      if (currentShuffleIndex > 0) {
        return _shuffledIndices[currentShuffleIndex - 1];
      } else {
        return _shuffledIndices.last;
      }
    } else {
      if (_currentIndex > 0) {
        return _currentIndex - 1;
      } else {
        return _playlist.length - 1;
      }
    }
  }

  //Handler for when a track completes playback
  void _onPlayerComplete() {
    if (_repeatMode == RepeatMode.one) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else {
      int nextIndex = _getNextIndex();
      if (nextIndex != -1) {
        playTrack(_playlist[nextIndex]['audioPath']!, _playlist, nextIndex);
      } else {
        _isPlaying = false;
        _position = Duration.zero;
        notifyListeners();
      }
    }
  }

  Future<void> playTrack(String audioPath, List<Map<String, String>> playlist, int index) async {
    try {
      if (index < 0 || index >= playlist.length) {
        return;
      }

      //If same track is already playing and playing do nothing
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
    } catch (e) {
    }
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
    int nextIndex = _getNextIndex();
    if (nextIndex != -1) {
      await playTrack(_playlist[nextIndex]['audioPath']!, _playlist, nextIndex);
    } else {
      await _audioPlayer.stop();
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    }
  }

  Future<void> playPrevious() async {
    int previousIndex = _getPreviousIndex();
    if (previousIndex != -1) {
      await playTrack(_playlist[previousIndex]['audioPath']!, _playlist, previousIndex);
    }
  }

  //Clean up resources when model is disposed
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}