import 'package:flutter/material.dart';
import 'pages/personal_center_page.dart';
import 'model/user.dart';
import 'pages/real_time_detection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '行车助手',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1;

  // 模拟用户数据
  late final User _currentUser = User.initial().copyWith(
    uid: "USER001",
    realName: "NexusXian",
    weight: 70.5,
    height: 178,
    bloodType: "O型",
    avatarUrl: "https://bkimg.cdn.bcebos.com/pic/a50f4bfbfbedab6434c0d6c8f836afc379311e03?x-bce-process=image/format,f_auto/quality,Q_70/resize,m_lfit,limit_1,w_536", cars: [],
  );

  late final List<Widget> _pages = [
    const RealTimeDetectionPage(),
    const DrivingRecordPage(),
    PersonalCenterPage(user: _currentUser),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: '实时检测',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '行车记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '个人中心',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}



// 行车记录页面
class DrivingRecordPage extends StatelessWidget {
  const DrivingRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('行车记录')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('行车记录页面', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('查看历史行车数据和记录', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
