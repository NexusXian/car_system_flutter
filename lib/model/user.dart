import 'package:car_system_flutter/model/car.dart';

class User {
  String uid;                  // 用户唯一标识（关键：关联车辆数据库的 userId）
  String realName;             // 真实姓名
  String hireDate;             // 入职时间
  int drivingExperience;       // 驾龄
  String idCardNumber;         // 身份证
  String licensePlate;         // 车牌（注：若为“默认车牌”，建议与 cars 列表关联）
  String bloodType;            // 血型
  String residentialAddress;   // 居住地址
  String emergencyContact;     // 紧急联系人
  String allergies;            // 过敏症
  bool isOrganDonor;           // 器官捐赠者 (是/否)
  String medicalNotes;         // 医疗注意事项
  List<String> certificates;   // 技能证书展示
  String familyBrief;          // 家庭情况简要记录
  int subsidy;                 // 津贴 (默认 1000)
  int infractionCount;         // 违规次数
  List<Car> cars;              // 用户关联的车辆列表（核心：与本地数据库联动）
  double weight;               // 体重
  double oxygenSaturation;     // 血氧
  double heartRate;            // 心率
  double bodyTemperature;      // 体温
  double height;               // 身高
  DateTime createdAt;          // 创建时间
  DateTime updatedAt;          // 更新时间
  String? avatarUrl;           // 头像链接（可空）

