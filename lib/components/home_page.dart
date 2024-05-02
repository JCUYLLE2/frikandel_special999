import 'package:flutter/material.dart';
import './login_page.dart'; // Importeer de LoginPage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welkom bij de homepagina!',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Home Demo',
    initialRoute:
        '/login', // Verander naar /home als je direct naar de homepage wilt gaan
    routes: {
      '/login': (context) => const LoginPage(),
      '/home': (context) => const HomePage(),
    },
  ));
}
