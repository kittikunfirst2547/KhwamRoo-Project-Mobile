import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:khwamroo/firebase_options.dart';
import 'package:khwamroo/screens/category_screen.dart';
import 'package:khwamroo/screens/firstPage.dart';
import 'package:khwamroo/screens/login_screen.dart';
import 'package:khwamroo/screens/profile_screen.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // ← เปลี่ยนแล้ว
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const Homepage(),
        '/write': (_) => const WritePostScreen(),
        '/category': (_) => const CategoryScreen(),
        '/profile': (_) => ProfileScreen(
          userId: FirebaseAuth.instance.currentUser!.uid,
          displayName: FirebaseAuth.instance.currentUser!.displayName ?? '',
        ),
      },
    );
  }
}

// ── วางไว้ท้าย file ──────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const Homepage(); // login แล้ว
        }

        return const Firstpage(); // ยังไม่ login
      },
    );
  }
}