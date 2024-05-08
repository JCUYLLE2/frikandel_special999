import 'package:flutter/material.dart';
import 'home_page.dart'; // Dit is je HomePage die als feed fungeert
import 'profile_page.dart'; // Stel je profiel-pagina voor
import 'new_post_page.dart'; // Stel je nieuwe post-pagina voor

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Houdt bij welke tab momenteel geselecteerd is

  // Update hier met je HomePage, NewPostPage, en ProfilePage
  final List<Widget> _widgetOptions = [
    HomePage(),
    NewPostPage(),
    ProfilePage(callback: (BuildContext context) {
      // Logout-functie of andere callback
    }),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
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
