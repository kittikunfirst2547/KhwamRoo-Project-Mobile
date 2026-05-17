import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khwamroo/services/auth_service.dart';
import 'package:khwamroo/screens/register_screen.dart';
import 'package:khwamroo/screens/homePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; //ตัวแปรเช็ค
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose(); // ลบตัวควบคุมออกจากหน่วยความจำเพื่อกัน crash by อาจารย์ชนนวี
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async { //รอแบบไม่รีเทินค่า
    if (_emailController.text.trim().isEmpty) {
      _showSnackbar('กรุณาใส่ email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackbar('กรุณาใส่ password');
      return;
    }
    setState(() => _isLoading = true);
    try {
      // ส่งข้อมูลไปให้ Firebase ผ่าน AuthService
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print('✅ Login success');

      if (mounted) { // เช็กว่าผู้ใช้ยังอยู่ในจอไหม
        Navigator.pushAndRemoveUntil( //เปิดหน้าและลบอันก่อนออก
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Login error code: ${e.code}');
      _showSnackbar(_getErrorMessage(e.code));
    } catch (e) {
      print('❌ Login error: $e');
      _showSnackbar('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ไม่พบบัญชีนี้';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';
      case 'invalid-email':
        return 'รูปแบบ email ไม่ถูกต้อง';
      case 'too-many-requests':
        return 'ลองใหม่อีกครั้งในภายหลัง';
      default:
        return 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: SizedBox(
                  width: 2500,
                  height: 200,
                  child: Image.asset('assets/images/Logo1.png',
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 32),

              const Text('เข้าสู่ระบบ',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('ยินดีต้อนรับกลับมา',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 32),

              // Email
              _buildLabel('Email'), //ใช้ซ้ำ
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('minecraft@gmail.com'),
              ),
              const SizedBox(height: 20),

              // Password
              _buildLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration:
                _inputDecoration('กรอกรหัสผ่าน').copyWith(
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

              // ปุ่ม Login
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text('เข้าสู่ระบบ',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              // ไปหน้า Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ยังไม่มีบัญชี? ',
                      style:
                      TextStyle(color: Colors.grey.shade600)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),),
                    child: const Text('สมัครสมาชิก',
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  //global
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