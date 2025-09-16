// pages/vehicle_management_page.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/car.dart';
import '../model/user.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  // 添加新车辆
  void _addNewCar(Car newCar) {
    setState(() {
      final updatedCars = List<Car>.from(_currentUser.cars);
      updatedCars.add(newCar);
      _currentUser = _currentUser.copyWith(cars: updatedCars);
      widget.onUserUpdated(_currentUser);
    });
    Navigator.pop(context);
  }

  // 删除车辆
  void _deleteCar(String carId) {
    setState(() {
      final updatedCars = _currentUser.cars.where((car) => car.id != carId).toList();
      _currentUser = _currentUser.copyWith(cars: updatedCars);
      widget.onUserUpdated(_currentUser);
    });
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
      body: _currentUser.cars.isEmpty
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
        itemCount: _currentUser.cars.length,
        itemBuilder: (context, index) {
          final car = _currentUser.cars[index];
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
        _purchaseDateController.text = "${picked.year}-${picked.month}-${picked.day}";
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