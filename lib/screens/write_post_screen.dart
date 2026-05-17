import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khwamroo/models/post_model.dart';
import 'package:khwamroo/services/ai_service.dart';
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
  final _aiService = AiService();
  String _selectedCategory = 'การเงิน';
  bool _isLoading = false;

  final List<String> _categories = [
    'การเงิน', 'การเรียน', 'กีฬา', 'เกม', 'Mindset', 'Career'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // เช็คว่ามีเนื้อหาที่พิมพ์อยู่ไหม
  bool get _hasContent =>
      _titleController.text.trim().isNotEmpty ||
          _bodyController.text.trim().isNotEmpty;

  // Dialog ยืนยันการออก
  Future<bool> _confirmExit() async {
    if (!_hasContent) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ออกจากหน้านี้?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('เนื้อหาที่เขียนไว้จะไม่ถูกบันทึก'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('เขียนต่อ',
                style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ออกโดยไม่บันทึก',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
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

      final result = await _aiService.moderate(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        category: _selectedCategory,
      );

      if (!result.passed) {
        _showRejectDialog(result.reason);
        return;
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
      );

      await _postService.addPost(post);

      if (mounted) {
        _showSnackbar('โพสต์สำเร็จ! 🎉');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackbar('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRejectDialog(String reason) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('โพสต์ไม่ผ่านการตรวจสอบ',
                style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('เหตุผล:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(reason,
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Text(
              'กรุณาแก้ไขเนื้อหาให้มีสาระและตรงหมวดหมู่',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('แก้ไขโพสต์',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _confirmExit();
        if (shouldExit && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () async {
              final shouldExit = await _confirmExit();
              if (shouldExit && mounted) Navigator.pop(context);
            },
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
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
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
                  hintText: 'เขียนเนื้อหาที่มีสาระ อย่างน้อย 50 ตัวอักษร...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
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
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}