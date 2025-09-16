import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';

class RealTimeDetectionPage extends StatefulWidget {
  const RealTimeDetectionPage({super.key});

  @override
  State<RealTimeDetectionPage> createState() => _RealTimeDetectionPageState();
}

class _RealTimeDetectionPageState extends State<RealTimeDetectionPage> {
  // 图表数据类型：0-心率，1-体重，2-血压
  int _chartType = 0;

  // 实时数据
  double _heartRate = 70.0;
  double _bodyTemperature = 36.5;

  // 图表数据点
  final List<FlSpot> _heartRateData = [];
  // **修改点1：新增月度体重数据列表**
  final List<FlSpot> _monthlyWeightData = [];
  final List<FlSpot> _bloodPressureData = [];

  // 时间轴 (用于实时数据)
  double _time = 0;

  // 定时器用于更新数据
  Timer? _timer;

  // 随机数生成器
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // 初始化图表数据
    _initializeChartData();
    // 启动定时器，每2秒更新一次数据
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateData();
    });
  }

  @override
  void dispose() {
    // 取消定时器，防止内存泄漏
    _timer?.cancel();
    super.dispose();
  }

  // 初始化图表数据
  void _initializeChartData() {
    // 初始化实时数据（心率和血压）
    for (int i = 0; i < 10; i++) {
      _time = i.toDouble();
      _heartRateData.add(FlSpot(_time, 65 + _random.nextDouble() * 10));
      _bloodPressureData.add(FlSpot(_time, 120 + _random.nextDouble() * 10));
    }
    _time = 9;

    // **修改点2：填充静态的月度体重数据**
    _monthlyWeightData.addAll([
      FlSpot(1, 70.5),
      FlSpot(2, 71.2),
      FlSpot(3, 71.0),
      FlSpot(4, 71.8),
      FlSpot(5, 72.5),
      FlSpot(6, 72.1),
      FlSpot(7, 71.9),
      FlSpot(8, 72.8),
      FlSpot(9, 72.6),
      FlSpot(10, 72.0),
      FlSpot(11, 71.5),
      FlSpot(12, 71.2),
    ]);
  }

  // 更新实时数据
  void _updateData() {
    setState(() {
      // 更新心率（60-100之间波动）
      _heartRate = _heartRate + (_random.nextDouble() * 4 - 2);
      if (_heartRate < 60) _heartRate = 60;
      if (_heartRate > 100) _heartRate = 100;

      // 更新体温（36.0-37.2之间波动）
      _bodyTemperature = _bodyTemperature + (_random.nextDouble() * 0.2 - 0.1);
      if (_bodyTemperature < 36.0) _bodyTemperature = 36.0;
      if (_bodyTemperature > 37.2) _bodyTemperature = 37.2;

      // 更新图表数据
      _time++;
      _heartRateData.add(FlSpot(_time, _heartRate));
      _bloodPressureData.add(FlSpot(_time, 125 + _random.nextDouble() * 5));

      // 保持数据点数量为10个，只显示最近的趋势
      if (_heartRateData.length > 10) {
        _heartRateData.removeAt(0);
        _bloodPressureData.removeAt(0);
      }
      // **修改点3：移除对体重数据的实时更新**
    });
  }

  // 获取当前图表数据
  List<FlSpot> _getCurrentChartData() {
    switch (_chartType) {
      case 0:
        return _heartRateData;
      case 1:
      // **修改点4：为体重图表提供月度数据**
        return _monthlyWeightData;
      case 2:
        return _bloodPressureData;
      default:
        return _heartRateData;
    }
  }

  // 获取当前图表标题
  String _getCurrentChartTitle() {
    switch (_chartType) {
      case 0:
        return "心率趋势 (bpm)";
      case 1:
        return "月度体重趋势 (kg)";
      case 2:
        return "血压趋势 (mmHg)";
      default:
        return "健康趋势";
    }
  }

  @override
  Widget build(BuildContext context) {
    // 根据图表类型决定图表的X轴范围
    final double minX, maxX;
    if (_chartType == 1) {
      minX = 1;
      maxX = 12;
    } else {
      minX = _heartRateData.first.x;
      maxX = _heartRateData.last.x;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户实时状态'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _getCurrentChartTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Color(0xffe7e8ec),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return const FlLine(
                              color: Color(0xffe7e8ec),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          // **修改点5：根据图表类型动态切换X轴标签**
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: _chartType == 1 ? 1 : 2,
                              getTitlesWidget: _chartType == 1 ? monthBottomTitleWidgets : timeBottomTitleWidgets,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: leftTitleWidgets,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xffe7e8ec), width: 1),
                        ),
                        minX: minX,
                        maxX: maxX,
                        minY: _getMinY(),
                        maxY: _getMaxY(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getCurrentChartData(),
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.lightBlue],
                            ),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent.withOpacity(0.3),
                                  Colors.lightBlue.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChartTypeButton(title: '心率', type: 0),
                      const SizedBox(width: 10),
                      _buildChartTypeButton(title: '体重', type: 1),
                      const SizedBox(width: 10),
                      _buildChartTypeButton(title: '血压', type: 2),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildInfoCard(
                  title: '实时心率',
                  value: '${_heartRate.toStringAsFixed(1)} bpm',
                  icon: Icons.favorite,
                  color: Colors.red,
                ),
                _buildInfoCard(
                  title: '实时体温',
                  value: '${_bodyTemperature.toStringAsFixed(1)} °C',
                  icon: Icons.thermostat_outlined,
                  color: Colors.orange,
                ),
                _buildInfoCard(
                  title: '车辆状态',
                  value: '正常',
                  icon: Icons.directions_car,
                  color: Colors.green,
                ),
                _buildInfoCard(
                  title: '用户状态',
                  value: '良好',
                  icon: Icons.person_outline,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeButton({required String title, required int type}) {
    bool isSelected = _chartType == type;
    return ElevatedButton(
      onPressed: () => setState(() => _chartType = type),
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(title),
    );
  }

  // 用于显示实时时间的X轴标签
  Widget timeBottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(value.toInt().toString(), style: style),
    );
  }

  // 新增：用于显示月份的X轴标签
  Widget monthBottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    // 每隔一个月显示一个标签，避免拥挤
    if (value.toInt() % 2 != 0) {
      text = '${value.toInt()}月';
    } else {
      text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    int interval;
    switch (_chartType) {
      case 0:
        interval = 20;
        break;
      case 1:
        interval = 2;
        break;
      case 2:
        interval = 10;
        break;
      default:
        interval = 10;
    }

    if (value.toInt() % interval != 0) {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(value.toInt().toString(), style: style, textAlign: TextAlign.left),
    );
  }

  double _getMinY() {
    switch (_chartType) {
      case 0:
        return 50;
      case 1:
      // **修改点6：调整体重图表的Y轴范围**
        return 68;
      case 2:
        return 110;
      default:
        return 0;
    }
  }

  double _getMaxY() {
    switch (_chartType) {
      case 0:
        return 110;
      case 1:
      // **修改点7：调整体重图表的Y轴范围**
        return 74;
      case 2:
        return 140;
      default:
        return 100;
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}