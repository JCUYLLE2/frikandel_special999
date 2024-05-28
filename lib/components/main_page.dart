import 'package:flutter/material.dart';
import 'package:frikandel_special999/components/feed_page.dart';
import 'home_page.dart'; // Importeer de HomePage
import 'profile_page.dart'; // Importeer de ProfilePage
import 'new_post_page.dart'; // Importeer de NewPostPage

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Houdt bij welke tab momenteel geselecteerd is

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      FeedPage(
        callback: () {
          Navigator.pushReplacementNamed(context, '/feed');
        },
      ),
      const NewPostPage(),
      ProfilePage(
        callback: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Nieuwe Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profiel',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
