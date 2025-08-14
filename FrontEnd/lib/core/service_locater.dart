import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        baseUrl:
            'http://localhost:3001/', //in case of emulator use 10.0.2.2:3001 // in case of real fone 172.20.10.2:3001/
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 3),
      )));
}

List<FlSpot> parseEuriborData(Map<String, dynamic> jsonData) {
  final List<dynamic> dataList = jsonData['data'];
  if (dataList.isEmpty) return [];

  final List<dynamic> euriborPoints = dataList[0]['Data'];

  final DateTime now = DateTime.now();
  final DateTime oneYearAgo = now.subtract(Duration(days: 365));

  // Use a Map to track the latest entry per (year, month)
  final Map<String, FlSpot> monthlyLastPoints = {};

  for (var point in euriborPoints) {
    final int timestampMs = (point[0] as num).toInt();
    final double value = (point[1] as num).toDouble();
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestampMs);

    if (date.isBefore(oneYearAgo)) continue;

    final String key = '${date.year}-${date.month}';

    final currentSpot = FlSpot(timestampMs.toDouble(), value);

    // Replace if it's newer in the same month
    if (!monthlyLastPoints.containsKey(key) ||
        timestampMs > monthlyLastPoints[key]!.x) {
      monthlyLastPoints[key] = currentSpot;
    }
  }

  // Sort by timestamp
  final sortedSpots = monthlyLastPoints.values.toList()
    ..sort((a, b) => a.x.compareTo(b.x));

  return sortedSpots;
}

Future<List<FlSpot>> fetchEuriborData(String euribor) async {
  final Dio dio = getIt<Dio>();
  try {
    final response = await dio.get('euribor/rate/$euribor');
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data;
      return parseEuriborData(jsonData);
    } else {
      print('Error: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching Euribor data: $e');
    return [];
  }
}
