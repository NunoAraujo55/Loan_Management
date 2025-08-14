import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final String title;
  final String subtitle1;
  final String subtitle2;

  const ChartWidget({
    Key? key,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 500,
                            getTitlesWidget: (value, meta) {
                              return Text('\$${value.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return Text(subtitle1,
                                      style: TextStyle(fontSize: 12));
                                case 1:
                                  return Text(subtitle2,
                                      style: TextStyle(fontSize: 12));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: 1300,
                              color: Colors.deepPurple,
                              width: 50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: 1500,
                              color: Colors.deepPurple.shade200,
                              width: 50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
