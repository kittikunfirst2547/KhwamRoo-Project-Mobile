// lib/screens/profile_screen.dart
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

  bool get _isOwner => _auth.currentUser?.uid == widget.userId;

  // ดึงข้อมูล user จาก Firestore
  Stream<DocumentSnapshot> _getUserStream() {
    return _db.collection('users').doc(widget.userId).snapshots();
  }

  // ดึงโพสต์ของ user
  Stream<List<Post>> _getUserPosts() {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => Post.fromMap(doc.id, doc.data()))
        .toList());
  }

  // แสดง dialog แก้ไขโปรไฟล์
  void _showEditDialog(Map<String, dynamic> userData) {
    final nameController =
    TextEditingController(text: userData['displayName'] ?? '');
    final bioController =
    TextEditingController(text: userData['bio'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('แก้ไขโปรไฟล์',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อที่แสดง',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              maxLines: 3,
              maxLength: 150,
              decoration: InputDecoration(
                labelText: 'แนะนำตัวเอง',
                hintText: 'เขียนแนะนำตัวเองสั้นๆ...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
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
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('บันทึก',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile({
    required String displayName,
    required String bio,
  }) async {
    try {
      await _db.collection('users').doc(widget.userId).set({
        'displayName': displayName,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _auth.currentUser?.updateDisplayName(displayName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกสำเร็จ ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('ต้องการออกจากระบบใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('ออกจากระบบ',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as dynamic).toDate();
    return 'เข้าร่วมเมื่อ ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _getUserStream(),
        builder: (context, userSnap) {
          Map<String, dynamic> userData = {
            'displayName': widget.displayName,
            'bio': '',
          };

          if (userSnap.hasData && userSnap.data!.exists) {
            userData =
            userSnap.data!.data() as Map<String, dynamic>;
          }

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              _buildSliverAppBar(userData),
            ],
            body: _buildPostList(),
          );
        },
      ),
    );
  }

  // ── Sliver AppBar + Profile Header ───────────────
  SliverAppBar _buildSliverAppBar(Map<String, dynamic> userData) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      expandedHeight: _isOwner ? 320 : 280,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isOwner)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'edit') _showEditDialog(userData);
              if (value == 'logout') _logout();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('แก้ไขโปรไฟล์'),
                  ],
                ),
              ),
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Avatar
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.black,
                child: Text(
                  (userData['displayName'] as String? ??
                      widget.displayName)[0]
                      .toUpperCase(),
                  style: const TextStyle(
                      fontSize: 36,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    userData['bio'],
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              const SizedBox(height: 4),

              // วันที่เข้าร่วม
              if (userData['createdAt'] != null)
                Text(
                  _formatDate(userData['createdAt']),
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade400),
                ),

              const SizedBox(height: 12),

              // Stats — จำนวนโพสต์
              StreamBuilder<List<Post>>(
                stream: _getUserPosts(),
                builder: (context, snap) {
                  final count = snap.data?.length ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('$count',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('โพสต์',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                },
              ),

              // ปุ่มแก้ไข (เฉพาะเจ้าของ)
              if (_isOwner) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditDialog(userData),
                      icon: const Icon(Icons.edit,
                          size: 16, color: Colors.black),
                      label: const Text('แก้ไขโปรไฟล์',
                          style: TextStyle(color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                        side:
                        const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Post List ─────────────────────────────────────
  Widget _buildPostList() {
    return StreamBuilder<List<Post>>(
      stream: _getUserPosts(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: posts.length,
          itemBuilder: (_, i) => _buildPostCard(posts[i]),
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          // Category + วันที่
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(post.category,
                    style: const TextStyle(fontSize: 12)),
              ),
              Text(
                '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
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

          // Like count
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
    );
  }
}