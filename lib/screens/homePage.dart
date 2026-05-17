// lib/screens/homePage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khwamroo/models/post_model.dart';
import 'package:khwamroo/screens/notifications_screen.dart';
import 'package:khwamroo/screens/post_detail_screen.dart';
import 'package:khwamroo/screens/profile_screen.dart';
import 'package:khwamroo/services/notification_service.dart';
import 'package:khwamroo/services/post_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _postService = PostService();
  String _selectedCategory = 'ทั้งหมด';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'ทั้งหมด', 'การเงิน', 'การเรียน', 'กีฬา', 'เกม', 'Mindset', 'Career'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            const SizedBox(height: 8),
            Expanded(child: _buildFeed()),
          ],
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? '';
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
          GestureDetector(
            onTap: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      userId: user.uid,
                      displayName: displayName,
                    ),
                  ),
                );
              }
            },
            child: Row(
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black,
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        decoration: InputDecoration(
          hintText: 'ค้นหาโพสต์...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ── Category Chips ────────────────────────────────
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
            padding: const EdgeInsets.only(right: 8, top: 4),
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

  // ── Feed ──────────────────────────────────────────
  Widget _buildFeed() {
    return StreamBuilder<List<Post>>(
      stream: _postService.getPosts(category: _selectedCategory),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(child: Text('เกิดข้อผิดพลาด'));
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(child: Text('ยังไม่มีโพสต์ในหมวดนี้'));
        }

        // ── filter ตาม search ──────────────────────
        var posts = snap.data!;
        if (_searchQuery.isNotEmpty) {
          posts = posts
              .where((p) => p.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
              .toList();
        }

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'ไม่พบโพสต์ที่ค้นหา',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }


        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, i) => _buildPostCard(posts[i]),
        );
      },
    );
  }

  //  Post Card
  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 8),
            Text(post.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(post.body,
                style:
                TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
                        style:
                        TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Nav
  Widget _buildBottomNav() {
    return Container(
      height: 70,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'หน้าแรก', isActive: true),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/category'),
            child: _navItem(Icons.category, 'หมวดหมู่'),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: () => Navigator.pushNamed(context, '/write'),
              icon: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          StreamBuilder<int>(
            stream: NotificationService().getUnreadCount(),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _navItem(Icons.notifications, 'แจ้งเตือน'),
                    if (count > 0)
                      Positioned(
                        top: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      userId: user.uid,
                      displayName: user.displayName ?? '',
                    ),
                  ),
                );
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            child: _navItem(Icons.person, 'โปรไฟล์'),
          ),
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