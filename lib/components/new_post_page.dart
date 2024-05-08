import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _postController = TextEditingController();
  Uint8List? _imageData;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    print('Submitting post...');
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Voeg de post toe aan de Firestore-collectie "posts"
    await db.collection("posts").add({
      'text': _postController.text,
      'imageData': _imageData,
      'timestamp': Timestamp.now(),
    }).then((doc) {
      print('Post submitted successfully with ID: ${doc.id}');
    }).catchError((error) {
      print('Error submitting post: $error');
    });

    // Navigeer terug naar de hoofdpagina
    Navigator.pop(context);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageData != null)
              Image.memory(_imageData!, fit: BoxFit.cover),
            ElevatedButton(
              onPressed: () async {
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
              onPressed: () async {
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
              onPressed: _submitPost,
              child: Text('Posten'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NewPostPage(),
  ));
}
