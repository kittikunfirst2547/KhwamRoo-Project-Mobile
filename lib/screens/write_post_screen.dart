import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwamroo/models/post_model.dart';
import 'package:khwamroo/services/post_service.dart';

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final _postService = PostService();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedCategory = 'การเงิน';
  bool _isLoading = false;
  File? _selectedImage;        // ← รูปที่เลือก
  String? _uploadedImageUrl;   // ← url หลัง upload

  final List<String> _categories = [
    'การเงิน', 'การเรียน', 'กีฬา', 'เกม', 'Mindset', 'Career'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // เลือกรูปจาก gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,        // ← compress รูปก่อน upload
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // ถ่ายรูปด้วยกล้อง
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // แสดง bottom sheet เลือก gallery หรือ camera
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('เลือกจาก Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ถ่ายรูป'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // upload รูปไป Firebase Storage
  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child(fileName);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      _showSnackbar('อัปโหลดรูปไม่สำเร็จ: $e');
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackbar('กรุณาใส่หัวข้อ');
      return;
    }
    if (_bodyController.text.trim().length < 50) {
      _showSnackbar('เนื้อหาต้องมีอย่างน้อย 50 ตัวอักษร');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackbar('กรุณา login ก่อน');
        return;
      }

      // upload รูปถ้ามี
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!, user.uid);
      }

      final post = Post(
        id: '',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        category: _selectedCategory,
        userId: user.uid,
        displayName: user.displayName ?? 'ไม่ระบุชื่อ',
        createdAt: DateTime.now(),
        likes: 0,
        imageUrl: imageUrl,   // ← เพิ่ม field ใหม่
      );

      await _postService.addPost(post);

      if (mounted) {
        _showSnackbar('โพสต์สำเร็จ! 🎉');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackbar('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('เขียนโพสต์',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('โพสต์',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Category
            const Text('หมวดหมู่',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 13,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // หัวข้อ
            const Text('หัวข้อ *',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'ตั้งหัวข้อให้น่าสนใจ...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  const BorderSide(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // เนื้อหา
            const Text('เนื้อหา *',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              maxLines: 10,
              maxLength: 5000,
              decoration: InputDecoration(
                hintText:
                'เขียนเนื้อหาที่มีสาระ อย่างน้อย 50 ตัวอักษร...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  const BorderSide(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // รูปภาพ
            const Text('รูปภาพ (ไม่บังคับ)',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),

            // ถ้ายังไม่ได้เลือกรูป
            if (_selectedImage == null)
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('กดเพื่อเพิ่มรูปภาพ',
                          style: TextStyle(
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),

            // ถ้าเลือกรูปแล้ว
            if (_selectedImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // ปุ่มลบรูป
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  // ปุ่มเปลี่ยนรูป
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _showImageOptions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('เปลี่ยนรูป',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'เนื้อหาต้องมีสาระ ไม่มีดราม่า และตรงกับหมวดหมู่ที่เลือก',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}