import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frikandel_special999/singleton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Nieuwe import voor Firebase Storage

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _postController = TextEditingController();
  Uint8List? _imageData;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false; // Variabele om de status bij te houden

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    print('Bezig met het indienen van de post...');
    setState(() {
      _isSubmitting = true;
    });

    final FirebaseFirestore db = SettingsSingleton().myDB;

    try {
      String? imageUrl;
      if (_imageData != null) {
        print('Bezig met het uploaden van de afbeelding...');
        // Upload de afbeelding naar Firebase Storage
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

      // Voeg de post toe aan Firestore zonder imageData
      print('Bezig met het opslaan van de post in Firestore...');
      final DocumentReference docRef = await db.collection("posts").add({
        'text': _postController.text,
        'imageUrl': imageUrl, // Sla de afbeelding URL op
        'timestamp': Timestamp.now(),
      });
      print('Post succesvol ingediend met ID: ${docRef.id}');

      // Navigeer naar de hoofdpagina (de feed) nadat de post is ingediend
      Navigator.pushReplacementNamed(context, '/main');
    } catch (error) {
      print('Fout bij het indienen van de post: $error');
      // Toon een foutmelding aan de gebruiker
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
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (file != null) {
      return await file.readAsBytes();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nieuwe Post'),
      ),
      body: SingleChildScrollView(
        // Voeg deze regel toe
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageData != null)
                Container(
                  width: 200, // Stel hier de gewenste breedte in
                  height: 200, // Stel hier de gewenste hoogte in
                  child: Image.memory(_imageData!, fit: BoxFit.cover),
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
                controller: _postController,
                decoration: InputDecoration(labelText: 'Wat wil je delen?'),
                maxLines: 3,
              ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                child: _isSubmitting
                    ? CircularProgressIndicator()
                    : Text('Posten'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
