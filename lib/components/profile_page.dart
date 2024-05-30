import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback callback;

  const ProfilePage({Key? key, required this.callback}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Loading...';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          print('Gebruikersdocument gevonden: ${userDoc.data()}');
          var data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            username = data['username'] ?? 'No Username';
          });
        } else {
          print('Gebruikersdocument niet gevonden');
          setState(() {
            username = 'Unknown User';
          });
        }
      } catch (e) {
        print('Fout bij het ophalen van gebruikersgegevens: $e');
        setState(() {
          username = 'Error';
        });
      }
    } else {
      print('Geen gebruiker ingelogd');
      setState(() {
        username = 'No User';
      });
    }
  }

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
            Text(
              'Welcome, $username!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.callback,
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
