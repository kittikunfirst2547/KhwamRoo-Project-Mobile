// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khwamroo/models/post_model.dart';
import 'package:khwamroo/services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String displayName;

  const ProfileScreen({
    required this.userId,
    required this.displayName,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = FirebaseFirestore.instance;
  final _postService = PostService();
  final _auth = FirebaseAuth.instance;

  // เช็คว่าเป็นโปรไฟล์ตัวเอง
  bool get _isOwner => _auth.currentUser?.uid == widget.userId;

  // ดึงข้อมูล user จาก Firestore
  Future<Map<String, dynamic>?> _getUserData() async {
    final doc = await _db.collection('users').doc(widget.userId).get();
    return doc.data();
  }

  // ดึงโพสต์ของ user นี้
  Stream<List<Post>> _getUserPosts() {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      print('📋 posts ของ ${widget.userId}: ${snap.docs.length} โพสต์');
      return snap.docs
          .map((doc) => Post.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // แสดง dialog แก้ไขโปรไฟล์
  void _showEditDialog(Map<String, dynamic> userData) {
    final nameController =
    TextEditingController(text: userData['displayName']);
    final bioController =
    TextEditingController(text: userData['bio'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('แก้ไขโปรไฟล์'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อที่แสดง',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'แนะนำตัวเอง',
                border: OutlineInputBorder(),
                hintText: 'เขียนแนะนำตัวเองสั้นๆ...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveProfile(
                displayName: nameController.text.trim(),
                bio: bioController.text.trim(),
              );
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black),
            child: const Text('บันทึก',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // บันทึกโปรไฟล์
  Future<void> _saveProfile({
    required String displayName,
    required String bio,
  }) async {
    try {
      // อัปเดต Firestore
      await _db.collection('users').doc(widget.userId).update({
        'displayName': displayName,
        'bio': bio,
      });

      // อัปเดต Firebase Auth displayName
      await _auth.currentUser?.updateDisplayName(displayName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกสำเร็จ ✅')),
        );
        setState(() {}); // refresh UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  // logout
  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('โปรไฟล์',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          if (_isOwner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('ออกจากระบบ',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnap.data ?? {
            'displayName': widget.displayName,
            'bio': '',
            'postCount': 0,
          };

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(userData),
                const SizedBox(height: 8),
                _buildPostList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Profile Header ────────────────────────────────
  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.black,
            child: Text(
              (userData['displayName'] as String? ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // ชื่อ
          Text(
            userData['displayName'] ?? widget.displayName,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Bio
          if ((userData['bio'] ?? '').isNotEmpty)
            Text(
              userData['bio'],
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 16),

          // Stats
          StreamBuilder<List<Post>>(
            stream: _getUserPosts(),
            builder: (context, snap) {
              final count = snap.data?.length ?? 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStat('โพสต์', count.toString()),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // ปุ่มแก้ไข (เฉพาะเจ้าของ)
          if (_isOwner)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showEditDialog(userData),
                icon: const Icon(Icons.edit, size: 16,
                    color: Colors.black),
                label: const Text('แก้ไขโปรไฟล์',
                    style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  // ── Post List ─────────────────────────────────────
  Widget _buildPostList() {
    return StreamBuilder<List<Post>>(
      stream: _getUserPosts(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snap.hasData || snap.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.article_outlined,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('ยังไม่มีโพสต์',
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        final posts = snap.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (_, i) => _buildPostCard(posts[i]),
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(post.category,
                style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 8),

          // Title
          Text(post.title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),

          // Body preview
          Text(post.body,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade400),
              ),
              Row(
                children: [
                  Icon(Icons.favorite_border,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text('${post.likes}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}