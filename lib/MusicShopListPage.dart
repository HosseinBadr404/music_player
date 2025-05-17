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
  bool hasSubscription = false; // Mock subscription status

  @override
  void initState() {
    super.initState();
    _loadMusic();
    _searchController.addListener(_filterMusic);
  }

  void _loadMusic() {
    // Use the music data from our model
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
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search music...',
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
              SizedBox(height: 10),
              DropdownButton<SortOption>(
                hint: Text('Sort by'),
                value: _sortOption,
                items: [
                  DropdownMenuItem(
                    value: SortOption.rating,
                    child: Text('Rating'),
                  ),
                  DropdownMenuItem(
                    value: SortOption.price,
                    child: Text('Price'),
                  ),
                  DropdownMenuItem(
                    value: SortOption.downloads,
                    child: Text('Downloads'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortOption = value;
                    _sortMusic();
                  });
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: filteredMusicList.isEmpty
                    ? Center(child: Text('No music found', style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                  itemCount: filteredMusicList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemBuilder: (context, index) => filteredMusicList[index],
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
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
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