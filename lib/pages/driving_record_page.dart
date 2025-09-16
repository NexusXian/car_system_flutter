import 'package:flutter/material.dart';
import '../api/service_api.dart';

class DrivingRecordPage extends StatefulWidget {
  const DrivingRecordPage({super.key});

  @override
  State<DrivingRecordPage> createState() => _DrivingRecordPageState();
}

class _DrivingRecordPageState extends State<DrivingRecordPage> {
  late Future<DrivingData> _drivingDataFuture;

  @override
  void initState() {
    super.initState();
    _drivingDataFuture = ApiService.fetchDrivingRecords(
        idCardNumber: "110101199001011234"
    );
  }

  void _viewDrivingReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在加载行车记录报告...'),
        duration: Duration(seconds: 2),
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
      // 使用SafeArea确保内容不会被系统UI遮挡
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
            // 计算总违规次数
            final totalViolations = records.length;

            return CustomScrollView(
              // 增加内边距避免内容与底部按钮重叠
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
          label: const Text('查看完整行车记录报告', style: TextStyle(color: Colors.white)),
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

  // 显示总违规次数的卡片
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
            // 添加溢出处理
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                record.formattedCreateAt,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '姓名: ${record.realName}',
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '车牌: ${record.licensePlate.isEmpty ? "未登记" : record.licensePlate}',
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
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
