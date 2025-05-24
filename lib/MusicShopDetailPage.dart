import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'fake_user_data.dart';

class MusicShopDetailPage extends StatefulWidget {
  final String title;
  final String artist;
  final String image;
  final double rating;
  final double price;
  final bool isFree;
  final int downloads;
  final String audioFileName;

  const MusicShopDetailPage({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.rating,
    required this.price,
    required this.isFree,
    required this.downloads,
    required this.audioFileName,
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

  @override
  void initState() {
    super.initState();
    if (FakeUserData.currentUser != null) {
      isPurchased = FakeUserData.currentUser!.hasPurchased(widget.title);
    }

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

    // Create a download progress simulation
    double progress = 0.0;
    const int totalSteps = 100;

    for (int i = 0; i < totalSteps; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      setState(() {
        progress = (i + 1) / totalSteps;
      });
    }

    try {
      // استفاده از نام فایل مخصوص هر موزیک
      final ByteData data = await rootBundle.load('assets/${widget.audioFileName}');
      final List<int> bytes = data.buffer.asUint8List();

      // ایجاد مسیر دانلود
      final Directory downloadDir = Directory('/storage/emulated/0/Download/dmusics');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final File file = File('${downloadDir.path}/${widget.title}.mp3');
      await file.writeAsBytes(bytes);

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
    });
  }



  void _purchaseSong() async {
    if (FakeUserData.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to your account first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.isFree) {
      _downloadSong();
      return;
    }

    if (FakeUserData.currentUser!.isSubscriptionActive) {
      setState(() {
        isPurchased = true;
      });
      _downloadSong();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded with Premium subscription'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    if (FakeUserData.currentUser!.balance < widget.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // اگر موجودی کافی است، مستقیماً کم کن و دانلود کن
    bool success = FakeUserData.currentUser!.deductBalance(widget.price);

    if (success) {
      setState(() {
        isPurchased = true;
      });

      // اضافه کردن آهنگ به لیست خریداری شده
      FakeUserData.currentUser!.purchasedMusic.add(widget.title);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase successful! New balance: \$${FakeUserData.currentUser!.balance.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );

      // شروع دانلود
      _downloadSong();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing purchase'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }






  void _submitComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add(Comment(content: _commentController.text, likes: 0, dislikes: 0));
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = FakeUserData.isLoggedIn();
    bool hasSubscription = isLoggedIn && FakeUserData.currentUser!.isSubscriptionActive;
    bool isPurchased = isLoggedIn && FakeUserData.currentUser!.purchasedMusic.contains(widget.title);

    // بررسی اینکه آیا فایل دانلود شده یا نه
    bool isFileDownloaded = false; // اینجا باید چک کنید فایل روی دستگاه هست یا نه

    // منطق دکمه
    bool showPurchaseButton = !widget.isFree && !hasSubscription && !isPurchased;
    bool showDownloadButton = widget.isFree || hasSubscription || isPurchased;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Music Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Music Image with Gradient Overlay
                Container(
                  height: 400,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          widget.image,
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Music Info Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(Icons.star, '${widget.rating}', 'Rating'),
                          _buildStat(Icons.download, '${widget.downloads}', 'Downloads'),
                          _buildStat(
                            Icons.attach_money,
                            widget.isFree ? 'Free' : '\$${widget.price.toStringAsFixed(2)}',
                            'Price',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // User Rating (Centered)
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Rate this song:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    index < userRating ? Icons.star : Icons.star_border,
                                    color: Colors.yellow,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      userRating = index + 1.0;
                                    });
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !isLoggedIn
                                  ? Colors.grey
                                  : (showDownloadButton ? Colors.blue : Colors.orange),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: !isLoggedIn
                                ? null
                                : (isDownloading
                                ? null
                                : (showDownloadButton ? _downloadSong : _purchaseSong)),
                            child: Text(
                              !isLoggedIn
                                  ? 'Login Required'
                                  : (isDownloading
                                  ? 'Downloading...'
                                  : (hasSubscription
                                  ? 'Download Now (Premium)'
                                  : (isPurchased
                                  ? 'Download Now'
                                  : (widget.isFree
                                  ? 'Download Free'
                                  : 'Purchase for \$${widget.price.toStringAsFixed(2)}')))),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Comments Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Comment Input
                      TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _submitComment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(255, 255, 255, 0.07),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Submit Comment'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Comments List with Separators
                      comments.isEmpty
                          ? const Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width * 0.7,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        itemBuilder: (_, index) => ListTile(
                          title: Text(
                            comments[index].content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up, size: 16, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    comments[index].likes++;
                                  });
                                },
                              ),
                              Text(
                                '${comments[index].likes}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.thumb_down, size: 16, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    comments[index].dislikes++;
                                  });
                                },
                              ),
                              Text(
                                '${comments[index].dislikes}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class Comment {
  String content;
  int likes;
  int dislikes;

  Comment({required this.content, required this.likes, required this.dislikes});
}