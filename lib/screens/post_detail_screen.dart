// lib/screens/post_detail_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khwamroo/models/post_model.dart';
import 'package:khwamroo/services/notification_service.dart';
import 'package:khwamroo/services/post_service.dart';
import 'package:khwamroo/screens/profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({required this.post, super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _postService = PostService();
  final _notificationService = NotificationService();
  final _db = FirebaseFirestore.instance;
  bool _liked = false;

  bool get _isOwner =>
      FirebaseAuth.instance.currentUser?.uid == widget.post.userId;

  // ── เช็ค liked ตอนเปิดหน้า ──────────────────────
  @override
  void initState() {
    super.initState();
    _checkLiked();
  }

  Future<void> _checkLiked() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final liked = await _postService.isLiked(widget.post.id, uid);
    if (mounted) setState(() => _liked = liked);
  }

  // ── กด like ──────────────────────────────────────
  void _handleLike() async {
    print('🔔 กด like, _liked: $_liked');
    if (_liked) return;
    setState(() => _liked = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    print('🔔 uid: $uid');
    if (uid == null) return;

    try {
      await _postService.likePost(widget.post.id, uid);
      print('✅ like สำเร็จ');
    } catch (e) {
      print('❌ like error: $e');
      setState(() => _liked = false);
    }

    await _notificationService.sendLikeNotification(
      toUserId: widget.post.userId,
      postId: widget.post.id,
      postTitle: widget.post.title,
    );
  }

  // ── ลบโพสต์ ──────────────────────────────────────
  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('ลบโพสต์?'),
        content: const Text(
          'โพสต์นี้จะถูกลบถาวร ไม่สามารถกู้คืนได้',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ลบ',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _postService.deletePost(widget.post.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบโพสต์สำเร็จ')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isOwner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'delete') _deletePost();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('ลบโพสต์',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(post.category,
                  style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Author row
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userId: post.userId,
                    displayName: post.displayName,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black,
                    child: Text(
                      post.displayName[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      Text('กดเพื่อดูโปรไฟล์',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),

            const Divider(height: 32),

            // Body
            Text(post.body,
                style:
                const TextStyle(fontSize: 16, height: 1.8)),
            const SizedBox(height: 40),

            // ── Like button realtime ──────────────────
            Center(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _db
                    .collection('posts')
                    .doc(post.id)
                    .snapshots(),
                builder: (context, snap) {
                  int likes = widget.post.likes;
                  if (snap.hasData && snap.data!.exists) {
                    final data = snap.data!.data()
                    as Map<String, dynamic>?;
                    likes = data?['likes'] ?? 0;
                  }
                  return GestureDetector(
                    onTap: _handleLike,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: _liked
                            ? Colors.red.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _liked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _liked
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$likes ถูกใจ',
                            style: TextStyle(
                              color: _liked
                                  ? Colors.red
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}