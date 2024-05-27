import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frikandel_special999/components/home_page.dart';
import 'package:frikandel_special999/components/login_page.dart';
import 'package:frikandel_special999/components/main_page.dart';
import 'firebase_options.dart'; // Importeer de Firebase-opties

import 'singleton.dart'; // Importeer de Singleton-klasse

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Roep createDB aan om de database te initialiseren
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
      initialRoute: '/home', // Start de app op de home pagina
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
