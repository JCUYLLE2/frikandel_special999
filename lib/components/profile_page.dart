import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frikandel_special999/components/detail_page.dart';
import 'package:frikandel_special999/components/post_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback callback;

  const ProfilePage({Key? key, required this.callback}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Loading...';
  String? profileImageUrl;
  String age = '...';
  String city = '...';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          print('Gebruikersdocument gevonden: ${userDoc.data()}');
          setState(() {
            final data = userDoc.data() as Map<String, dynamic>;
            username = data['username'] ?? 'No Username';
            profileImageUrl = data['profileImageUrl'];
            age = data['age'] ?? '...';
            city = data['city'] ?? '...';
          });
        } else {
          print('Gebruikersdocument niet gevonden');
          setState(() {
            username = 'Unknown User';
          });
        }
      } else {
        print('Geen gebruiker ingelogd');
        setState(() {
          username = 'No User';
        });
      }
    } catch (e) {
      print('Fout bij het ophalen van gebruikersgegevens: $e');
      setState(() {
        username = 'Error';
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

  Future<void> _editProfile() async {
    final TextEditingController usernameController =
        TextEditingController(text: username);
    final TextEditingController ageController =
        TextEditingController(text: age);
    final TextEditingController cityController =
        TextEditingController(text: city);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bewerk Profiel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Gebruikersnaam'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Leeftijd'),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'Woonplaats'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user != null) {
                  await _firestore.collection('users').doc(user.uid).set({
                    'username': usernameController.text,
                    'age': ageController.text,
                    'city': cityController.text,
                  }, SetOptions(merge: true));
                  setState(() {
                    username = usernameController.text;
                    age = ageController.text;
                    city = cityController.text;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileImage(),
                const SizedBox(height: 20),
                _buildUsername(),
                const SizedBox(height: 20),
                _buildUploadButton(),
                const SizedBox(height: 20),
                _buildAge(),
                const SizedBox(height: 10),
                _buildCity(),
                const SizedBox(height: 20),
                _buildEditButton(),
                const SizedBox(height: 20),
                _buildLogoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF235d3a),
            const Color(0xFF235d3a).withOpacity(0.8),
            const Color(0xFF235d3a).withOpacity(0.6),
            const Color(0xFF235d3a).withOpacity(0.4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 55,
        backgroundImage:
            profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
        child: profileImageUrl == null
            ? const Icon(Icons.person, size: 55, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildUsername() {
    return Text(
      username,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: _uploadProfileImage,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF235d3a),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Upload Profielfoto'),
    );
  }

  Widget _buildAge() {
    return Text(
      'Leeftijd: $age',
      style: const TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCity() {
    return Text(
      'Woonplaats: $city',
      style: const TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: _editProfile,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF235d3a),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Bewerk Profiel'),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: widget.callback,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('Log Out'),
      ),
    );
  } // Add this line
}
