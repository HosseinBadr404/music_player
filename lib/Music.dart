import 'dart:math';

class Music {
  final String title;
  final String artist;
  final String coverImage;
  final double price;
  final int downloads;
  final double rating;
  final String category;
  final String audioBase64;
  final String audioFileName;

  Music({
    required this.title,
    required this.artist,
    required this.coverImage,
    required this.price,
    required this.downloads,
    required this.rating,
    required this.category,
    required this.audioBase64,
    required this.audioFileName,
  });

  bool get isFree => price <= 0;
}

// Mock data for audio files
class MusicData {
  static final Random _random = Random();

  // Mock base64 audio data
  static String getMockAudioBase64() {
    return 'SGVsbG8sIHRoaXMgaXMgYSBtb2NrIGJhc2U2NCBlbmNvZGVkIGF1ZGlvIGZpbGUgZm9yIGRlbW9uc3RyYXRpb24gcHVycG9zZXMu';
  }

  static List<Music> getAllMusic() {
    return [
      // CLASSIC category
      Music(
        title: 'Symphony No. 9',
        artist: 'Beethoven',
        coverImage: 'assets/images/c1.jpg',
        price: 3.99,
        downloads: 12500,
        rating: 4.9,
        category: 'CLASSIC',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'The Four Seasons',
        artist: 'Vivaldi',
        coverImage: 'assets/images/c1.jpg',
        price: 2.99,
        downloads: 9800,
        rating: 4.7,
        category: 'CLASSIC',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'Moonlight Sonata',
        artist: 'Beethoven',
        coverImage: 'assets/images/c1.jpg',
        price: 1.99,
        downloads: 15300,
        rating: 4.8,
        category: 'CLASSIC',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'Für Elise',
        artist: 'Beethoven',
        coverImage: 'assets/images/c1.jpg',
        price: 0.00,
        downloads: 23000,
        rating: 4.5,
        category: 'CLASSIC',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),

      // POP category
      Music(
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        coverImage: 'assets/images/c1.jpg',
        price: 1.49,
        downloads: 45000,
        rating: 4.5,
        category: 'POP',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        coverImage: 'assets/images/c1.jpg',
        price: 1.99,
        downloads: 38000,
        rating: 4.7,
        category: 'POP',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'Bad Guy',
        artist: 'Billie Eilish',
        coverImage: 'assets/images/c1.jpg',
        price: 1.29,
        downloads: 42000,
        rating: 4.6,
        category: 'POP',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'As It Was',
        artist: 'Harry Styles',
        coverImage: 'assets/images/c1.jpg',
        price: 0.00,
        downloads: 50000,
        rating: 4.8,
        category: 'POP',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),

      // RAP category
      Music(
        title: 'Lose Yourself',
        artist: 'Eminem',
        coverImage: 'assets/images/c1.jpg',
        price: 1.99,
        downloads: 67000,
        rating: 4.9,
        category: 'RAP',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'SICKO MODE',
        artist: 'Travis Scott',
        coverImage: 'assets/images/c1.jpg',
        price: 1.49,
        downloads: 55000,
        rating: 4.6,
        category: 'RAP',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'God\'s Plan',
        artist: 'Drake',
        coverImage: 'assets/images/c1.jpg',
        price: 1.79,
        downloads: 62000,
        rating: 4.7,
        category: 'RAP',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'Humble',
        artist: 'Kendrick Lamar',
        coverImage: 'assets/images/c1.jpg',
        price: 0.00,
        downloads: 48000,
        rating: 4.5,
        category: 'RAP',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),

      // ROCK category
      Music(
        title: 'Bohemian Rhapsody',
        artist: 'Queen',
        coverImage: 'assets/images/c1.jpg',
        price: 2.49,
        downloads: 78000,
        rating: 4.9,
        category: 'ROCK',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'Sweet Child O\' Mine',
        artist: 'Guns N\' Roses',
        coverImage: 'assets/images/c1.jpg',
        price: 1.99,
        downloads: 65000,
        rating: 4.8,
        category: 'ROCK',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'Stairway to Heaven',
        artist: 'Led Zeppelin',
        coverImage: 'assets/images/c1.jpg',
        price: 2.29,
        downloads: 72000,
        rating: 4.9,
        category: 'ROCK',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
      Music(
        title: 'Back in Black',
        artist: 'AC/DC',
        coverImage: 'assets/images/c1.jpg',
        price: 0.00,
        downloads: 59000,
        rating: 4.7,
        category: 'ROCK',
        audioBase64: getMockAudioBase64(),
        audioFileName: 'sample_music.mp3',
      ),
    ];
  }

  static List<Music> getMusicByCategory(String category) {
    return getAllMusic().where((music) => music.category == category).toList();
  }
}
