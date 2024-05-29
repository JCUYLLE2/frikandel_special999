import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String username;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final String userId; // Voeg dit veld toe

  Post(
      {required this.username,
      required this.text,
      required this.imageUrl,
      required this.timestamp,
      required this.userId});

  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      username: data['username'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '', // Voeg dit veld toe
    );
  }
}
