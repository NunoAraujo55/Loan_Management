import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amortiza/controllers/loan_controller.dart';
import 'package:flutter_amortiza/controllers/user_controller.dart';
import 'package:flutter_amortiza/core/service_locater.dart';
import 'package:flutter_amortiza/screens/SignUpScreens/first_screen.dart';
import 'package:flutter_amortiza/utils/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await initializeDateFormatting('pt_PT', null);
  setupLocator();

  if (Platform.isIOS) {
    print('⚠️ iOS: triggering local network access...');
    await Future.delayed(Duration(seconds: 1));

    try {
      final dio = getIt<Dio>(); // ✅ use the registered Dio
      final response =
          await dio.get('euribor/rate/3meses'); // ✅ relative to baseUrl
      print('✅ Local network request successful: ${response.statusCode}');
    } catch (e) {
      print('❌ Local network request failed: $e');
    }
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => LoanController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Adjust the status bar style to match the background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
            Color(0xFFD8EAF2), // Matches the Scaffold/AppBar background
        statusBarIconBrightness:
            Brightness.dark, // Dark icons for light background
      ),
    );

    // Rename the variable to avoid shadowing the ThemeProvider class
    final themeNotifier = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Use the provider state to select the theme. You can replace ThemeData.dark()/light() with your custom themes if available.
      theme: themeNotifier.isDarkMode
          ? ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Inter',
            )
          : ThemeData(
              brightness: Brightness.light,
              fontFamily: 'Inter',
            ),
      home: FirstScreen(),
    );
  }
}
