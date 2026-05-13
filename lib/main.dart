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
      home: const AuthGate(),
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


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    //Widget ทำหน้าที่รอดูกระแสข้อมูล
    return StreamBuilder<User?>( //บอกว่าข้อมูลที่ไหลมาในท่อนี้คือวัตถุ User หรือ null
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const Homepage();
        }

        return const Firstpage();
      },
    );
  }
}