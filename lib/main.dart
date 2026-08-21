import 'package:flutter/material.dart';
import 'package:w3_peerawit/api_service.dart';
import 'package:w3_peerawit/model.dart';

// ฟังก์ชัน main คือจุดเริ่มต้นของโปรแกรม Flutter
// runApp() จะนำ Widget ที่ส่งเข้าไป (MyApp) ไปแสดงผลบนหน้าจอ
void main() {
  runApp(const MyApp());
}

// MyApp คือ Widget หลักของแอป (root widget)
// เป็น StatelessWidget เพราะตัวมันเองไม่มีสถานะ (state) ที่เปลี่ยนแปลง
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp คือ Widget ที่ครอบแอปทั้งหมด กำหนดธีม, ชื่อแอป, และหน้าแรกที่จะแสดง
    return MaterialApp(
      theme: ThemeData(
        // สร้างชุดสีของธีมทั้งหมดโดยอัตโนมัติจากสีหลัก (seedColor)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // หน้าแรกที่จะแสดงเมื่อเปิดแอป
      home: const MyHomePage(title: 'Student'),
    );
  }
}

// MyHomePage เป็น StatefulWidget เพราะหน้านี้มีข้อมูลที่เปลี่ยนแปลงได้
// (เช่น รายชื่อนักเรียนที่โหลดมาจาก API)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // รับค่าชื่อหน้ามาจาก widget แม่ (MyApp)
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// คลาส State ที่เก็บสถานะของ MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // เพิ่มค่า counter แล้วเรียก setState เพื่อสั่งให้ build() ทำงานใหม่
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ใช้สีพื้นหลังอ่อนๆ ให้การ์ดสีขาวดูเด่นและสบายตา
      backgroundColor: colorScheme.surfaceContainerLowest,

      // แถบด้านบนของหน้า ปรับให้ดูสะอาดตาขึ้น
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        elevation: 2,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // เนื้อหาหลัก ใช้ FutureBuilder เพื่อรอผลลัพธ์จากการเรียก API แบบ asynchronous
      body: FutureBuilder(
        future: ApiService.fetchStudent(), // เรียก API ดึงรายชื่อนักเรียน
        builder: (context, snapshot) {
          // กรณี 1: ข้อมูลยังโหลดไม่เสร็จ -> แสดงวงกลมหมุน (loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // กรณี 2: เกิดข้อผิดพลาดระหว่างโหลด -> แสดงข้อความ error พร้อมไอคอน
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 12),
                  Text(
                    "เกิดข้อผิดพลาด: ${snapshot.error}",
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // กรณี 3: โหลดสำเร็จ -> เก็บข้อมูลไว้ในตัวแปร students
          final students = snapshot.data!;

          // แสดงรายชื่อนักเรียนทั้งหมดในรูปแบบลิสต์ พร้อมระยะห่างรอบขอบจอ
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final s = students[index];

              // แสดงข้อมูลนักเรียนแต่ละคนในรูปแบบการ์ดที่ดูทันสมัยขึ้น
              // - มุมโค้ง, เงาเบาๆ, รูปโปรไฟล์วงกลม, ไอคอนประกอบ
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    // แตะที่การ์ดทั้งใบก็ไปหน้ารายละเอียดได้เช่นกัน
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetaiPage(Student: s),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // รูปโปรไฟล์วงกลม
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colorScheme.primaryContainer,
                            backgroundImage: NetworkImage(s.avatar),
                          ),
                          const SizedBox(width: 14),

                          // ชื่อและเบอร์โทรของนักเรียน
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      s.phone,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ไอคอนลูกศรบอกว่ากดดูรายละเอียดได้
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// หน้าแสดงรายละเอียดของนักเรียนแต่ละคน
// เป็น StatelessWidget เพราะแค่รับข้อมูลมาแสดงผล ไม่มีการเปลี่ยนสถานะ
class DetaiPage extends StatelessWidget {
  // ข้อมูลนักเรียนที่ส่งมาจากหน้าก่อนหน้า
  final Model Student;
  const DetaiPage({super.key, required this.Student});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: const Text("รายละเอียดนักเรียน"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // รูปโปรไฟล์ขนาดใหญ่ ทรงวงกลม พร้อมเงารอบตัว
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: NetworkImage(Student.avatar),
                ),
              ),
              const SizedBox(height: 20),

              // ชื่อของนักเรียน
              Text(
                Student.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // เบอร์โทรศัพท์ แสดงในรูปแบบ chip เล็กๆ พร้อมไอคอน
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Student.phone,
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
