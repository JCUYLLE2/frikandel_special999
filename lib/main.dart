import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importeer de Firebase-opties
import './components/login_page.dart'; // Importeer de LoginPage
import './components/main_page.dart'; // Zorg ervoor dat MainPage correct geïmporteerd is
import 'singleton.dart'; // Importeer de Singleton-klasse die je hebt gemaakt

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
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mijn Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Start de app met de LoginPage
    );
  }
}
