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

  // 转换为Map，用于数据库存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'licensePlate': licensePlate,
      'color': color,
      'purchaseDate': purchaseDate,
    };
  }

  // 从Map创建Car对象，用于从数据库读取
  static Car fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      licensePlate: map['licensePlate'],
      color: map['color'],
      purchaseDate: map['purchaseDate'],
    );
  }
}
