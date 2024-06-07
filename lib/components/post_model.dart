import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String userId;
  String username;
  String title;
  String description;
  String text; // Add this line
  Timestamp timestamp;
  String profileImageUrl;
  int likes;
  List<String> likedBy;
  List<String> imageUrls;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    required this.description,
    required this.text, // Add this line
    required this.timestamp,
    this.profileImageUrl = '',
    required this.likes,
    required this.likedBy,
    required this.imageUrls,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<String> imageUrls = [];
    if (data.containsKey('imageUrls')) {
      imageUrls = List<String>.from(data['imageUrls']);
    } else if (data.containsKey('imageURL')) {
      imageUrls = [data['imageURL']];
    }
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      text: data['text'] ?? '', // Add this line
      timestamp: data['timestamp'],
      profileImageUrl: data['profileImageUrl'] ?? '',
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      imageUrls: imageUrls,
    );
  }

  void setProfileImageUrl(String url) {
    profileImageUrl = url;
  }
}
