import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'PlayerPage.dart';
import 'MusicShopPage.dart';
import 'LoginPage.dart';
import 'SignupPage.dart';

// پخش‌کننده مشترک برای همه صفحات
final AudioPlayer globalAudioPlayer = AudioPlayer();
// برای ردیابی موزیک در حال پخش
String? currentAudioPath;

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/music_shop': (context) => const MusicShopPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.balooBhaijaan2TextTheme(
          ThemeData.dark().textTheme.copyWith(
            bodySmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadMusic();
  }

  Future<void> _requestPermissionsAndLoadMusic() async {
    final permissionStatus = await Permission.audio.request();
    if (permissionStatus.isGranted) {
      print('Audio permission granted');
      await _loadMusicFiles();
    } else if (permissionStatus.isDenied) {
      print('Audio permission denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio permission is required to load music')),
      );
    } else if (permissionStatus.isPermanentlyDenied) {
      print('Audio permission permanently denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio permission is permanently denied. Please enable it in settings.'),
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

    try {
      Directory? musicDir = Directory('/storage/emulated/0/Music/musics');
      Directory? downloadDir = Directory('/storage/emulated/0/Download/dmusics');

      if (!await musicDir.exists()) {
        final externalDir = await getExternalStorageDirectory();
        musicDir = Directory('${externalDir?.path ?? ''}/musics');
        print('Fallback to external storage: ${musicDir.path}');
      }
      if (!await downloadDir.exists()) {
        final dlDir = await getDownloadsDirectory();
        downloadDir = Directory('${dlDir?.path ?? ''}/dmusics');
        print('Fallback to download directory: ${downloadDir.path}');
      }

      print('Checking music directory: ${musicDir.path}');
      print('Checking download directory: ${downloadDir.path}');

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
        print('Found ${local.length} local music files');
      } else {
        print('Music directory does not exist: ${musicDir.path}');
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
        print('Found ${downloaded.length} downloaded music files');
      } else {
        print('Download directory does not exist: ${downloadDir.path}');
      }
    } catch (e) {
      print('Error loading music files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading music: $e')),
        );
      }
    }

    if (mounted) {
      setState(() {
        localMusics = local;
        downloadedMusics = downloaded;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/music_shop');
    }
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
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
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
                child: Text("Home", style: Theme.of(context).textTheme.titleLarge),
              ),
              SizedBox(height: 12),
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'type a music name ...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(36),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 40),
              sectionTitle(context, "Local Musics"),
              SizedBox(height: 8),
              musicList(localMusics),
              SizedBox(height: 24),
              sectionTitle(context, "Downloaded Musics"),
              SizedBox(height: 8),
              musicList(downloadedMusics),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        Text("show all", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget musicList(List<MusicCard> cards) {
    return SizedBox(
      height: 255,
      child: cards.isEmpty
          ? Center(child: Text('No music found', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (context, index) => SizedBox(width: 14),
        itemBuilder: (context, index) => cards[index],
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
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
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
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error playing music: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing music: $e')),
        );
      }
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
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.artist,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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