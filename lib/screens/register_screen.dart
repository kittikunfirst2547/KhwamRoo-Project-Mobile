// lib/screens/register_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khwamroo/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // ← เพิ่ม
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose(); // ← เพิ่ม
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _onRegister() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackbar('กรุณาใส่ชื่อที่แสดง');
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showSnackbar('กรุณาใส่ username');
      return;
    }
    final usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');
    if (!usernameRegex.hasMatch(_usernameController.text.trim())) {
      _showSnackbar('username ใช้ได้เฉพาะ a-z, 0-9, _ และ 3-20 ตัว');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showSnackbar('กรุณาใส่ email');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showSnackbar('password ต้องมีอย่างน้อย 6 ตัวอักษร');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _nameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
      );

      // ── Dialog หลังสมัครสำเร็จ ────────────────────
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ยินดีต้อนรับ! 🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _nameController.text.trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'สมัครสมาชิกสำเร็จแล้ว\nพร้อมเริ่มเรียนรู้และแบ่งปันได้เลย',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'เริ่มใช้งานเลย →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // ─────────────────────────────────────────────

    } on FirebaseAuthException catch (e) {
      _showSnackbar(_getFirebaseError(e.code));
    } catch (e) {
      if (e.toString().contains('username_taken')) {
        _showSnackbar('username นี้ถูกใช้งานแล้ว');
      } else {
        _showSnackbar('เกิดข้อผิดพลาด: $e');
        print('❌ Register error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'email นี้ถูกใช้งานแล้ว';
      case 'invalid-email':
        return 'รูปแบบ email ไม่ถูกต้อง';
      case 'weak-password':
        return 'password ง่ายเกินไป';
      default:
        return 'สมัครไม่สำเร็จ กรุณาลองใหม่';
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('สมัครสมาชิก',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('เข้าร่วมชุมชนคนรักการเรียนรู้',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 32),

            // ── ชื่อที่แสดง ──────────────────────────
            _buildLabel('ชื่อที่แสดง'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('กรอกชื่อของคุณ'),
            ),
            const SizedBox(height: 20),

            // ── Username ─────────────────────────────
            _buildLabel('Username'),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: _inputDecoration('เช่น john_doe123').copyWith(
                prefixStyle: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
                helperText: 'ใช้ได้เฉพาะ a-z, 0-9, _ และ 3-20 ตัว',
                helperStyle: TextStyle(color: Colors.grey.shade500),
              ),
              // บังคับ lowercase อัตโนมัติ
              onChanged: (val) {
                final lower = val.toLowerCase();
                if (val != lower) {
                  _usernameController.value =
                      _usernameController.value.copyWith(
                        text: lower,
                        selection: TextSelection.collapsed(
                            offset: lower.length),
                      );
                }
              },
            ),
            const SizedBox(height: 20),

            // ── Email ────────────────────────────────
            _buildLabel('Email'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('example@email.com'),
            ),
            const SizedBox(height: 20),

            // ── Password ─────────────────────────────
            _buildLabel('Password'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _inputDecoration('อย่างน้อย 6 ตัวอักษร').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── ปุ่ม Register ─────────────────────────
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('สมัครสมาชิก',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // ── ไปหน้า Login ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('มีบัญชีอยู่แล้ว? ',
                    style: TextStyle(color: Colors.grey.shade600)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('เข้าสู่ระบบ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w600));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
    );
  }
}