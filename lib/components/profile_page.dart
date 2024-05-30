import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
            username = (userDoc.data() as Map<String, dynamic>)?['username'] ??
                'No Username';
            profileImageUrl =
                (userDoc.data() as Map<String, dynamic>)?['profileImageUrl'];
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
          title: Text('Bewerk Profiel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Gebruikersnaam'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Leeftijd'),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'Woonplaats'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuleren'),
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
              child: Text('Opslaan'),
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF235d3a),
                  Color(0xFF235d3a).withOpacity(0.8),
                  Color(0xFF235d3a).withOpacity(0.6),
                  Color(0xFF235d3a).withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? Icon(Icons.person, size: 55, color: Colors.grey)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadProfileImage,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF235d3a),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Upload Profielfoto'),
                ),
                SizedBox(height: 20),
                Text(
                  'Leeftijd: $age',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Woonplaats: $city',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _editProfile,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF235d3a),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Bewerk Profiel'),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Jouw Posts',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('userId',
                                    isEqualTo: _auth.currentUser?.uid)
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                    child: Text('Geen posts beschikbaar'));
                              }

                              final posts = snapshot.data!.docs.map((doc) {
                                return Post.fromFirestore(
                                    doc.data() as Map<String, dynamic>);
                              }).toList();

                              return ListView.builder(
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return Card(
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.username,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy HH:mm')
                                                .format(post.timestamp),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(post.text),
                                        ],
                                      ),
                                      leading: post.imageUrl.isNotEmpty
                                          ? Image.network(
                                              post.imageUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (context, child, progress) {
                                                if (progress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: progress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? progress
                                                                .cumulativeBytesLoaded /
                                                            progress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.red);
                                              },
                                            )
                                          : const Icon(
                                              Icons.image_not_supported),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
