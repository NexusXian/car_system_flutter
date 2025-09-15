import 'package:flutter/material.dart';

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
  // 当前选中的页面索引
  int _currentIndex = 0;

  // 三个页面的列表
  final List<Widget> _pages = [
    const RealTimeDetectionPage(),
    const DrivingRecordPage(),
    const PersonalCenterPage(),
  ];

  // 导航项被点击时更新状态
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
        type: BottomNavigationBarType.fixed, // 确保在有三个以上项目时标签都显示
      ),
    );
  }
}

// 实时检测页面
class RealTimeDetectionPage extends StatelessWidget {
  const RealTimeDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时检测'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              '实时检测页面',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '显示车辆实时状态和检测信息',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
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
      appBar: AppBar(
        title: const Text('行车记录'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              '行车记录页面',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '查看历史行车数据和记录',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// 个人中心页面
class PersonalCenterPage extends StatelessWidget {
  const PersonalCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              '个人中心页面',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '管理个人信息和设置',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

