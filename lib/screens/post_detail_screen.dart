import 'package:flutter/material.dart';
import 'package:khwamroo/models/post_model.dart';
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
  bool _liked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
  }

  void _handleLike() {
    if (_liked) return;
    setState(() {
      _liked = true;
      _likeCount++;
    });
    _postService.likePost(widget.post.id);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                post.category,
                style: const TextStyle(fontSize: 12),
              ),
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

            // Author row — กดไปหน้า Profile
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      userId: post.userId,
                      displayName: post.displayName,
                    ),
                  ),
                );
              },
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
                      Text(
                        post.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'กดเพื่อดูโปรไฟล์',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // วันที่
                  Text(
                    '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 32),
            // แสดงรูปถ้ามี
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            if (post.imageUrl != null) const SizedBox(height: 16),

            // Body เต็ม
            Text(
              post.body,
              style: const TextStyle(fontSize: 16, height: 1.8),
            ),
            const SizedBox(height: 40),

            // Like button
            Center(
              child: GestureDetector(
                onTap: _handleLike,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _liked ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _liked ? Icons.favorite : Icons.favorite_border,
                        color: _liked ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_likeCount ถูกใจ',
                        style: TextStyle(
                          color: _liked ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}