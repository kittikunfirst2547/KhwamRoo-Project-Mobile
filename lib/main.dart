import 'package:flutter/material.dart';
import 'package:khwamroo/screens/firstPage.dart';
import 'package:khwamroo/screens/homePage.dart';
import 'package:khwamroo/screens/login_screen.dart';
import 'package:khwamroo/screens/register_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Firstpage()
    );
  }
}
