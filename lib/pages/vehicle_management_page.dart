import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../model/car.dart';
import '../model/user.dart';

// 数据库帮助类
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cars.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final pathStr = path.join(dbPath, filePath);

    return await openDatabase(pathStr, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cars (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        licensePlate TEXT NOT NULL,
        color TEXT NOT NULL,
        purchaseDate TEXT NOT NULL
      )
    ''');
  }

  // 为用户添加车辆
  Future<void> insertCar(Car car, String userId) async {
    final db = await instance.database;
    await db.insert(
      'cars',
      {
        ...car.toMap(),
        'userId': userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取用户的所有车辆
  Future<List<Car>> getCarsForUser(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'cars',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) {
      return [];
    } else {
      return maps.map((map) => Car.fromMap(map)).toList();
    }
  }

  // 删除车辆
  Future<void> deleteCar(String carId) async {
    final db = await instance.database;
    await db.delete(
      'cars',
      where: 'id = ?',
      whereArgs: [carId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class VehicleManagementPage extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdated;

  const VehicleManagementPage({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<VehicleManagementPage> createState() => _VehicleManagementPageState();
}

class _VehicleManagementPageState extends State<VehicleManagementPage> {
  late User _currentUser;
  late List<Car> _userCars;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadUserCars();
  }

  // 从数据库加载用户车辆
  Future<void> _loadUserCars() async {
    try {
      final cars = await DatabaseHelper.instance.getCarsForUser(_currentUser.uid);
      setState(() {
        _userCars = cars;
        _isLoading = false;
        // 更新用户对象中的车辆列表
        _currentUser = _currentUser.copyWith(cars: cars);
        widget.onUserUpdated(_currentUser);
      });
    } catch (e) {
      debugPrint('加载车辆失败: $e');
      setState(() {
        _userCars = [];
        _isLoading = false;
      });
    }
  }

  // 添加新车辆
  void _addNewCar(Car newCar) async {
    try {
      // 保存到数据库
      await DatabaseHelper.instance.insertCar(newCar, _currentUser.uid);

      // 更新UI
      setState(() {
        final updatedCars = List<Car>.from(_userCars);
        updatedCars.add(newCar);
        _userCars = updatedCars;
        _currentUser = _currentUser.copyWith(cars: updatedCars);
        widget.onUserUpdated(_currentUser);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('车辆添加成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: ${e.toString()}')),
        );
      }
    }
  }

  // 删除车辆
  void _deleteCar(String carId) async {
    try {
      // 从数据库删除
      await DatabaseHelper.instance.deleteCar(carId);

      // 更新UI
      setState(() {
        final updatedCars = _userCars.where((car) => car.id != carId).toList();
        _userCars = updatedCars;
        _currentUser = _currentUser.copyWith(cars: updatedCars);
        widget.onUserUpdated(_currentUser);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('车辆已删除')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: ${e.toString()}')),
      );
    }
  }

  // 导航到添加车辆页面
  void _navigateToAddCarPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVehiclePage(
          onAddCar: _addNewCar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('车辆管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userCars.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              '暂无车辆信息',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              '点击下方按钮添加您的车辆',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userCars.length,
        itemBuilder: (context, index) {
          final car = _userCars[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.blue, size: 40),
              title: Text('${car.brand} ${car.model}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('车牌号: ${car.licensePlate}'),
                  Text('颜色: ${car.color}'),
                  Text('登记日期: ${car.purchaseDate}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCar(car.id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCarPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 添加车辆页面
class AddVehiclePage extends StatefulWidget {
  final Function(Car) onAddCar;

  const AddVehiclePage({super.key, required this.onAddCar});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _purchaseDateController = TextEditingController();

  // 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _purchaseDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newCar = Car(
        id: const Uuid().v4(), // 使用uuid生成唯一ID
        brand: _brandController.text,
        model: _modelController.text,
        licensePlate: _licensePlateController.text,
        color: _colorController.text,
        purchaseDate: _purchaseDateController.text,
      );
      widget.onAddCar(newCar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加车辆'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: '车辆品牌',
                  icon: Icon(Icons.branding_watermark),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入车辆品牌';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: '车辆型号',
                  icon: Icon(Icons.model_training),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入车辆型号';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: '车牌号',
                  icon: Icon(Icons.confirmation_num),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入车牌号';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: '车辆颜色',
                  icon: Icon(Icons.color_lens),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入车辆颜色';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _purchaseDateController,
                decoration: const InputDecoration(
                  labelText: '购买日期',
                  icon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择购买日期';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('添加车辆'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}