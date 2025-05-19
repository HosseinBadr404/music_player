import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_player_model.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'PlayerPage.dart';
import 'package:path_provider/path_provider.dart';

class ShowAllPage extends StatefulWidget {
  final String title;
  final bool isLocal;

  const ShowAllPage({
    super.key,
    required this.title,
    required this.isLocal,
  });

  @override
  State<ShowAllPage> createState() => _ShowAllPageState();
}

class _ShowAllPageState extends State<ShowAllPage> {
  List<MusicCardItem> musicItems = [];
  List<MusicCardItem> originalMusicItems = [];
  int _sortState = 0;

  @override
  void initState() {
    super.initState();
    _loadMusicFiles();
  }

  void _sortMusicItems() {
    setState(() {
      _sortState = (_sortState + 1) % 3;

      switch (_sortState) {
        case 0:
          musicItems = List.from(originalMusicItems);
          break;
        case 1:
          musicItems.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          break;
        case 2:
          musicItems.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
          break;
      }
    });
  }

  Future<void> _loadMusicFiles() async {
    final directoryPath = widget.isLocal
        ? '/storage/emulated/0/Music/musics'
        : '/storage/emulated/0/Download/dmusics';
    final directory = Directory(directoryPath);

    final dataList = <Map<String, String>>[];
    if (await directory.exists()) {
      await for (final file in directory.list(recursive: false)) {
        if (file is File && file.path.toLowerCase().endsWith('.mp3')) {
          String title = 'Unknown';
          String artist = 'Unknown';
          String image = 'assets/images/c1.jpg'; // پیش‌فرض اگر تصویری پیدا نشود

          try {
            final metadata = await MetadataRetriever.fromFile(File(file.path));
            title = metadata.trackName ?? file.path.split('/').last.replaceAll('.mp3', '');
            artist = metadata.trackArtistNames?.join(', ') ?? 'Unknown';
            if (metadata.albumArt != null) {
              final tempDir = await getTemporaryDirectory();
              final coverFile = File('${tempDir.path}/${title.replaceAll(' ', '_')}_cover.jpg');
              await coverFile.writeAsBytes(metadata.albumArt!);
              image = coverFile.path;
            }
          } catch (e) {
            print('Error reading metadata: $e');
            title = file.path.split('/').last.replaceAll('.mp3', '');
          }

          dataList.add({
            'title': title,
            'artist': artist,
            'image': image,
            'audioPath': file.path,
          });
        }
      }
    }

    setState(() {
      musicItems = dataList.map((data) => MusicCardItem(
        title: data['title']!,
        artist: data['artist']!,
        image: data['image']!,
        audioPath: data['audioPath']!,
        playlist: dataList,
      )).toList();
      originalMusicItems = List.from(musicItems);
    });
  }

  IconData _getSortIcon() {
    switch (_sortState) {
      case 0: return Icons.sort_rounded;
      case 1: return Icons.arrow_downward;
      case 2: return Icons.arrow_upward;
      default: return Icons.sort_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_getSortIcon(), color: Colors.white),
            onPressed: _sortMusicItems,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(28),
            ),
            child: musicItems.isEmpty
                ? const Center(
              child: Text(
                'No music found',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: ListView.separated(
                padding: const EdgeInsets.all(15),
                scrollDirection: Axis.vertical,
                itemCount: musicItems.length,
                separatorBuilder: (_, __) => Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.7,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.grey.withOpacity(0.3),
                ),
                itemBuilder: (_, index) => musicItems[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MusicCardItem extends StatelessWidget {
  final String title;
  final String artist;
  final String image;
  final String audioPath;
  final List<Map<String, String>> playlist;

  const MusicCardItem({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.audioPath,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    final audioModel = Provider.of<AudioPlayerModel>(context);
    final index = playlist.indexWhere((item) => item['audioPath'] == audioPath);
    final isPlaying = audioModel.currentAudioPath == audioPath && audioModel.isPlaying;

    return GestureDetector(
      onTap: () {
        audioModel.playTrack(audioPath, playlist, index);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerPage(
              playlist: playlist,
              currentIndex: index,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image.startsWith('assets/')
                  ? Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(image),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                if (audioModel.currentAudioPath == audioPath && audioModel.isPlaying) {
                  audioModel.togglePlayPause();
                } else {
                  audioModel.playTrack(audioPath, playlist, index);
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}