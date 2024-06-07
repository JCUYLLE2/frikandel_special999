import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Uint8List> _imageDataList = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _postOrigin = 'Eigen Recept'; // Default value

  void _togglePostOrigin() {
    setState(() {
      _postOrigin =
          _postOrigin == 'Eigen Recept' ? 'Elders Gevonden' : 'Eigen Recept';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nieuwe Post'),
        backgroundColor: const Color(0xFF235d3a), // Dark green theme
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imageDataList.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageDataList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: MemoryImage(_imageDataList[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Center(
                    child: SizedBox(
                      width: 200, // Adjust the width as needed
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                final List<XFile>? images =
                                    await _picker.pickMultiImage(
                                  imageQuality: 90,
                                );
                                if (images != null) {
                                  List<Uint8List> imageDataList = [];
                                  for (var image in images) {
                                    imageDataList
                                        .add(await image.readAsBytes());
                                  }
                                  setState(() {
                                    _imageDataList = imageDataList;
                                  });
                                }
                              },
                        child: const Icon(Icons.camera_alt),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xFF235d3a),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Titel',
                      fillColor: Colors.grey[200], // Light gray fill
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      labelText: 'Tekst',
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Beschrijving of URL/Recept',
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ToggleButtons(
                      isSelected: [
                        _postOrigin == 'Eigen Recept',
                        _postOrigin == 'Elders Gevonden',
                      ],
                      onPressed: (index) {
                        _togglePostOrigin();
                      },
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Eigen Recept',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Elders Gevonden',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                      selectedColor: Colors.white,
                      fillColor: const Color(0xFF235d3a),
                      color: const Color(0xFF235d3a),
                      borderColor: Colors.grey,
                      borderWidth: 1.5,
                      selectedBorderColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 200, // Adjust the width as needed
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitPost,
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text('Posten'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xFF235d3a),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  Future<void> _submitPost() async {
    setState(() {
      _isSubmitting = true;
    });

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isSubmitting = false;
      });
      _showLoginRequiredDialog();
      return;
    }

    try {
      List<String> imageUrls = [];
      for (var imageData in _imageDataList) {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        final UploadTask uploadTask = storageRef.putData(imageData);
        final TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() => {});
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        throw 'User document does not exist';
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final String username = userData['username'] ?? 'Unknown';
      final String profileImageUrl = userData.containsKey('profileImageUrl')
          ? userData['profileImageUrl']
          : '';

      await _firestore.collection("posts").add({
        'userId': currentUser.uid,
        'title': _titleController.text,
        'text': _postController.text,
        'description': _descriptionController.text,
        'imageUrls': imageUrls,
        'timestamp': Timestamp.now(),
        'username': username,
        'profileImageUrl': profileImageUrl,
        'likes': 0,
        'likedBy': [],
        'origin': _postOrigin, // Added post origin
      });

      // Na het succesvol indienen van de post, navigeer naar de feedpagina
      Navigator.pushReplacementNamed(context,
          '/feed'); // Zorg ervoor dat '/feed' de juiste naam is voor je feedpagina route
    } catch (error) {
      print('Fout bij het indienen van de post: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fout'),
          content: const Text(
              'Er is een fout opgetreden bij het indienen van de post. Probeer het opnieuw.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Vereist'),
        content: const Text(
            'U moet ingelogd zijn om een nieuwe post te kunnen plaatsen.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context,
                  '/login'); // Assuming you have a named route for the login page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
