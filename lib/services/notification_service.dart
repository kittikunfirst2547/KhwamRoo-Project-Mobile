// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance; // ← เพิ่ม

  // ── ส่ง Like Notification (เรียกจาก PostDetailScreen) ──
  Future<void> sendLikeNotification({
    required String toUserId,
    required String postId,
    required String postTitle,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    if (toUserId == currentUser.uid) return; // ไม่ส่งให้ตัวเอง

    // ป้องกัน like ซ้ำ
    final existing = await _db
        .collection('notifications')
        .where('toUserId', isEqualTo: toUserId)
        .where('fromUserId', isEqualTo: currentUser.uid)
        .where('postId', isEqualTo: postId)
        .where('type', isEqualTo: 'like')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _db.collection('notifications').add(
      NotificationModel(
        id: '',
        toUserId: toUserId,
        fromUserId: currentUser.uid,
        fromDisplayName: currentUser.displayName ?? 'ผู้ใช้',
        type: NotificationType.like,
        postId: postId,
        postTitle: postTitle,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }

  // ── ส่ง Notification ทั่วไป ───────────────────────
  Future<void> sendNotification({
    required String toUserId,
    required String fromUserId,
    required String fromDisplayName,
    required NotificationType type,
    String postId = '',
    String postTitle = '',
  }) async {
    if (toUserId == fromUserId) return;

    await _db.collection('notifications').add(
      NotificationModel(
        id: '',
        toUserId: toUserId,
        fromUserId: fromUserId,
        fromDisplayName: fromDisplayName,
        type: type,
        postId: postId,
        postTitle: postTitle,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }

  // ── นับ unread (ใช้ใน Homepage badge) ────────────
  Stream<int> getUnreadCount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    return _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── ดึง Notifications ของ User (realtime) ─────────
  Stream<List<NotificationModel>> getNotifications(String uid) {
    return _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  // ── อ่านแล้ว (ทีละตัว) ───────────────────────────
  Future<void> markAsRead(String notificationId) async {
    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // ── อ่านทั้งหมด ───────────────────────────────────
  Future<void> markAllAsRead(String uid) async {
    final batch = _db.batch();
    final unread = await _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}