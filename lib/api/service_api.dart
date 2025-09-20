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

// --- 4. 报告相关数据模型 ---
class DrivingReportData {
  final String generateTime;
  final String timeRange;
  final double totalMileage;
  final int totalViolations;
  final int drivingScore;
  final List<ViolationStat> violationStats;
  final List<String> suggestions;

  DrivingReportData({
    required this.generateTime,
    required this.timeRange,
    required this.totalMileage,
    required this.totalViolations,
    required this.drivingScore,
    required this.violationStats,
    required this.suggestions,
  });

  factory DrivingReportData.fromJson(Map<String, dynamic> json) {
    return DrivingReportData(
      generateTime: json['generateTime'] ?? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      timeRange: json['timeRange'] ?? '近30天',
      totalMileage: (json['totalMileage'] ?? 0).toDouble(),
      totalViolations: json['totalViolations'] ?? 0,
      drivingScore: json['drivingScore'] ?? 85,
      violationStats: (json['violationStats'] as List<dynamic>?)
          ?.map((item) => ViolationStat.fromJson(item))
          .toList() ?? [],
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ?? [],
    );
  }
}

class ViolationStat {
  final String violationType;
  final int count;

  ViolationStat({
    required this.violationType,
    required this.count,
  });

  factory ViolationStat.fromJson(Map<String, dynamic> json) {
    return ViolationStat(
      violationType: json['violationType'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

// --- 5. 驾驶建议API响应模型 ---
class SuggestionsApiResponse {
  final int code;
  final String message;
  final List<dynamic> data;

  SuggestionsApiResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuggestionsApiResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionsApiResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] ?? [],
    );
  }
}

// --- 6. API 服务 ---
class ApiService {
  // 基础API地址
  static const String _baseUrl = 'http://10.29.177.115:8200';
  static const String _recordApiUrl = '$_baseUrl/api/record/findByIDCard';
  static const String _suggestionsApiUrl = '$_baseUrl/api/user/report'; // 建议API地址

  // 发送 POST 请求获取驾驶数据
  static Future<DrivingData> fetchDrivingRecords({required String idCardNumber}) async {
    try {
      final response = await http.post(
        Uri.parse(_recordApiUrl),
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

  // 获取驾驶建议
  static Future<List<String>> fetchDrivingSuggestions({
    required String idCardNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_suggestionsApiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'idCardNumber': idCardNumber,
        }),
      );

      if (response.statusCode == 200) {
        final SuggestionsApiResponse apiResponse = SuggestionsApiResponse.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );

        if (apiResponse.code == 200) {
          return apiResponse.data.map((item) => item.toString()).toList();
        } else {
          // API返回失败，使用默认建议
          return _getDefaultSuggestions();
        }
      } else {
        throw Exception('请求失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      // 网络请求失败，返回默认建议
      print('建议API请求失败，使用默认建议: $e');
      return _getDefaultSuggestions();
    }
  }

  // 获取完整行车记录报告
  static Future<DrivingReportData> fetchDrivingReport({
    required String idCardNumber,
  }) async {
    try {
      // 获取违规记录数据
      final drivingData = await fetchDrivingRecords(idCardNumber: idCardNumber);

      // 获取驾驶建议（从API）
      final suggestions = await fetchDrivingSuggestions(idCardNumber: idCardNumber);

      // 生成违规统计
      final violationStats = drivingData.stats.entries
          .map((entry) => ViolationStat(
        violationType: entry.key,
        count: entry.value,
      ))
          .toList();

      // 计算驾驶评分
      final drivingScore = _calculateDrivingScore(drivingData.records);

      return DrivingReportData(
        generateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        timeRange: '近30天',
        totalMileage: _estimateTotalMileage(drivingData.records),
        totalViolations: drivingData.records.length,
        drivingScore: drivingScore,
        violationStats: violationStats,
        suggestions: suggestions, // 使用从API获取的建议
      );
    } catch (e) {
      throw Exception('生成报告失败: $e');
    }
  }

  // 计算驾驶评分
  static int _calculateDrivingScore(List<ViolationRecord> records) {
    int baseScore = 100;

    for (var record in records) {
      switch (record.record) {
        case '危险驾驶':
          baseScore -= 20;
          break;
        case '超速行驶':
          baseScore -= 15;
          break;
        case '闯红灯':
          baseScore -= 15;
          break;
        case '疲劳驾驶':
          baseScore -= 10;
          break;
        case '违规变道':
          baseScore -= 8;
          break;
        case '开车使用手机':
          baseScore -= 5;
          break;
        default:
          baseScore -= 5;
      }
    }

    return baseScore < 0 ? 0 : baseScore;
  }

  // 估算总里程
  static double _estimateTotalMileage(List<ViolationRecord> records) {
    // 根据违规记录数量估算里程，这里使用简单的估算方法
    return records.length * 50.0 + 1000.0; // 假设每个违规对应约50公里行驶
  }

  // 默认驾驶建议（当API不可用时使用）
  static List<String> _getDefaultSuggestions() {
    return [
      '请严格遵守交通规则，确保行车安全',
      '定期检查车辆状况，确保车辆性能良好',
      '保持良好的驾驶习惯，文明驾驶',
      '关注天气变化，调整驾驶方式',
      '长途驾驶时请定期休息，避免疲劳驾驶',
    ];
  }
}