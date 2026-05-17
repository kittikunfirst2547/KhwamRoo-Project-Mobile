// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Register
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    // สร้าง user ใน Firebase Auth ก่อน
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    try {
      // เช็ค username ซ้ำ
      final usernameCheck = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        // ลบ Auth user
        await cred.user!.delete();
        throw Exception('username_taken');
      }

      // อัปเดต displayName
      await cred.user!.updateDisplayName(displayName);

      // บันทึกลง Firestore
      final newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        displayName: displayName,
        username: username,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db
          .collection('users')
          .doc(cred.user!.uid)
          .set(newUser.toMap());

    } catch (e) {
      // ป้องกัน Auth user ค้างโดยไม่มีข้อมูลใน Firestore
      await cred.user?.delete();
      rethrow;
    }
  }
  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ดึงข้อมูล User จาก Firestore
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  // Stream User realtime
  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

  // Update Profile
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? username,
    String? profileImageUrl,
    String? bio,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      updates['displayName'] = displayName;
      await _auth.currentUser!.updateDisplayName(displayName);
    }
    if (username != null) updates['username'] = username;
    if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
    if (bio != null) updates['bio'] = bio;

    await _db.collection('users').doc(uid).update(updates);
  }

  // Current User
  User? get currentUser => _auth.currentUser;

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}