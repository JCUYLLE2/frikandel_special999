import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback callback;

  const ProfilePage({Key? key, required this.callback}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Loading...';
  String? profileImageUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

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
            profileImageUrl = data.containsKey('profileImageUrl')
                ? data['profileImageUrl']
                : null;
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

  Future<void> _uploadProfileImage() async {
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      Uint8List imageData = await imageFile.readAsBytes();

      User? user = _auth.currentUser;
      if (user != null) {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        final UploadTask uploadTask = storageRef.putData(imageData);
        final TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() => {});
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).set({
          'profileImageUrl': downloadUrl,
        }, SetOptions(merge: true));

        setState(() {
          profileImageUrl = downloadUrl;
        });
      }
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
            if (profileImageUrl != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profileImageUrl!),
              )
            else
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            const SizedBox(height: 20),
            Text(
              'Welcome, $username!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadProfileImage,
              child: const Text('Upload Profielfoto'),
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
