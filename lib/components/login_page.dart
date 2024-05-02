import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigeer naar de ProfilePage en geef de callback door
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePageWithCallback(
                  callback: () {
                    // Doe hier wat nodig is om uit te loggen
                    // In dit voorbeeld, pop het huidige scherm terug naar de loginpagina
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: const Text('Log In'),
        ),
      ),
    );
  }
}

class ProfilePageWithCallback extends StatelessWidget {
  final VoidCallback callback;

  const ProfilePageWithCallback({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to your profile page!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Roep de callback aan wanneer de gebruiker uitlogt
                callback();
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
