import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amortiza/core/service_locater.dart';

class LineCharWidget extends StatefulWidget {
  final ValueChanged<double> onPercentChange;
  final String euribor;
  const LineCharWidget(
      {Key? key, required this.onPercentChange, required this.euribor})
      : super(key: key);

  @override
  _LineCharWidgetState createState() => _LineCharWidgetState();
}

class _LineCharWidgetState extends State<LineCharWidget> {
  List<FlSpot> spots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final fetchedSpots = await fetchEuriborData(widget.euribor);

    fetchedSpots.sort((a, b) => a.x.compareTo(b.x));

    double change = 0;
    if (fetchedSpots.isNotEmpty && fetchedSpots.first.y != 0) {
      final first = fetchedSpots.first.y;
      final last = fetchedSpots.last.y;
      change = ((last - first) / first) * 100;
    }
    widget.onPercentChange(change);

    setState(() {
      spots = fetchedSpots;
      isLoading = false;
    });
  }

  @override
  void didUpdateWidget(covariant LineCharWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.euribor != widget.euribor) {
      _loadData();
    }
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    double minX = spots.isNotEmpty ? spots.map((s) => s.x).reduce(math.min) : 0;
    double maxX = spots.isNotEmpty ? spots.map((s) => s.x).reduce(math.max) : 1;
    double minY = spots.isNotEmpty ? spots.map((s) => s.y).reduce(math.min) : 0;
    double maxY = spots.isNotEmpty ? spots.map((s) => s.y).reduce(math.max) : 5;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          height: 200,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withAlpha(60),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: (maxX - minX) /
                              3, // show exactly 4 labels: minX, 1/3, 2/3, maxX
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            final formatted = _monthLabel(date.month);
                            return Text(
                              formatted,
                              style: const TextStyle(color: Color(0xFF002E8B)),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 0,
                          interval: (maxY - minY) / 5,
                          getTitlesWidget: (value, meta) =>
                              Text(value.toStringAsFixed(0)),
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(
                      show: false,
                      border: const Border(
                        left: BorderSide(color: Colors.black, width: 1),
                        bottom: BorderSide(color: Colors.black, width: 1),
                        top: BorderSide.none,
                        right: BorderSide.none,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
