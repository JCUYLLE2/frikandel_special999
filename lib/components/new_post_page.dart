import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

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
                  if (_imageData != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: MemoryImage(_imageData!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 200, // Adjust the width as needed
                      child: ElevatedButton(
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
                      labelText: 'Wat heb je gegeten?',
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
                      labelText: 'Post hier je bereidingswijze',
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
                      labelText: 'Post hier de link van je recept',
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

  Future<void> _submitPost() async {
    // Existing submit logic here
  }

  @override
  void dispose() {
    _postController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
