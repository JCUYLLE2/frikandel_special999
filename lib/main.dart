import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frikandel_special999/components/feed_page.dart';
import 'package:frikandel_special999/components/home_page.dart';
import 'package:frikandel_special999/components/login_page.dart';
import 'package:frikandel_special999/components/main_page.dart';
import 'package:frikandel_special999/components/new_post_page.dart';
import 'package:frikandel_special999/components/profile_page.dart';
import 'package:frikandel_special999/components/register_page.dart'; // Voeg dit toe
import 'package:frikandel_special999/firebase_options.dart';
import 'singleton.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SettingsSingleton().createDB();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mijn Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Start de app op de LoginPage
      routes: {
        '/': (context) => const LoginPage(), // Start met de LoginPage
        '/main': (context) =>
            const MainPage(), // Navigeer naar MainPage na inloggen
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(), // Voeg dit toe
        '/new_post': (context) => const NewPostPage(),
        '/profile': (context) => ProfilePage(
              callback: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
        '/feed': (context) => FeedPage(
              callback: () {
                Navigator.pushReplacementNamed(context, '/feed');
              },
            ),
      },
    );
  }
}
