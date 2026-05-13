// lib/screens/notifications_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khwamroo/models/notification_model.dart';
import 'package:khwamroo/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // เปิดหน้านี้ปุ๊บ mark ทั้งหมดเป็น read เลย
    _notificationService.markAllAsRead(_uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'การแจ้งเตือน',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationService.getNotifications(_uid),
        builder: (context, snap) {
          // loading
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error
          if (snap.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาด'));
          }

          // ไม่มี notification
          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'ยังไม่มีการแจ้งเตือน',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final notifications = snap.data!;
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (_, i) =>
                _buildNotificationItem(notifications[i]),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel n) {
    return Container(
      color: n.isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildAvatar(n),
        title: _buildTitle(n),
        subtitle: n.postTitle.isNotEmpty
            ? Text(
          n.postTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 12, color: Colors.grey.shade500),
        )
            : null,
        trailing: Text(
          _timeAgo(n.createdAt),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
        onTap: () => _notificationService.markAsRead(n.id),
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────
  Widget _buildAvatar(NotificationModel n) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.black,
          child: Text(
            n.fromDisplayName.isNotEmpty
                ? n.fromDisplayName[0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        // ไอคอน type มุมขวาล่าง
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _typeColor(n.type),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(
              _typeIcon(n.type),
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Title text ────────────────────────────────────
  Widget _buildTitle(NotificationModel n) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            color: Colors.black, fontSize: 14),
        children: [
          TextSpan(
            text: n.fromDisplayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' ${_typeText(n.type)}'),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────
  String _typeText(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return 'ถูกใจโพสต์ของคุณ';
      case NotificationType.comment:
        return 'แสดงความคิดเห็นในโพสต์ของคุณ';
      case NotificationType.system:
        return 'มีการแจ้งเตือนจากระบบ';
    }
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.system:
        return Colors.orange;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'เมื่อกี้';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    if (diff.inDays < 7) return '${diff.inDays} วันที่แล้ว';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

