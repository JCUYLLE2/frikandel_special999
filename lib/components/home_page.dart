import 'package:flutter/material.dart';
import 'package:frikandel_special999/components/login_page.dart';

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
    initialRoute: '/login',
    routes: {
      '/login': (context) => MyLoginPage(),
      '/home': (context) => HomePage(),
    },
  ));
}
