import 'package:flutter/material.dart';
import 'MusicShopDetailPage.dart';
import 'package:music_player/Music.dart';

class MusicShopListPage extends StatefulWidget {
  final String category;

  const MusicShopListPage({super.key, required this.category});

  @override
  State<MusicShopListPage> createState() => _MusicShopListPageState();
}
enum SortOption { rating, price, downloads }

class _MusicShopListPageState extends State<MusicShopListPage> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  List<ShopMusicCard> musicList = [];
  List<ShopMusicCard> filteredMusicList = [];
  SortOption? _sortOption;
  bool hasSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadMusic();
    _searchController.addListener(_filterMusic);
  }

  void _loadMusic() {
    List<Music> musicData = MusicData.getMusicByCategory(widget.category);

    musicList = musicData.map((music) => ShopMusicCard(
      title: music.title,
      artist: music.artist,
      image: music.coverImage,
      rating: music.rating,
      price: music.price,
      isFree: music.isFree,
      downloads: music.downloads,
      category: music.category,
    )).toList();

    filteredMusicList = musicList;
  }

  void _filterMusic() {
    setState(() {
      filteredMusicList = musicList.where((song) {
        return song.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            song.artist.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
      _sortMusic();
    });
  }

  void _sortMusic() {
    setState(() {
      if (_sortOption == SortOption.rating) {
        filteredMusicList.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_sortOption == SortOption.price) {
        filteredMusicList.sort((a, b) => a.price.compareTo(b.price));
      } else if (_sortOption == SortOption.downloads) {
        filteredMusicList.sort((a, b) => b.downloads.compareTo(a.downloads));
      }
    });
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Stack(
          children: [
            BottomNavigationBar(
              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.07),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${widget.category} Musics',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    flex: 80,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.grey , fontSize: 17),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort button (20% width)
                  Expanded(
                    flex: 20,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: PopupMenuButton<SortOption>(
                        icon: const Icon(Icons.sort, color: Colors.white),
                        offset: const Offset(0, 50),
                        color: Colors.grey[900],
                        onSelected: (SortOption option) {
                          setState(() {
                            _sortOption = option;
                            _sortMusic();
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
                          const PopupMenuItem<SortOption>(
                            value: SortOption.rating,
                            child: Text('Rating', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.price,
                            child: Text('Price', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.downloads,
                            child: Text('Downloads', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: filteredMusicList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MusicShopDetailPage(
                              title: filteredMusicList[index].title,
                              artist: filteredMusicList[index].artist,
                              image: filteredMusicList[index].image,
                              rating: filteredMusicList[index].rating,
                              price: filteredMusicList[index].price,
                              isFree: filteredMusicList[index].isFree,
                              downloads: filteredMusicList[index].downloads,
                            ),
                          ),
                        );
                      },
                      child: filteredMusicList[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  class ShopMusicCard extends StatelessWidget {
  final String title;
  final String artist;
  final String image;
  final double rating;
  final double price;
  final bool isFree;
  final int downloads;
  final String category;

  const ShopMusicCard({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.rating,
    required this.price,
    required this.isFree,
    required this.downloads,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicShopDetailPage(
              title: title,
              artist: artist,
              image: image,
              rating: rating,
              price: price,
              isFree: isFree,
              downloads: downloads,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                image,
                width: 78,
                height: 78,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    artist,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    'Rating: $rating',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              isFree ? 'Free' : '\$${price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}