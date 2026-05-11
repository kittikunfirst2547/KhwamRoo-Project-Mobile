import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:khwamroo/firebase_options.dart';
import 'package:khwamroo/screens/firstPage.dart';
import 'package:khwamroo/screens/login_screen.dart';
import 'package:khwamroo/screens/register_screen.dart';
import 'package:khwamroo/screens/homePage.dart';
import 'package:khwamroo/screens/write_post_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase init success');
  } catch (e) {
    print('❌ Firebase init error: $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(           // ← เอา const ออก
      debugShowCheckedModeBanner: false,
      home: const Firstpage(),
      routes: {                   // ← เพิ่ม routes
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const Homepage(),
        '/write': (_) => const WritePostScreen(),   // ← เพิ่ม
      },
    );
  }
}