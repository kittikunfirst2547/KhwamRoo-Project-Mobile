// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { like, system }

class NotificationModel {
  final String id;
  final String toUserId;
  final String fromUserId;
  final String fromDisplayName;
  final NotificationType type;
  final String postId;
  final String postTitle;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.toUserId,
    required this.fromUserId,
    required this.fromDisplayName,
    required this.type,
    required this.postId,
    required this.postTitle,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      toUserId: map['toUserId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      fromDisplayName: map['fromDisplayName'] ?? '',
      type: NotificationType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      postId: map['postId'] ?? '',
      postTitle: map['postTitle'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'fromDisplayName': fromDisplayName,
      'type': type.name,
      'postId': postId,
      'postTitle': postTitle,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}