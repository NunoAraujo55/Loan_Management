import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_amortiza/auth/auth.service.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl:
          'http://localhost:3001/', //in case of emulator use 10.0.2.2:3001 // in case of real fone 172.20.10.2:3001/
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 3),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Attach the access token to every request
        final token = await AuthService.instance.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // On 401, try to refresh the token and retry the request
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await AuthService.instance.getRefreshToken();
            if (refreshToken != null) {
              // Use a separate Dio instance to avoid interceptor loop
              final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
              final response = await refreshDio.post(
                'auth/refresh',
                options: Options(headers: {
                  'Authorization': 'Bearer $refreshToken',
                }),
              );

              final newAccessToken = response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];
              await AuthService.instance
                  .storeTokens(newAccessToken, newRefreshToken);

              // Retry the original request with the new token
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse =
                  await refreshDio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          } catch (_) {
            // Refresh failed — user needs to re-login
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  });
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
      return [];
    }
  } catch (e) {
    return [];
  }
}
