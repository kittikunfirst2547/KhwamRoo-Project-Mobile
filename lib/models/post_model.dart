// lib/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String body;
  final String category;
  final String userId;
  final String displayName;
  final DateTime createdAt;
  final int likes;


  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.userId,
    required this.displayName,
    required this.createdAt,
    required this.likes,

  });

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      category: map['category'] ?? '',
      userId: map['userId'] ?? '',
      displayName: map['displayName'] ?? 'ไม่ระบุชื่อ',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'category': category,
      'userId': userId,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': likes,
    };
  }
}