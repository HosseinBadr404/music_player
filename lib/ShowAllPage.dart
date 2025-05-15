import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_player_model.dart';
import 'PlayerPage.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMusicFiles();
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
          final fileName = file.path.split('/').last.replaceAll('.mp3', '');
          dataList.add({
            'title': fileName,
            'artist': 'Unknown',
            'image': 'assets/images/c1.jpg',
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
    });
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
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: () {},
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
                : ListView.separated(
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
              child: Image.asset(
                image,
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