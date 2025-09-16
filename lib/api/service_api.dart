import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 用于日期格式化

// --- 1. API响应模型 ---
class ApiResponse {
  final int code;
  final String message;
  final List<dynamic> data;

  ApiResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] ?? [], // 确保data不为null
    );
  }
}

// --- 2. 违规记录数据模型 ---
class ViolationRecord {
  final int id;
  final String realName;
  final String idCardNumber;
  final String record; // 违规类型，例如 "疲劳驾驶"
  final DateTime createAt; // 创建时间
  final String licensePlate; // 车牌号
  final DateTime updateAt; // 更新时间

  ViolationRecord({
    required this.id,
    required this.realName,
    required this.idCardNumber,
    required this.record,
    required this.createAt,
    required this.licensePlate,
    required this.updateAt,
  });

  // 从 JSON 对象创建 ViolationRecord 实例的工厂构造函数
  factory ViolationRecord.fromJson(Map<String, dynamic> json) {
    return ViolationRecord(
      id: json['id'],
      realName: json['realName'] ?? '',
      idCardNumber: json['IDCardNumber'] ?? '',
      record: json['record'] ?? '',
      createAt: DateTime.parse(json['CreateAt']),
      licensePlate: json['licensePlate'] ?? '',
      updateAt: DateTime.parse(json['UpdateAt']),
    );
  }

  // 格式化日期和时间，方便显示
  String get formattedCreateAt {
    return DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  }
}

// --- 3. 用于封装处理结果 ---
class DrivingData {
  final List<ViolationRecord> records; // 违规记录列表
  final Map<String, int> stats; // 统计数据
  final String message; // 接口返回的消息

  DrivingData({
    required this.records,
    required this.stats,
    required this.message,
  });
}

// --- 4. API 服务 ---
class ApiService {
  // 请将这里的 URL 替换为您的真实 API 地址
  static const String _apiUrl = 'http://192.168.0.102:8100/api/record/findByIDCard';

  // 发送 POST 请求获取驾驶数据
  static Future<DrivingData> fetchDrivingRecords({required String idCardNumber}) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'idCardNumber': idCardNumber, // 使用传入的身份证号
        }),
      );

      // 处理响应数据
      if (response.statusCode == 200) {
        // 解析完整的API响应
        final ApiResponse apiResponse = ApiResponse.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );

        // 根据code判断是否有数据
        if (apiResponse.code == 200) {
          // 将JSON列表转换为ViolationRecord列表
          final List<ViolationRecord> records = apiResponse.data
              .map((data) => ViolationRecord.fromJson(data))
              .toList();

          // 计算统计数据
          final Map<String, int> stats = {};
          for (var record in records) {
            stats.update(
              record.record,
                  (value) => value + 1,
              ifAbsent: () => 1,
            );
          }

          return DrivingData(
            records: records,
            stats: stats,
            message: apiResponse.message,
          );
        } else {
          // code不等于200，返回空记录列表
          return DrivingData(
            records: [],
            stats: {},
            message: apiResponse.message,
          );
        }
      } else {
        // 网络请求失败
        throw Exception('请求失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      // 捕获网络或其他异常
      throw Exception('加载驾驶记录失败: $e');
    }
  }
}
