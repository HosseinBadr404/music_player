import 'dart:io';
import 'package:flutter/material.dart';
import 'PlayerPage.dart';
import 'main.dart';

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
    List<MusicCardItem> items = [];
    String directoryPath = widget.isLocal
        ? '/storage/emulated/0/Music/musics'
        : '/storage/emulated/0/Download/dmusics';

    Directory directory = Directory(directoryPath);

    if (await directory.exists()) {
      await for (var file in directory.list(recursive: false)) {
        if (file is File && file.path.toLowerCase().endsWith('.mp3')) {
          final fileName = file.path.split('/').last.replaceAll('.mp3', '');
          items.add(MusicCardItem(
            title: fileName,
            artist: 'Unknown',
            image: 'assets/images/c1.jpg', // Placeholder image
            audioPath: file.path,
          ));
        }
      }
    }

    setState(() {
      musicItems = items;
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(28),
            ),
            child: musicItems.isEmpty
                ? Center(
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
              padding: EdgeInsets.all(15),
              scrollDirection: Axis.vertical,
              itemCount: musicItems.length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                width: MediaQuery.of(context).size.width * 0.7, // عرض محدود
                margin: EdgeInsets.symmetric(horizontal: 20), // فاصله از چپ و راست
                color: Colors.grey.withOpacity(0.3),
              ),
              itemBuilder: (context, index) => musicItems[index],
            ),
          ),
        ),
      ),
    );
  }
}

class MusicCardItem extends StatefulWidget {
  final String title;
  final String artist;
  final String image;
  final String audioPath;

  const MusicCardItem({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.audioPath,
  });

  @override
  State<MusicCardItem> createState() => _MusicCardItemState();
}

class _MusicCardItemState extends State<MusicCardItem> {
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    globalAudioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _togglePlay() async {
    try {
      if (currentAudioPath == widget.audioPath && globalAudioPlayer.playing) {
        await globalAudioPlayer.pause();
      } else {
        await globalAudioPlayer.stop();
        currentAudioPath = widget.audioPath;
        await globalAudioPlayer.setFilePath(widget.audioPath);
        await globalAudioPlayer.play();
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing music')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPlaying = currentAudioPath == widget.audioPath && globalAudioPlayer.playing;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerPage(
              audioPlayer: globalAudioPlayer,
              title: widget.title,
              artist: widget.artist,
              image: widget.image,
              audioPath: widget.audioPath,
              isPlaying: isPlaying,
              position: _position,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                widget.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.artist,
                    style: TextStyle(
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
              onPressed: _togglePlay,
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