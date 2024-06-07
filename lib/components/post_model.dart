import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id; // Add this field
  final String username;
  final String title;
  final String text;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  final String userId;
  String profileImageUrl;
  int likes;
  List<String> likedBy;

  Post({
    required this.id, // And this line
    required this.username,
    required this.title,
    required this.text,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.userId,
    this.profileImageUrl = '',
    this.likes = 0,
    this.likedBy = const [],
  });

  // Change Map<String, dynamic> data to DocumentSnapshot doc in the parameters.
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id, // Add this line
      username: data['username'] ?? '',
      title: data['title'] ?? '',
      text: data['text'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  void setProfileImageUrl(String url) {
    profileImageUrl = url;
  }
}
