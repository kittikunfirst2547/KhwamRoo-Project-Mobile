import 'package:flutter/material.dart';
import 'package:khwamroo/screens/login_screen.dart';
import 'package:khwamroo/screens/register_screen.dart';

class Firstpage extends StatelessWidget {
  const Firstpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //ส่วนบน
            Container(
            height: 450,
            width: double.infinity,
            color: Colors.black87,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("./assets/images/Logo1.png"),
                Text(
                  'ความรู้',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(height: 5),
                Text(
                  "Learn. Share. Grow.\nพื้นที่ของคนที่อยากพัฒนาตัวเอง",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 🔽 ส่วนล่าง
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Khwamroo คือพื้นที่สำหรับการเรียนรู้และแบ่งปันความรู้\nจากผู้คนจริงในหลากหลายหมวดหมู่\nไม่มีดราม่า ไม่มีโฆษณารบกวน\nมีแต่เนื้อหาที่มีคุณค่า",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 30),
                  Spacer(),
                  //ปุ่ม
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                          ),
                          onPressed: () {
                            Navigator.push(context , MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text("Login",style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () { Navigator.push(context , MaterialPageRoute(builder: (context) => RegisterScreen(),
                          ));},
                          child: Text("Register",style: TextStyle(color: Colors.black87,),
                        ),
                      ),
                      )],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
