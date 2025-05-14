import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MusicShopDetailPage extends StatefulWidget {
  final String title;
  final String artist;
  final String image;
  final double rating;
  final double price;
  final bool isFree;
  final int downloads;

  const MusicShopDetailPage({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.rating,
    required this.price,
    required this.isFree,
    required this.downloads,
  });

  @override
  State<MusicShopDetailPage> createState() => _MusicShopDetailPageState();
}

class _MusicShopDetailPageState extends State<MusicShopDetailPage> {
  int _selectedIndex = 1;
  double userRating = 0;
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  bool isPurchased = false;
  bool isDownloading = false;
  bool hasSubscription = false; // Mock subscription status
  SortOption? _commentSortOption;

  @override
  void initState() {
    super.initState();
    // Mock comments
    comments = [
      Comment(content: 'Great song!', likes: 10, dislikes: 2),
      Comment(content: 'Not bad.', likes: 5, dislikes: 3),
    ];
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

  Future<void> _downloadSong() async {
    setState(() {
      isDownloading = true;
    });
    // Mock download
    try {
      final downloadDir = await getDownloadsDirectory();
      final filePath = '${downloadDir?.path}/dmusics/${widget.title}.mp3';
      final file = File(filePath);
      await file.create(recursive: true);
      // Simulate download by writing a placeholder
      await file.writeAsString('Mock audio file');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed: ${widget.title}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading: $e')),
      );
    }
    setState(() {
      isDownloading = false;
      isPurchased = true;
    });
  }

  void _purchaseSong() {
    // Mock purchase
    setState(() {
      isPurchased = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Song purchased: ${widget.title}')),
    );
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add(Comment(content: _commentController.text, likes: 0, dislikes: 0));
        _commentController.clear();
      });
    }
  }

  void _sortComments() {
    setState(() {
      if (_commentSortOption == SortOption.likes) {
        comments.sort((a, b) => b.likes.compareTo(a.likes));
      } else if (_commentSortOption == SortOption.dislikes) {
        comments.sort((a, b) => b.dislikes.compareTo(a.dislikes));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canDownload = widget.isFree || isPurchased || hasSubscription;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.image,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                widget.artist,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              Text(
                'Rating: ${widget.rating}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 10),
              Text('Rate this song:'),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < userRating ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                    ),
                    onPressed: () {
                      setState(() {
                        userRating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 10),
              if (canDownload)
                ElevatedButton(
                  onPressed: isDownloading ? null : _downloadSong,
                  child: Text(isDownloading ? 'Downloading...' : 'Download'),
                )
              else
                ElevatedButton(
                  onPressed: _purchaseSong,
                  child: Text('Purchase for \$${widget.price.toStringAsFixed(2)}'),
                ),
              SizedBox(height: 20),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitComment,
                child: Text('Submit Comment'),
              ),
              SizedBox(height: 10),
              DropdownButton<SortOption>(
                hint: Text('Sort comments by'),
                value: _commentSortOption,
                items: [
                  DropdownMenuItem(
                    value: SortOption.likes,
                    child: Text('Likes'),
                  ),
                  DropdownMenuItem(
                    value: SortOption.dislikes,
                    child: Text('Dislikes'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _commentSortOption = value;
                    _sortComments();
                  });
                },
              ),
              SizedBox(height: 10),
              ...comments.map((comment) => ListTile(
                title: Text(comment.content),
                subtitle: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, size: 16),
                      onPressed: () {
                        setState(() {
                          comment.likes++;
                        });
                      },
                    ),
                    Text('${comment.likes}'),
                    IconButton(
                      icon: Icon(Icons.thumb_down, size: 16),
                      onPressed: () {
                        setState(() {
                          comment.dislikes++;
                        });
                      },
                    ),
                    Text('${comment.dislikes}'),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class Comment {
  String content;
  int likes;
  int dislikes;

  Comment({required this.content, required this.likes, required this.dislikes});
}
enum SortOption { likes, dislikes }