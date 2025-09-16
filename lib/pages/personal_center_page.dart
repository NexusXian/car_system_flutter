// lib/pages/psersonal_center_page.dart（保留原文件名拼写）
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// ✅ 导入User和Car模型（需确保Car模型已创建）
import '../model/user.dart';
import '../model/car.dart';
// ✅ 导入车辆管理页面
import 'vehicle_management_page.dart';

class PersonalCenterPage extends StatefulWidget {
  final User user;

  const PersonalCenterPage({
    super.key,
    required this.user,
  });

  @override
  _PersonalCenterPageState createState() => _PersonalCenterPageState();
}

class _PersonalCenterPageState extends State<PersonalCenterPage> {
  final TextEditingController _activationCodeController = TextEditingController(text: "nexus");
  bool _isCarActivated = false;
  bool _isDeviceActivated = false;
  // ✅ 新增：存储当前用户（用于接收车辆更新后的数据）
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    // ✅ 初始化：将传入的用户数据赋值给当前用户
    _currentUser = widget.user;
  }

  // ✅ 新增：用户数据更新回调（车辆添加/删除后触发）
  void _onUserUpdated(User updatedUser) {
    setState(() {
      _currentUser = updatedUser; // 刷新用户数据（含车辆列表）
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserHeader(), // 原用户头部：不修改
            const SizedBox(height: 20),
            _buildInfoCards(), // 原信息卡片：不修改
            const SizedBox(height: 30),
            _buildVehicleManagementButton(), // ✅ 仅修改此按钮的点击逻辑
            const SizedBox(height: 20),
            _buildActivationSection(), // 原产品激活区：不修改
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 原用户头部：完全保留
  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: _currentUser.avatarUrl?.isNotEmpty == true
                ? NetworkImage(_currentUser.avatarUrl!)
                : null,
            child: _currentUser.avatarUrl?.isEmpty ?? true
                ? const Icon(Icons.person, size: 45, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _currentUser.realName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, size: 28, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('消息通知功能待开发')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 28, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('设置页面待开发')),
            ),
          ),
        ],
      ),
    );
  }

  // 原信息卡片：完全保留（身高字段保持原逻辑）
  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoCard(
            icon: Icons.fitness_center,
            value: '${_currentUser.weight}kg',
            label: "体重",
            color: Colors.blue,
          ),
          _buildInfoCard(
            icon: Icons.height,
            value: '178cm', // 保持原固定值，如需用用户数据可改为 '${_currentUser.height}cm'
            label: "身高",
            color: Colors.green,
          ),
          _buildInfoCard(
            icon: Icons.bloodtype,
            value: _currentUser.bloodType,
            label: "血型",
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  // 原单个信息卡片：完全保留
  Widget _buildInfoCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ✅ 仅修改此方法：保留原按钮样式，替换点击逻辑为跳转车辆管理页面
  Widget _buildVehicleManagementButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          // ✅ 原SnackBar改为跳转车辆管理页面
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleManagementPage(
                user: _currentUser, // 传递当前用户（含已有车辆）
                onUserUpdated: _onUserUpdated, // 传递更新回调（用于刷新车辆数量）
              ),
            ),
          ),
          child: Text(
            // ✅ 新增：显示已添加车辆数量（保持原按钮文字样式）
            '车辆管理（已添加 ${_currentUser.cars.length} 辆）',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // 原产品激活区域：完全保留
  Widget _buildActivationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '产品激活',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _activationCodeController,
            decoration: InputDecoration(
              labelText: '激活码',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _activationCodeController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('激活码已复制')),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _buildDeviceActivationButton(
                deviceName: '车载电脑 c01',
                isActivated: _isCarActivated,
                onPressed: () {
                  setState(() => _isCarActivated = !_isCarActivated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(
                        _isCarActivated ? '车载电脑c01已激活' : '车载电脑c01已取消激活'
                    )),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildDeviceActivationButton(
                deviceName: '嵌入式设备 e01',
                isActivated: _isDeviceActivated,
                onPressed: () {
                  setState(() => _isDeviceActivated = !_isDeviceActivated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(
                        _isDeviceActivated ? '嵌入式设备e01已激活' : '嵌入式设备e01已取消激活'
                    )),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 原单个设备激活按钮：完全保留
  Widget _buildDeviceActivationButton({
    required String deviceName,
    required bool isActivated,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: isActivated ? Colors.green : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isActivated ? Colors.green : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          elevation: isActivated ? 2 : 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '激活 $deviceName',
              style: TextStyle(
                fontSize: 16,
                color: isActivated ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              isActivated ? Icons.check_circle : Icons.circle_outlined,
              color: isActivated ? Colors.white : Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }
}