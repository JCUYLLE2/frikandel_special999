import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String username;
  final String title; // Voeg dit veld toe
  final String text;
  final String description; // Voeg dit veld toe
  final String imageUrl;
  final DateTime timestamp;
  final String userId;
  String profileImageUrl;

  Post({
    required this.username,
    required this.title, // Voeg dit veld toe
    required this.text,
    required this.description, // Voeg dit veld toe
    required this.imageUrl,
    required this.timestamp,
    required this.userId,
    this.profileImageUrl = '',
  });

  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      username: data['username'] ?? '',
      title: data['title'] ?? '', // Voeg dit veld toe
      text: data['text'] ?? '',
      description: data['description'] ?? '', // Voeg dit veld toe
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  void setProfileImageUrl(String url) {
    profileImageUrl = url;
  }
}
