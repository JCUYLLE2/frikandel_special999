import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String id;
  String userId;
  String username;
  String profileImageUrl;
  String text;
  DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.text,
    required this.timestamp,
  });

  // Factory constructor for creating a Comment object from Firestore data
  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Method to convert a Comment object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'text': text,
      'timestamp': timestamp,
    };
  }
}

class Post {
  String id;
  String userId;
  String username;
  String profileImageUrl;
  String title;
  String description;
  List<String> imageUrls;
  int likes;
  List<String> likedBy;
  String url;
  DateTime timestamp;
  List<Comment> comments = [];
  int commentCount;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.likes,
    required this.likedBy,
    required this.url,
    required this.timestamp,
    required this.commentCount,
  });

  // Factory constructor voor het maken van een Post-object vanuit Firestore data
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      url: data['url'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  // Methode om een Post-object om te zetten naar een map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'likes': likes,
      'likedBy': likedBy,
      'url': url,
      'timestamp': timestamp,
      'commentCount': commentCount,
    };
  }
}
