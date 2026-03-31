import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // 🔻 Footer
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: (){},icon: Icon(Icons.home, color: Colors.black,size: 30)),
                SizedBox(height: 0),
                Text("หน้าแรก", style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: (){},icon: Icon(Icons.category, color: Colors.grey,size: 30)),
                Text("หมวดหมู่", style: TextStyle(fontSize: 12)),
              ],
            ),
            // ปุ่มกลาง
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(onPressed: (){},icon: Icon(Icons.remove, color: Colors.white,size: 30)),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: (){},icon: Icon(Icons.notifications, color: Colors.grey,size: 30)),
                Text("แจ้งเตือน", style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: (){},icon: Icon(Icons.person, color: Colors.grey,size: 30)),
                Text("โปรไฟล์", style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),

      //  SafeArea ไม่ให้ขอบชน
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header
            Padding(
              padding: EdgeInsets.all(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // โลโก้
                  Container(
                    width: 120,
                    height: 120,
                    child: Image.asset(
                      "assets/images/Logo1.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    children: [
                      Text('Monkey D Luffy',style: TextStyle(fontSize: 15),),
                      SizedBox(width: 10),
                      Container(
                        width: 35,
                        height: 35,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Text('Content'),

          ],
        ),
      ),
    );
  }
}