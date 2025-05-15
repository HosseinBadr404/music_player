import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'audio_player_model.dart';
import 'PlayerPage.dart';
import 'MusicShopPage.dart';
import 'SignIn.dart';
import 'SignUp.dart';
import 'ShowAllPage.dart';

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioPlayerModel(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/music_shop': (context) => const MusicShopPage(),
          '/signin': (context) => const SignIn(),
          '/signup': (context) => const SignUp(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          textTheme: ThemeData.dark().textTheme.copyWith(
            bodySmall: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
            ),
            bodyLarge: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lora',
            ),
            titleLarge: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lora',
            ),
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
      await _loadMusicFiles();
    } else if (permissionStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enable audio permission in settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio permission is required')),
      );
    }
  }

  Future<void> _loadMusicFiles() async {
    final local = await _loadMusicFromDirectory('/storage/emulated/0/Music/musics', getExternalStorageDirectory);
    final downloaded = await _loadMusicFromDirectory('/storage/emulated/0/Download/dmusics', getDownloadsDirectory);
    setState(() {
      localMusics = local;
      downloadedMusics = downloaded;
    });
  }

  Future<List<MusicCard>> _loadMusicFromDirectory(String path, Future<Directory?> Function() getDir) async {
    Directory dir = Directory(path);
    if (!await dir.exists()) {
      final fallbackDir = await getDir();
      dir = Directory('${fallbackDir?.path ?? ''}/${path.split('/').last}');
    }

    if (!await dir.exists()) {
      return [];
    }

    final musicCards = <MusicCard>[];
    await for (final file in dir.list(recursive: false)) {
      if (file is File && file.path.toLowerCase().endsWith('.mp3')) {
        final fileName = file.path.split('/').last.replaceAll('.mp3', '');
        musicCards.add(MusicCard(
          title: fileName,
          artist: 'Unknown',
          image: 'assets/images/c1.jpg',
          audioPath: file.path,
          index: musicCards.length,
          musicList: musicCards,
        ));
      }
    }
    return musicCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              const Center(
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
              const SizedBox(height: 12),
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildSection(context, "Local Musics", localMusics, true),
              const SizedBox(height: 24),
              _buildSection(context, "Downloaded Musics", downloadedMusics, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.07),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        iconSize: 28,
        selectedFontSize: 16,
        unselectedFontSize: 16,
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: SizedBox(height: 40, child: Center(child: Icon(Icons.home))),
          ),
          BottomNavigationBarItem(
            label: 'Shop',
            icon: SizedBox(height: 40, child: Center(child: Icon(Icons.shopping_bag))),
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicShopPage()));
          }
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        hintText: 'type a music name ...',
        hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Poppins', fontSize: 17),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(36),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<MusicCard> musics, bool isLocal) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
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
                    builder: (_) => ShowAllPage(title: "Show All $title", isLocal: isLocal),
                  ),
                );
              },
              child: const Text("Show All", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 255,
          child: musics.isEmpty
              ? const Center(
            child: Text(
              'No music found',
              style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
            ),
          )
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: musics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, index) => musics[index],
          ),
        ),
      ],
    );
  }
}

class MusicCard extends StatelessWidget {
  final String title;
  final String artist;
  final String image;
  final String audioPath;
  final int index;
  final List<MusicCard> musicList;

  const MusicCard({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.audioPath,
    required this.index,
    required this.musicList,
  });

  @override
  Widget build(BuildContext context) {
    final audioModel = Provider.of<AudioPlayerModel>(context);

    if (musicList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot play this track')),
      );
      return const SizedBox.shrink();
    }

    final playlist = musicList
        .map((music) => {
      'title': music.title,
      'artist': music.artist,
      'image': music.image,
      'audioPath': music.audioPath,
    })
        .toList();
    final computedIndex = musicList.indexWhere((music) => music.audioPath == audioPath);
    final finalIndex = computedIndex >= 0 ? computedIndex : index;

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
                  if (finalIndex < 0 || playlist.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot play this track')),
                    );
                    return;
                  }
                  audioModel.playTrack(audioPath, playlist, finalIndex);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerPage(
                        playlist: playlist,
                        currentIndex: finalIndex,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (finalIndex < 0 || playlist.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cannot play this track')),
                            );
                            return;
                          }
                          audioModel.playTrack(audioPath, playlist, finalIndex);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlayerPage(
                                playlist: playlist,
                                currentIndex: finalIndex,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              artist,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (finalIndex < 0 || playlist.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cannot play this track')),
                          );
                          return;
                        }
                        if (audioModel.currentAudioPath == audioPath && audioModel.isPlaying) {
                          audioModel.togglePlayPause();
                        } else {
                          audioModel.playTrack(audioPath, playlist, finalIndex);
                        }
                      },
                      icon: Icon(
                        audioModel.currentAudioPath == audioPath && audioModel.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}