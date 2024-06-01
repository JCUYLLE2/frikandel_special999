import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Uint8List? _imageData;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _postController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    print('Bezig met het indienen van de post...');
    setState(() {
      _isSubmitting = true;
    });

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('Geen gebruiker ingelogd');
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      String? imageUrl;
      if (_imageData != null) {
        print('Bezig met het uploaden van de afbeelding...');
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        final UploadTask uploadTask = storageRef.putData(_imageData!);
        final TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() => {});
        imageUrl = await taskSnapshot.ref.getDownloadURL();
        print('Afbeelding geüpload naar: $imageUrl');
      }

      // Haal de gebruikersdocument op
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Controleer of het gebruikersdocument bestaat
      if (!userDoc.exists) {
        print('Gebruikersdocument niet gevonden');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Haal de gebruikersnaam op
      String username = (userDoc.data() as Map<String, dynamic>)['username'];
      print('Gebruikersnaam: $username');

      print('Bezig met het opslaan van de post in Firestore...');
      await FirebaseFirestore.instance.collection("posts").add({
        'userId': currentUser.uid, // Voeg de userId toe
        'title': _titleController.text, // Voeg de titel toe
        'text': _postController.text, // Gebruik dit als de tekst van de post
        'description': _descriptionController.text, // Voeg de beschrijving toe
        'imageUrl': imageUrl,
        'timestamp': Timestamp.now(),
        'username': username, // Voeg dit veld toe
      });
      print('Post succesvol ingediend');

      Navigator.pushReplacementNamed(context, '/main');
    } catch (error, stackTrace) {
      print('Fout bij het indienen van de post: $error');
      print('Stack trace: $stackTrace');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Fout'),
          content: Text(
              'Er is een fout opgetreden bij het indienen van de post. Probeer het opnieuw.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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

  Future<Uint8List?> pickImage({required ImageSource source}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (file != null) {
        return await file.readAsBytes();
      }
    } catch (error) {
      print('Fout bij het kiezen van een afbeelding: $error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nieuwe Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageData != null)
              Container(
                constraints: BoxConstraints(
                  maxHeight:
                      200, // Pas deze waarde aan om de maximale hoogte te beperken
                ),
                child: Image.memory(
                  _imageData!,
                  fit: BoxFit.contain,
                ),
              ),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final Uint8List? imageData =
                          await pickImage(source: ImageSource.gallery);
                      if (imageData != null) {
                        setState(() {
                          _imageData = imageData;
                        });
                      }
                    },
              child: Text('Kies een afbeelding uit galerij'),
            ),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final Uint8List? imageData =
                          await pickImage(source: ImageSource.camera);
                      if (imageData != null) {
                        setState(() {
                          _imageData = imageData;
                        });
                      }
                    },
              child: Text('Neem een afbeelding'),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Titel'),
            ),
            TextField(
              controller: _postController,
              decoration: InputDecoration(labelText: 'Tekst'),
              maxLines: 3,
            ),
            TextField(
              controller: _descriptionController,
              decoration:
                  InputDecoration(labelText: 'Beschrijving of URL/Recept'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              child:
                  _isSubmitting ? CircularProgressIndicator() : Text('Posten'),
            ),
          ],
        ),
      ),
    );
  }
}