  User({
    required this.uid,
    required this.realName,
    required this.hireDate,
    required this.drivingExperience,
    required this.idCardNumber,
    required this.licensePlate,
    required this.bloodType,
    required this.residentialAddress,
    required this.emergencyContact,
    required this.allergies,
    required this.isOrganDonor,
    required this.medicalNotes,
    required this.certificates,
    required this.familyBrief,
    required this.subsidy,
    required this.infractionCount,
    required this.cars,        // 初始化时必须传入车辆列表（避免空指针）
    required this.weight,
    required this.oxygenSaturation,
    required this.heartRate,
    required this.bodyTemperature,
    required this.height,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 工厂构造函数：从 JSON 解析 User（关键优化：正确解析 Car 列表）
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      realName: json['realName'] ?? '',
      hireDate: json['hireDate'] ?? '',
      drivingExperience: (json['drivingExperience'] ?? 0).toInt(),
      idCardNumber: json['idCardNumber'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      bloodType: json['bloodType'] ?? '',
      residentialAddress: json['residentialAddress'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      allergies: json['allergies'] ?? '',
      isOrganDonor: _parseBool(json['isOrganDonor']),
      medicalNotes: json['medicalNotes'] ?? '',
      // 优化：将 JSON 中的 Car 列表（Map 格式）转为 Car 对象列表
      cars: (json['cars'] as List<dynamic>?)
          ?.map((carMap) => Car.fromMap(carMap as Map<String, dynamic>))
          .toList() ??
          [],
      certificates: (json['certificates'] as List<dynamic>?)
          ?.map((cert) => cert as String)
          .toList() ??
          [],
      familyBrief: json['familyBrief'] ?? '',
      subsidy: (json['subsidy'] ?? 1000).toInt(),
      infractionCount: (json['infractionCount'] ?? 0).toInt(),
      weight: (json['weight'] ?? 0).toDouble(),
      oxygenSaturation: (json['oxygenSaturation'] ?? 0).toDouble(),
      heartRate: (json['heartRate'] ?? 0).toDouble(),
      bodyTemperature: (json['bodyTemperature'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      avatarUrl: json['avatarUrl'],
      // 优化：DateTime 解析增加容错（避免 JSON 格式错误导致崩溃）
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// 转 JSON（关键优化：将 Car 对象列表转为 Map 列表，支持序列化）
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'realName': realName,
      'hireDate': hireDate,
      'drivingExperience': drivingExperience,
      'idCardNumber': idCardNumber,
      'licensePlate': licensePlate,
      'bloodType': bloodType,
      'residentialAddress': residentialAddress,
      'emergencyContact': emergencyContact,
      'allergies': allergies,
      'isOrganDonor': isOrganDonor,
      'medicalNotes': medicalNotes,
      // 优化：Car 对象通过 toMap() 转为 Map，确保能正常序列化为 JSON
      'cars': cars.map((car) => car.toMap()).toList(),
      'certificates': certificates,
      'familyBrief': familyBrief,
      'subsidy': subsidy,
      'infractionCount': infractionCount,
      'weight': weight,
      'oxygenSaturation': oxygenSaturation,
      'heartRate': heartRate,
      'bodyTemperature': bodyTemperature,
      'height': height,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 初始化构造函数：带默认值（优化：cars 初始化为空列表，避免空指针）
  User.initial()
      : uid = '',
        realName = '',
        hireDate = '',
        drivingExperience = 0,
        idCardNumber = '',
        licensePlate = '',
        bloodType = '',
        residentialAddress = '',
        emergencyContact = '',
        allergies = '',
        isOrganDonor = false,
        medicalNotes = '',
        certificates = [],
        familyBrief = '',
        subsidy = 1000,
        infractionCount = 0,
        cars = [],  // 初始化为空列表，而非 null
        weight = 0.0,
        oxygenSaturation = 0.0,
        heartRate = 0.0,
        bodyTemperature = 0.0,
        height = 0.0,
        avatarUrl = null,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  /// 复制对象并修改部分属性（关键优化：cars 改为可选参数，适配车辆列表更新）
  User copyWith({
    String? uid,
    String? realName,
    String? hireDate,
    int? drivingExperience,
    String? idCardNumber,
    String? licensePlate,
    String? bloodType,
    String? residentialAddress,
    String? emergencyContact,
    String? allergies,
    bool? isOrganDonor,
    String? medicalNotes,
    List<String>? certificates,
    String? familyBrief,
    int? subsidy,
    int? infractionCount,
    // 优化：cars 改为可选参数，默认使用当前对象的 cars（避免每次必须传参）
    List<Car>? cars,
    double? weight,
    double? oxygenSaturation,
    double? heartRate,
    double? bodyTemperature,
    double? height,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      realName: realName ?? this.realName,
      hireDate: hireDate ?? this.hireDate,
      drivingExperience: drivingExperience ?? this.drivingExperience,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      licensePlate: licensePlate ?? this.licensePlate,
      bloodType: bloodType ?? this.bloodType,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      allergies: allergies ?? this.allergies,
      isOrganDonor: isOrganDonor ?? this.isOrganDonor,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      certificates: certificates ?? this.certificates,
      familyBrief: familyBrief ?? this.familyBrief,
      subsidy: subsidy ?? this.subsidy,
      infractionCount: infractionCount ?? this.infractionCount,
      // 使用传入的 cars 或当前对象的 cars（核心：适配车辆添加/删除后的更新）
      cars: cars ?? this.cars,
      weight: weight ?? this.weight,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      heartRate: heartRate ?? this.heartRate,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      height: height ?? this.height,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 布尔值解析辅助函数（保留原逻辑，增加兼容性）
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  /// （可选）添加 User 转 Map 方法：若需将 User 本身存入本地数据库，可使用此方法
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'realName': realName,
      'hireDate': hireDate,
      'drivingExperience': drivingExperience,
      'idCardNumber': idCardNumber,
      'licensePlate': licensePlate,
      'bloodType': bloodType,
      'residentialAddress': residentialAddress,
      'emergencyContact': emergencyContact,
      'allergies': allergies,
      'isOrganDonor': isOrganDonor ? 1 : 0,  // 数据库存储布尔值用 1/0
      'medicalNotes': medicalNotes,
      'familyBrief': familyBrief,
      'subsidy': subsidy,
      'infractionCount': infractionCount,
      'weight': weight,
      'oxygenSaturation': oxygenSaturation,
      'heartRate': heartRate,
      'bodyTemperature': bodyTemperature,
      'height': height,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// （可选）从 Map 解析 User：配合上述 toMap()，支持从数据库读取 User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      realName: map['realName'] ?? '',
      hireDate: map['hireDate'] ?? '',
      drivingExperience: (map['drivingExperience'] ?? 0).toInt(),
      idCardNumber: map['idCardNumber'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      bloodType: map['bloodType'] ?? '',
      residentialAddress: map['residentialAddress'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      allergies: map['allergies'] ?? '',
      isOrganDonor: map['isOrganDonor'] == 1,  // 从 1/0 恢复布尔值
      medicalNotes: map['medicalNotes'] ?? '',
      certificates: [],  // 若证书需存储，需单独设计表关联，此处暂空
      familyBrief: map['familyBrief'] ?? '',
      subsidy: (map['subsidy'] ?? 1000).toInt(),
      infractionCount: (map['infractionCount'] ?? 0).toInt(),
      cars: [],  // 车辆通过单独的 cars 表关联，此处暂空（需通过 uid 查询）
      weight: (map['weight'] ?? 0).toDouble(),
      oxygenSaturation: (map['oxygenSaturation'] ?? 0).toDouble(),
      heartRate: (map['heartRate'] ?? 0).toDouble(),
      bodyTemperature: (map['bodyTemperature'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      avatarUrl: map['avatarUrl'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}