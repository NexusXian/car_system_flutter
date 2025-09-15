class Driver {
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
  double oxygenSaturation;     // 血氧
  double heartRate;            // 心率
  double bodyTemperature;      // 体温
  DateTime createAt;
  DateTime updateAt;

  Driver({
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
    required this.oxygenSaturation,
    required this.heartRate,
    required this.bodyTemperature,
    required this.createAt,
    required this.updateAt,
  });

  /// 工厂构造函数：从 JSON 创建对象
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      uid: json['UID'] ?? '',
      realName: json['realName'] ?? '',
      hireDate: json['hireDate'] ?? '',
      drivingExperience: json['drivingExperience'] ?? 0,
      idCardNumber: json['IDCardNumber'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      bloodType: json['BloodType'] ?? '',
      residentialAddress: json['ResidentialAddress'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      allergies: json['allergies'] ?? '',
      isOrganDonor: json['IsOrganDonor'] ?? false,
      medicalNotes: json['MedicalNotes'] ?? '',
      certificates: List<String>.from(json['certificates'] ?? []),
      familyBrief: json['familyBrief'] ?? '',
      subsidy: json['subsidy'] ?? 1000,
      infractionCount: json['infractionCount'] ?? 0,
      oxygenSaturation: (json['oxygenSaturation'] ?? 0).toDouble(),
      heartRate: (json['heartRate'] ?? 0).toDouble(),
      bodyTemperature: (json['bodyTemperature'] ?? 0).toDouble(),
      createAt: DateTime.tryParse(json['create_at'] ?? '') ?? DateTime.now(),
      updateAt: DateTime.tryParse(json['update_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// 转 JSON
  Map<String, dynamic> toJson() {
    return {
      'UID': uid,
      'realName': realName,
      'hireDate': hireDate,
      'drivingExperience': drivingExperience,
      'IDCardNumber': idCardNumber,
      'licensePlate': licensePlate,
      'BloodType': bloodType,
      'ResidentialAddress': residentialAddress,
      'emergencyContact': emergencyContact,
      'allergies': allergies,
      'IsOrganDonor': isOrganDonor,
      'MedicalNotes': medicalNotes,
      'certificates': certificates,
      'familyBrief': familyBrief,
      'subsidy': subsidy,
      'infractionCount': infractionCount,
      'oxygenSaturation': oxygenSaturation,
      'heartRate': heartRate,
      'bodyTemperature': bodyTemperature,
      'create_at': createAt.toIso8601String(),
      'update_at': updateAt.toIso8601String(),
    };
  }

  /// 初始化构造函数：带默认值
  Driver.initial()
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
        oxygenSaturation = 0.0,
        heartRate = 0.0,
        bodyTemperature = 0.0,
        createAt = DateTime.now(),
        updateAt = DateTime.now();
}

