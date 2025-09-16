// model/car.dart
class Car {
  final String id;
  final String brand;
  final String model;
  final String licensePlate;
  final String color;
  final String purchaseDate;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.licensePlate,
    required this.color,
    required this.purchaseDate,
  });

  // 复制方法，用于修改车辆信息
  Car copyWith({
    String? id,
    String? brand,
    String? model,
    String? licensePlate,
    String? color,
    String? purchaseDate,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }
}