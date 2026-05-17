// lib/services/post_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final _db = FirebaseFirestore.instance;

  // ดึง posts realtime
  Stream<List<Post>> getPosts({String? category}) {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final posts = snap.docs
          .map((doc) => Post.fromMap(doc.id, doc.data()))
          .toList();

      if (category != null && category != 'ทั้งหมด') {
        return posts.where((p) => p.category == category).toList();
      }
      return posts;
    });
  }

  // ลบโพสต์
  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  // กด like
  Future<void> likePost(String postId, String uid) async {
    await _db.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([uid]),
    });
  }

  //เช็คว่าเคย like แล้วยัง
  Future<bool> isLiked(String postId, String uid) async {
    final doc = await _db.collection('posts').doc(postId).get();
    final data = doc.data();
    if (data == null) return false;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    return likedBy.contains(uid);
  }
  // เพิ่มโพสต์ใหม่
  Future<void> addPost(Post post) async {
    await _db.collection('posts').add(post.toMap());
  }
}