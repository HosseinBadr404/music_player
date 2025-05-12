import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'PlayerPage.dart';
import 'SignIn.dart';
import 'ShowAllPage.dart';

// پخش‌کننده مشترک برای همه صفحات
final AudioPlayer globalAudioPlayer = AudioPlayer();
String? currentAudioPath;

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodySmall: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lora',
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lora',
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MusicCard> localMusics = [];
  List<MusicCard> downloadedMusics = [];

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadMusic();
  }

  Future<void> _requestPermissionsAndLoadMusic() async {
    final permissionStatus = await Permission.audio.request();
    if (permissionStatus.isGranted) {
      _loadMusicFiles();
    } else if (permissionStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio permission is required')),
      );
    } else if (permissionStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable audio permission in settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  Future<void> _loadMusicFiles() async {
    List<MusicCard> local = [];
    List<MusicCard> downloaded = [];

    Directory musicDir = Directory('/storage/emulated/0/Music/musics');
    Directory downloadDir = Directory('/storage/emulated/0/Download/dmusics');

    if (!await musicDir.exists()) {
      final externalDir = await getExternalStorageDirectory();
      musicDir = Directory('${externalDir?.path ?? ''}/musics');
    }
    if (!await downloadDir.exists()) {
      final dlDir = await getDownloadsDirectory();
      downloadDir = Directory('${dlDir?.path ?? ''}/dmusics');
    }

    if (await musicDir.exists()) {
      await for (var file in musicDir.list(recursive: false)) {
        if (file is File && file.path.toLowerCase().endsWith('.mp3')) {
          final fileName = file.path.split('/').last.replaceAll('.mp3', '');
          local.add(MusicCard(
            title: fileName,
            artist: 'Unknown',
            image: 'assets/images/c1.jpg',
            audioPath: file.path,
          ));
        }
      }
    }

    if (await downloadDir.exists()) {
      await for (var file in downloadDir.list(recursive: false)) {
        if (file is File && file.path.toLowerCase().endsWith('.mp3')) {
          final fileName = file.path.split('/').last.replaceAll('.mp3', '');
          downloaded.add(MusicCard(
            title: fileName,
            artist: 'Unknown',
            image: 'assets/images/c1.jpg',
            audioPath: file.path,
          ));
        }
      }
    }

    setState(() {
      localMusics = local;
      downloadedMusics = downloaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Stack(
          children: [
            BottomNavigationBar(
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.07),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              iconSize: 28,
              selectedFontSize: 16,
              unselectedFontSize: 16,
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
                }
              },
              items: [
                BottomNavigationBarItem(
                  label: 'Home',
                  icon: SizedBox(
                    height: 40,
                    child: Center(child: Icon(Icons.home)),
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'Shop',
                  icon: SizedBox(
                    height: 40,
                    child: Center(child: Icon(Icons.shopping_bag)),
                  ),
                ),
              ],
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 0.5,
              top: 20,
              bottom: 30,
              child: Container(
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              Center(
                child: Text(
                  "Home",
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: 'type a music name ...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                    fontSize: 17,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(36),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Local Musics",
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShowAllPage(
                            title: "Show All Local Musics",
                            isLocal: true,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Show All",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 255,
                child: localMusics.isEmpty
                    ? Center(
                  child: Text(
                    'No music found',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                )
                    : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: localMusics.length,
                  separatorBuilder: (context, index) => SizedBox(width: 14),
                  itemBuilder: (context, index) => localMusics[index],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Downloaded Musics",
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "show all",
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 255,
                child: downloadedMusics.isEmpty
                    ? Center(
                  child: Text(
                    'No music found',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                )
                    : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: downloadedMusics.length,
                  separatorBuilder: (context, index) => SizedBox(width: 14),
                  itemBuilder: (context, index) => downloadedMusics[index],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicCard extends StatefulWidget {
  final String title;
  final String artist;
  final String image;
  final String audioPath;

  const MusicCard({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.audioPath,
  });

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
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

    return SizedBox(
      width: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Container(
          color: Colors.grey.shade900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
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
                  padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      widget.image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: GestureDetector(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}