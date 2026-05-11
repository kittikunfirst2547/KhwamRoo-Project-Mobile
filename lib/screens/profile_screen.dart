import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  final String displayName;
  const ProfileScreen({required this.userId,required this.displayName, super.key});

  // mock โพสต์ของคนนี้ (ทีหลังดึงจาก Firestore)
  List<Map<String, dynamic>> get _userPosts => [
    {
      'title': 'โพสต์ของ $displayName',
      'body': 'เนื้อหาโพสต์แรก...',
      'category': 'การเงิน',
      'likes': 10,
    },
  ];

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
        title: Text(displayName,
            style: const TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [

          // Profile header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.black,
                  child: Text(
                    displayName[0],
                    style: const TextStyle(
                        fontSize: 28, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_userPosts.length} โพสต์',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // โพสต์ของ user นี้
          Expanded(
            child: ListView.builder(
              itemCount: _userPosts.length,
              itemBuilder: (_, i) {
                final post = _userPosts[i];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['category'],
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500)),
                      const SizedBox(height: 6),
                      Text(post['title'],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(post['body'],
                          style: TextStyle(
                              color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}