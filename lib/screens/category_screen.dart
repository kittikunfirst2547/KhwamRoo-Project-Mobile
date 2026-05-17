// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:khwamroo/models/post_model.dart';
import 'package:khwamroo/services/post_service.dart';
import 'package:khwamroo/screens/post_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _postService = PostService();
  String _selectedCategory = 'การเงิน';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'การเงิน', 'icon': Icons.attach_money, 'color': Colors.green},
    {'name': 'การเรียน', 'icon': Icons.school, 'color': Colors.blue},
    {'name': 'กีฬา', 'icon': Icons.sports_soccer, 'color': Colors.orange},
    {'name': 'เกม', 'icon': Icons.sports_esports, 'color': Colors.purple},
    {'name': 'Mindset', 'icon': Icons.psychology, 'color': Colors.teal},
    {'name': 'Career', 'icon': Icons.work, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'หมวดหมู่',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryGrid(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Text(
              'โพสต์ในหมวด "$_selectedCategory"',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildPostList()),
        ],
      ),
    );
  }

  // Category Grid
  Widget _buildCategoryGrid() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true, // grid มีขนาดเท่ากับเนื้อหาภายใน
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = cat['name'] == _selectedCategory;
          return GestureDetector(
            onTap: () =>
                setState(() => _selectedCategory = cat['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? (cat['color'] as Color).withOpacity(0.15)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? cat['color'] as Color
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    color: isSelected
                        ? cat['color'] as Color
                        : Colors.grey.shade500,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? cat['color'] as Color
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Post List
  Widget _buildPostList() {
    return StreamBuilder<List<Post>>(
      key: ValueKey(_selectedCategory),
      stream: _postService.getPosts(category: _selectedCategory),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'ยังไม่มีโพสต์ในหมวด "$_selectedCategory"',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        final posts = snap.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, i) => _buildPostCard(posts[i]),
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    final cat = _categories.firstWhere(
          (c) => c['name'] == post.category,
      orElse: () => {'color': Colors.grey},
    );
    final color = cat['color'] as Color;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostDetailScreen(post: post),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6)
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color bar
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.body,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          post.displayName[0],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.displayName,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500),
                      ),
                      const Spacer(),
                      Icon(Icons.favorite_border,
                          size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}