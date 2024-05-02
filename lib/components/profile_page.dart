import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final void Function(BuildContext) callback;

  const ProfilePage({
    super.key,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiel'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welkom bij je profielpagina!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                callback(context);
              },
              child: const Text('Uitloggen'),
            ),
          ],
        ),
      ),
    );
  }
}
