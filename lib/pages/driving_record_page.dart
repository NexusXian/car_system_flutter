import 'dart:async';
import 'package:flutter/material.dart';
import '../api/service_api.dart';

class DrivingRecordPage extends StatefulWidget {
  const DrivingRecordPage({super.key});

  @override
  State<DrivingRecordPage> createState() => _DrivingRecordPageState();
}

class _DrivingRecordPageState extends State<DrivingRecordPage> {
  late Future<DrivingData> _drivingDataFuture;
  Timer? _timer; // 定时器

  @override
  void initState() {
    super.initState();
    _fetchData();

    // 每隔 5 秒刷新一次
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchData();
    });
  }

  void _fetchData() {
    setState(() {
      _drivingDataFuture = ApiService.fetchDrivingRecords(
        idCardNumber: "110101199001011234",
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 页面销毁时取消定时器
    super.dispose();
  }

  void _viewDrivingReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DrivingReportPage(),
      ),
    );
  }

  void _viewViolationDetail(ViolationRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViolationDetailPage(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('驾驶记录'),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FutureBuilder<DrivingData>(
          future: _drivingDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('加载失败: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.records.isEmpty) {
              String message = snapshot.data?.message ?? '暂无违规记录';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final drivingData = snapshot.data!;
            final records = drivingData.records;
            final totalViolations = records.length;

            return CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                    child: Text('违规统计', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildTotalViolationCard(totalViolations),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 10.0),
                    child: Text('违规记录', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final record = records[index];
                      return _buildViolationTile(record);
                    },
                    childCount: records.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton.icon(
          onPressed: _viewDrivingReport,
          icon: const Icon(Icons.description_outlined, color: Colors.white),
          label: const Text('AI报告分析', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalViolationCard(int total) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '总违规次数',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                '$total 次',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViolationTile(ViolationRecord record) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red[100],
            child: Icon(_getIconForViolation(record.record), color: Colors.red[700]),
          ),
          title: Text(
            record.record,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(record.formattedCreateAt, overflow: TextOverflow.ellipsis),
              Text('姓名: ${record.realName}', overflow: TextOverflow.ellipsis),
              Text('车牌: ${record.licensePlate.isEmpty ? "未登记" : record.licensePlate}', overflow: TextOverflow.ellipsis),
            ],
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _viewViolationDetail(record),
        ),
      ),
    );
  }

  IconData _getIconForViolation(String violationType) {
    switch (violationType) {
      case '超速行驶':
        return Icons.speed;
      case '闯红灯':
        return Icons.traffic;
      case '违规变道':
        return Icons.merge_type;
      case '疲劳驾驶':
        return Icons.airline_seat_individual_suite;
      case '危险驾驶':
        return Icons.dangerous;
      case '开车使用手机':
        return Icons.phone_android;
      default:
        return Icons.warning_amber_rounded;
    }
  }
}

// 违规记录详细信息页面
class ViolationDetailPage extends StatelessWidget {
  final ViolationRecord record;

  const ViolationDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('违规详情'),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red[100],
                      radius: 30,
                      child: Icon(
                        _getIconForViolation(record.record),
                        color: Colors.red[700],
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      record.record,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '详细信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('违规时间', record.formattedCreateAt),
                    _buildDetailRow('驾驶员姓名', record.realName),
                    _buildDetailRow('车牌号码', record.licensePlate.isEmpty ? '未登记' : record.licensePlate),
                    _buildDetailRow('违规类型', record.record),
                    // 可以根据需要添加更多详细信息
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForViolation(String violationType) {
    switch (violationType) {
      case '超速行驶':
        return Icons.speed;
      case '闯红灯':
        return Icons.traffic;
      case '违规变道':
        return Icons.merge_type;
      case '疲劳驾驶':
        return Icons.airline_seat_individual_suite;
      case '危险驾驶':
        return Icons.dangerous;
      case '开车使用手机':
        return Icons.phone_android;
      default:
        return Icons.warning_amber_rounded;
    }
  }
}

// 完整行车记录报告页面
class DrivingReportPage extends StatefulWidget {
  const DrivingReportPage({super.key});

  @override
  State<DrivingReportPage> createState() => _DrivingReportPageState();
}

class _DrivingReportPageState extends State<DrivingReportPage> {
  late Future<DrivingReportData> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _fetchReport();
  }

  Future<DrivingReportData> _fetchReport() async {
    // 调用API获取完整报告数据
    return ApiService.fetchDrivingReport(
      idCardNumber: "110101199001011234",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行车记录报告'),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<DrivingReportData>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在生成报告...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('报告加载失败: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _reportFuture = _fetchReport();
                      });
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('暂无报告数据'));
          }

          final reportData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 报告摘要卡片
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '报告摘要',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow('报告生成时间', reportData.generateTime),
                        _buildSummaryRow('统计时间范围', reportData.timeRange),
                        _buildSummaryRow('总行驶里程', '${reportData.totalMileage} 公里'),
                        _buildSummaryRow('总违规次数', '${reportData.totalViolations} 次'),
                        _buildSummaryRow('驾驶评分', '${reportData.drivingScore} 分'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 违规类型统计
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '违规类型统计',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...reportData.violationStats.map((stat) =>
                            _buildViolationStatRow(stat.violationType, stat.count)
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 驾驶建议
                if (reportData.suggestions.isNotEmpty)
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '驾驶建议',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...reportData.suggestions.map((suggestion) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontSize: 16)),
                                    Expanded(child: Text(suggestion)),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildViolationStatRow(String type, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count 次',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}