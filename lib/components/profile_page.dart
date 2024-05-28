import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback callback;

  const ProfilePage({Key? key, required this.callback}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            const Text('Welcome to your profile page!',
                style: TextStyle(fontSize: 20)),
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
