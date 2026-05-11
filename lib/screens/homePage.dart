import 'package:flutter/material.dart';
import 'package:khwamroo/models/post_model.dart';
import 'package:khwamroo/screens/post_detail_screen.dart';
import 'package:khwamroo/services/post_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _postService = PostService();
  String _selectedCategory = 'ทั้งหมด';

  final List<String> _categories = [
    'ทั้งหมด', 'การเงิน', 'การเรียน', 'กีฬา', 'เกม', 'Mindset', 'Career'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryChips(),
            const SizedBox(height: 8),
            Expanded(child: _buildFeed()),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Image.asset('assets/images/Logo1.png', fit: BoxFit.cover),
          ),
          Container(width: 35, height: 35, color: Colors.black87),
        ],
      ),
    );
  }

  // ── Category Chips ───────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8,top: 4),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        },
      ),
    );
  }

  // ── Feed ดึงจาก Firestore จริง ────────────────────
  Widget _buildFeed() {
    return StreamBuilder<List<Post>>(
      stream: _postService.getPosts(category: _selectedCategory),
      builder: (context, snap) {

        // loading
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // error
        if (snap.hasError) {
          return const Center(child: Text('เกิดข้อผิดพลาด'));
        }

        // ไม่มีโพสต์
        if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(child: Text('ยังไม่มีโพสต์ในหมวดนี้'));
        }

        final posts = snap.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, i) => _buildPostCard(posts[i]),
        );
      },
    );
  }

  // ── Post Card รับ Post object แทน Map ────────────
  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(post.category,
                  style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 8),
            Text(post.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(post.body,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(post.displayName,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                Row(
                  children: [
                    Icon(Icons.favorite_border,
                        size: 15, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('${post.likes}',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // ── Bottom Nav ────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      height: 70,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'หน้าแรก', isActive: true),
          _navItem(Icons.category, 'หมวดหมู่'),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/write');  // ← เพิ่ม
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          _navItem(Icons.notifications, 'แจ้งเตือน'),
          _navItem(Icons.person, 'โปรไฟล์'),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.black : Colors.grey, size: 28),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }
}