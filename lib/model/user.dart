// lib/model/user.dart
import 'package:car_system_flutter/model/car.dart';

class User {
  String uid;
  String realName;             // 真实姓名
  String hireDate;             // 入职时间
  int drivingExperience;       // 驾龄
  String idCardNumber;         // 身份证
  String licensePlate;         // 车牌
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
  List<Car> cars;
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
    required this.weight,
    required this.cars,
    required this.oxygenSaturation,
    required this.heartRate,
    required this.bodyTemperature,
    required this.height,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 工厂构造函数：从 JSON 创建对象
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
      cars: List<Car>.from(json['cars'] ?? []),
      certificates: List<String>.from(json['certificates'] ?? []),
      familyBrief: json['familyBrief'] ?? '',
      subsidy: (json['subsidy'] ?? 1000).toInt(),
      infractionCount: (json['infractionCount'] ?? 0).toInt(),
      weight: (json['weight'] ?? 0).toDouble(),
      oxygenSaturation: (json['oxygenSaturation'] ?? 0).toDouble(),
      heartRate: (json['heartRate'] ?? 0).toDouble(),
      bodyTemperature: (json['bodyTemperature'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// 转 JSON
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
      'certificates': certificates,
      'familyBrief': familyBrief,
      'subsidy': subsidy,
      'infractionCount': infractionCount,
      'weight': weight,
      'oxygenSaturation': oxygenSaturation,
      'heartRate': heartRate,
      'cars': cars,
      'bodyTemperature': bodyTemperature,
      'height': height,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 初始化构造函数：带默认值
  User.initial()
      : uid = '',
        realName = '',
        hireDate = '',
        drivingExperience = 0,
        idCardNumber = '',
        licensePlate = '',
        bloodType = '',
        residentialAddress = '',
        cars= [],
        emergencyContact = '',
        allergies = '',
        isOrganDonor = false,
        medicalNotes = '',
        certificates = [],
        familyBrief = '',
        subsidy = 1000,
        infractionCount = 0,
        weight = 0.0,
        oxygenSaturation = 0.0,
        heartRate = 0.0,
        bodyTemperature = 0.0,
        height = 0.0,
        avatarUrl = null,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  // 复制对象并修改部分属性
  User copyWith({
    String? uid,
    String? realName,
    double? weight,
    double? height,
    String? bloodType,
    String? avatarUrl, required List<Car> cars,
  }) {
    return User(
      uid: uid ?? this.uid,
      realName: realName ?? this.realName,
      hireDate: hireDate,
      drivingExperience: drivingExperience,
      idCardNumber: idCardNumber,
      licensePlate: licensePlate,
      bloodType: bloodType ?? this.bloodType,
      residentialAddress: residentialAddress,
      emergencyContact: emergencyContact,
      allergies: allergies,
      isOrganDonor: isOrganDonor,
      medicalNotes: medicalNotes,
      certificates: certificates,
      familyBrief: familyBrief,
      subsidy: subsidy,
      cars: cars,
      infractionCount: infractionCount,
      weight: weight ?? this.weight,
      oxygenSaturation: oxygenSaturation,
      heartRate: heartRate,
      bodyTemperature: bodyTemperature,
      height: height ?? this.height,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 布尔值解析辅助函数
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }
}