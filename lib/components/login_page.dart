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
    auth0 = Auth0(
      'dev-xv0jcmkzbkhhxl1c.eu.auth0.com',
      '7ymWdR0RxTzOfBnwEXmVYr8TN7OlcLQy',
    );
  }

  Future<void> _login() async {
    try {
      final credentials = await auth0.webAuthentication().login(useHTTPS: true);
      // Handle successful login, access credentials.accessToken for token and credentials.user for user info
    } catch (e) {
      // Handle login error
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
