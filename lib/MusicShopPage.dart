import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'MusicShopListPage.dart';
import 'AccountPage.dart';

// Global variable to track login state (for simplicity)
bool globalIsLoggedIn = false;

class MusicShopPage extends StatefulWidget {
  const MusicShopPage({super.key});

  @override
  State<MusicShopPage> createState() => _MusicShopPageState();
}

class _MusicShopPageState extends State<MusicShopPage> {
  int _selectedIndex = 1;

  final List<String> categories = [
    'ایرانی',
    'خارجی',
    'محلی',
    'جدیدترین‌ها',
  ];

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
          child: globalIsLoggedIn ? _buildShopContent() : _buildAuthOptions(),
        ),
      ),
    );
  }

  Widget _buildAuthOptions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome to Music Shop',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: Text('Login'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: Text('Signup'),
        ),
      ],
    );
  }

  Widget _buildShopContent() {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Music Shop',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPage()),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildAdCard(),
        SizedBox(height: 20),
        Text(
          'Categories',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: 10),
        ...categories.map((category) => ListTile(
          title: Text(category),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicShopListPage(category: category),
              ),
            );
          },
        )),
      ],
    );
  }

  Widget _buildAdCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InAppWebViewPage(url: 'https://www.google.com'),
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Advertisement: Visit Google!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}

class InAppWebViewPage extends StatelessWidget {
  final String url;

  const InAppWebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Advertisement')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}