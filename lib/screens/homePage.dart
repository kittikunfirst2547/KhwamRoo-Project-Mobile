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
  final _postService = PostService(); //ประกาศใช้งาน Service เพื่อเรียกข้อมูลโพสต์จาก Firebase
  String _selectedCategory = 'ทั้งหมด'; //default

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
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          SizedBox(
            width: 120,
            height: 120,
            child: Image.asset('assets/images/Logo1.png', fit: BoxFit.cover),
          ),
          // โปรไฟล์มุมขวาบน
          GestureDetector( //ตรวจจับการกระทำของผู้ใช้
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
                // ชื่อ
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black,
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName.toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Chips ───────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 56,
      child: ListView.builder( //loop ข้อมูลตาม list ด้านบนเด้อ
        scrollDirection: Axis.horizontal, //เลื่อนแนวนอน
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory; //cat นี้ถูกเลือกอยู่บ่
          return Padding(
            padding: const EdgeInsets.only(right: 8,top: 4),
            child: ChoiceChip( //widget ใช้เลือก
              label: Text(cat),
              selected: isSelected,
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              // setState => rebuild และอัพเดท
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        },
      ),
    );
  }

  // ── Feed ดึงจาก Firestore จริง ────────────────────
  Widget _buildFeed() {
    return StreamBuilder<List<Post>>( // rebuild ที่มีอัพเดทจาก stream
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

        final posts = snap.data!; //เพื่อยืนยันว่าไม่เป็น null
        return ListView.builder(
          itemCount: posts.length, // กำหนดจำนวนแถวตามจำนวนโพสต์ที่ดึงมาได้
          itemBuilder: (_, i) => _buildPostCard(posts[i]), // ในแต่ละแถว (i) ให้ส่งข้อมูลโพสต์อันนั้น posts[i] ไปวาดที่ฟังก์ชัน _buildPostCard
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
                overflow: TextOverflow.ellipsis), //ถ้าเกินให้ใส่จุดไข่ปลา
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
              onPressed: () {
                Navigator.pushNamed(context, '/write');
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          StreamBuilder<int>( // ใช้ Stream ดูจำนวนที่ยังไม่ได้อ่าน
            stream: NotificationService().getUnreadCount(),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
                child: Stack( // ใช้ Stack เพื่อวางตัวเลขทับบนไอคอน
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
              final user = FirebaseAuth.instance.currentUser; // เช็กว่า Login อยู่ไหม
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      userId: user.uid, //รอรับข้อมูล
                      displayName: user.displayName ?? '',
                    ),
                  ),
                );
              } else {
                // ถ้ายังไม่ Login ให้ไปหน้า Login
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