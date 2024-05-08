import 'package:flutter/material.dart';
import 'dart:io'; // Voor het gebruik van File

class ProfilePage extends StatefulWidget {
  final void Function(BuildContext) callback;

  const ProfilePage({
    super.key,
    required this.callback,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  File? imageFile; // Een variabele om de geselecteerde afbeelding op te slaan

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Implementeer de functionaliteit om een afbeelding te kiezen (bijvoorbeeld met image_picker)
    // Voor nu houden we het simpel:
    // imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      // Stel imageFile in met de gekozen afbeelding
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiel'),
      ),
      body: Center(
        child: SingleChildScrollView(
          // Voeg ScrollView toe voor betere responsiviteit
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welkom bij je profielpagina!',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Naam',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Toon de gekozen afbeelding of een placeholder
              imageFile != null
                  ? Image.file(imageFile!)
                  : Image.network(
                      'https://via.placeholder.com/150'), // Placeholder afbeelding
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Kies een profielfoto'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.callback(context);
                },
                child: const Text('Uitloggen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
