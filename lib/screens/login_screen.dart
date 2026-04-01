import 'package:flutter/material.dart';
import 'package:khwamroo/screens/homePage.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color primaryBlack = Color(0xFF000000);
  static const Color greyText = Color(0xFF9E9E9E);
  static const Color lightGreyField = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          //บีบซ้ายขวา
          padding:  EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              // --- ส่วนของ Logo และ Title ---
              Container(
                width: double.infinity,
                height: 100,
                child: Image.asset(
                  "assets/images/Logo1.png",
                  fit: BoxFit.cover,
                ),
              ),
             SizedBox(height: 24),
              Text(
                "ยินดีต้อนรับ",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryBlack,
                ),
              ),
               Text(
                "ลงชื่อผู้เข้าใช้เพื่อเข้าสู่ระบบ",
                style: TextStyle(fontSize: 14, color: greyText),
              ),

               SizedBox(height: 40),

              // --- Field: Email ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "อีเมล",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
                ),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "abc@gmail.com",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // --- Field: Password ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "รหัสผ่าน",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: lightGreyField,
                  hintText: "*********",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.visibility_off_outlined, color: greyText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // แบบสีเทาไม่มีเส้นขอบตามรูป
                  ),
                ),
              ),
              // --- Forget Password ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "ลืมรหัสผ่าน?",
                    style: TextStyle(color: greyText, fontSize: 13),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // --- Login Button ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    {
                      Navigator.push(context , MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  },
                  child: const Text(
                    "เข้าสู่ระบบ",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // --- Divider "หรือ" ---
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("หรือ", style: TextStyle(color: greyText)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

               SizedBox(height: 24),

              // --- Social Login (Google/Apple) ---
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Text("อื่นๆ", style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}