// lib/services/post_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final _db = FirebaseFirestore.instance;

  // ดึง posts realtime
  Stream<List<Post>> getPosts({String? category}) {
    // ดึงทั้งหมดก่อน ไม่ใช้ where ใน query
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final posts = snap.docs
          .map((doc) => Post.fromMap(
          doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // filter ฝั่ง app
      if (category != null && category != 'ทั้งหมด') {
        return posts
            .where((p) => p.category == category)
            .toList();
      }
      return posts;
    });
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }
  // กด like
  Future<void> likePost(String postId) async {
    await _db.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  // เพิ่มโพสต์ใหม่
  Future<void> addPost(Post post) async {
    await _db.collection('posts').add(post.toMap());
  }
}