import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String text;
  final String imageUrl;
  final DateTime timestamp; // Verander naar DateTime
  final String username;

  Post({
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.username,
  });

  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp)
          .toDate(), // Converteer Timestamp naar DateTime
      username: data['username'] ?? '',
    );
  }
}
