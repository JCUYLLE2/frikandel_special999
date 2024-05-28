import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String text;
  final String imageUrl;
  final DateTime timestamp;

  Post({required this.text, required this.imageUrl, required this.timestamp});

  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
