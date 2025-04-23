import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

import 'PlayerPage.dart';

// یه پخش‌کننده مشترک برای همه صفحات
final AudioPlayer globalAudioPlayer = AudioPlayer();
// برای اینکه بدونیم کدوم موزیک در حال پخش هست
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              musicList([
                MusicCard(
                  title: 'Giant',
                  artist: 'Yuqi',
                  image: 'assets/images/c1.jpg',
                  audioPath: 'LMusics/m1.mp3',
                ),
                MusicCard(
                  title: 'Remedy',
                  artist: 'Annie',
                  image: 'assets/images/c2.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Dream',
                  artist: 'Lisa',
                  image: 'assets/images/c5.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Sky',
                  artist: 'John',
                  image: 'assets/images/c6.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Moon',
                  artist: 'Ella',
                  image: 'assets/images/c7.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Star',
                  artist: 'Mike',
                  image: 'assets/images/c8.jpg',
                  audioPath: 'music.mp3',
                ),
              ]),
              SizedBox(height: 24),
              sectionTitle(context, "Downloaded Musics"),
              SizedBox(height: 8),
              musicList([
                MusicCard(
                  title: 'Faith',
                  artist: 'Nurko',
                  image: 'assets/images/c3.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Remedy',
                  artist: 'Annie',
                  image: 'assets/images/c4.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Light',
                  artist: 'Sara',
                  image: 'assets/images/c9.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Echo',
                  artist: 'Tom',
                  image: 'assets/images/c10.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Wave',
                  artist: 'Luna',
                  image: 'assets/images/c11.jpg',
                  audioPath: 'music.mp3',
                ),
                MusicCard(
                  title: 'Glow',
                  artist: 'Alex',
                  image: 'assets/images/c12.jpg',
                  audioPath: 'music.mp3',
                ),
              ]),
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
      child: ListView.separated(
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
  bool _isPlaying = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    globalAudioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing && currentAudioPath == widget.audioPath;
        });
      }
    });
    globalAudioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  Future<void> _togglePlay() async {
    if (_isPlaying && currentAudioPath == widget.audioPath) {
      await globalAudioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await globalAudioPlayer.stop();
      currentAudioPath = widget.audioPath;
      await globalAudioPlayer.play(AssetSource(widget.audioPath));
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        isPlaying: _isPlaying,
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
                                isPlaying: _isPlaying,
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
                        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
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