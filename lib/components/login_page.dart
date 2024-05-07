import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class MyLoginPage extends StatefulWidget {
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    // Zorg ervoor dat je hier je correcte domain en clientId gebruikt.
    auth0 = Auth0(
      'dev-xv0jcmkzbkhhxl1c.eu.auth0.com',
      '7ymWdR0RxTzOfBnwEXmVYr8TN7OlcLQy',
    );
  }

  Future<void> _login() async {
    try {
      final credentials = await auth0.webAuthentication().login(useHTTPS: true);
      // Handle successful login
      print('Login Successful: Access Token - ${credentials.accessToken}');
    } catch (e) {
      // Handle login error
      print('Login Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _login,
          child: Text('Login with Auth0'),
        ),
      ),
    );
  }
}
