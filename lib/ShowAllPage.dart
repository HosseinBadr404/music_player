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
  List<Map<String, String>> musicDataList = [];
  List<MusicCardItem> musicItems = [];

  @override
  void initState() {
    super.initState();
    _loadMusicFiles();
  }

  Future<void> _loadMusicFiles() async {
    List<Map<String, String>> dataList = [];
    String directoryPath = widget.isLocal
        ? '/storage/emulated/0/Music/musics'
        : '/storage/emulated/0/Download/dmusics';

    Directory directory = Directory(directoryPath);

    if (await directory.exists()) {
      await for (var file in directory.list(recursive: false)) {
        if (file is File && file.path.toLowerCase().endsWith('.mp3')) {
          final fileName = file.path.split('/').last.replaceAll('.mp3', '');

          // اضافه کردن داده‌ها به dataList
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
      musicDataList = dataList;

      // ایجاد آیتم‌ها با اطلاعات کامل
      musicItems = dataList.map((data) => MusicCardItem(
        title: data['title']!,
        artist: data['artist']!,
        image: data['image']!,
        audioPath: data['audioPath']!,
        playlist: dataList,
      )).toList();
    });
  }

  // اضافه کردن این متد برای به‌روزرسانی UI
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      setState(() {
        // به‌روزرسانی وضعیت نمایش
      });
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
                width: MediaQuery.of(context).size.width * 0.7,
                margin: EdgeInsets.symmetric(horizontal: 20),
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
  State<MusicCardItem> createState() => _MusicCardItemState();
}

class _MusicCardItemState extends State<MusicCardItem> {
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    globalAudioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    globalAudioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });
  }

  // اضافه کردن این متد برای به‌روزرسانی UI
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      setState(() {
        // به‌روزرسانی وضعیت نمایش
      });
    }
  }

  Future<void> _togglePlay() async {
    try {
      if (currentAudioPath == widget.audioPath && globalAudioPlayer.playing) {
        await globalAudioPlayer.pause();
      } else {
        await globalAudioPlayer.stop();
        currentAudioPath = widget.audioPath;

        // به‌روزرسانی پلی‌لیست جاری
        currentPlaylist = widget.playlist;
        currentPlayingIndex = widget.playlist.indexWhere((item) => item['audioPath'] == widget.audioPath);

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
        // ذخیره پلی‌لیست فعلی
        currentPlaylist = widget.playlist;
        currentPlayingIndex = widget.playlist.indexWhere((item) => item['audioPath'] == widget.audioPath);

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
              playlist: widget.playlist,
              currentIndex: currentPlayingIndex,
            ),
          ),
        ).then((_) {
          // وقتی از PlayerPage برمی‌گردید، وضعیت را به‌روز کنید
          if (mounted) {
            setState(() {});
          }
        });
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
